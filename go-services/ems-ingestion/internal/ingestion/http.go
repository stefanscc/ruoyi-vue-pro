package ingestion

import (
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"ems-ingestion/internal/config"
)

func NewHTTPServer(cfg config.Config, deps *Dependencies, processor *Processor) http.Handler {
	mux := http.NewServeMux()
	h := &httpHandler{cfg: cfg, deps: deps, processor: processor}
	mux.HandleFunc("POST /mqtt/auth", h.handleAuth)
	mux.HandleFunc("POST /mqtt/acl", h.handleACL)
	mux.HandleFunc("POST /mqtt/event", h.handleEvent)
	mux.HandleFunc("GET /internal/health", h.handleHealth)
	mux.HandleFunc("POST /internal/reload", h.requireToken(h.handleReload))
	mux.HandleFunc("POST /internal/downlink", h.requireToken(h.handleDownlink))
	return mux
}

type httpHandler struct {
	cfg       config.Config
	deps      *Dependencies
	processor *Processor
}

func (h *httpHandler) handleAuth(w http.ResponseWriter, r *http.Request) {
	var body struct {
		ClientID string `json:"clientid"`
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeEMQX(w, "ignore")
		return
	}
	if h.isInternalMQTTClient(body.ClientID, body.Username, body.Password) {
		writeEMQX(w, "allow")
		return
	}
	productKey, deviceName, ok := parseUsername(body.Username)
	if !ok {
		writeEMQX(w, "deny")
		return
	}
	if strings.HasSuffix(body.ClientID, authTypeRegister) {
		product, exists := h.deps.Cache.Snapshot().ProductsByKey[productKey]
		if !exists {
			writeEMQX(w, "deny")
			return
		}
		if _, _, err := RegisterDevice(r.Context(), h.deps.PG, product, deviceName, body.Password); err != nil {
			writeEMQX(w, "deny")
			return
		}
		_ = h.deps.Cache.Reload(r.Context())
		writeEMQX(w, "allow")
		return
	}
	device, ok := h.deps.Cache.Snapshot().DeviceByIdentity(productKey, deviceName)
	if !ok || !validateDevicePassword(device, body.ClientID, body.Username, body.Password) {
		writeEMQX(w, "deny")
		return
	}
	writeEMQX(w, "allow")
}

func (h *httpHandler) handleACL(w http.ResponseWriter, r *http.Request) {
	var body struct {
		ClientID string `json:"clientid"`
		Username string `json:"username"`
		Topic    string `json:"topic"`
		Action   string `json:"action"`
		Access   string `json:"access"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeEMQX(w, "ignore")
		return
	}
	if body.ClientID == h.cfg.MQTTClientID && body.Username == h.cfg.MQTTUsername {
		writeEMQX(w, "allow")
		return
	}
	productKey, deviceName, ok := parseUsername(body.Username)
	if !ok {
		writeEMQX(w, "ignore")
		return
	}
	action := strings.ToLower(body.Action + body.Access)
	subscribe := strings.Contains(action, "sub")
	publish := strings.Contains(action, "pub")
	if !subscribe && !publish {
		writeEMQX(w, "ignore")
		return
	}
	if topicAllowed(body.Topic, productKey, deviceName, subscribe) {
		writeEMQX(w, "allow")
		return
	}
	writeEMQX(w, "deny")
}

func (h *httpHandler) isInternalMQTTClient(clientID, username, password string) bool {
	return clientID == h.cfg.MQTTClientID &&
		username == h.cfg.MQTTUsername &&
		password == h.cfg.MQTTPassword
}

func (h *httpHandler) handleEvent(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Event    string `json:"event"`
		Username string `json:"username"`
		ClientID string `json:"clientid"`
	}
	_ = json.NewDecoder(r.Body).Decode(&body)
	if body.Username != "" {
		productKey, deviceName, ok := parseUsername(body.Username)
		if ok {
			if device, exists := h.deps.Cache.Snapshot().DeviceByIdentity(productKey, deviceName); exists {
				state := DeviceStateOnline
				if strings.Contains(body.Event, "disconnected") {
					state = DeviceStateOffline
				}
				reportTime := now()
				_ = UpdateDeviceReportState(r.Context(), h.deps.PG, device.ID, state, reportTime)
				_ = UpdateRedisRuntime(r.Context(), h.deps.Redis, device, h.cfg.ServerID, reportTime, nil)
			}
		}
	}
	writeJSON(w, map[string]any{"result": "ok"})
}

func (h *httpHandler) handleHealth(w http.ResponseWriter, r *http.Request) {
	snapshot := h.deps.Cache.Snapshot()
	writeJSON(w, map[string]any{
		"status":      "UP",
		"serverId":    h.cfg.ServerID,
		"cacheLoaded": snapshot.LoadedAt,
		"devices":     len(snapshot.DevicesByID),
		"dataRules":   len(snapshot.DataRules),
		"dataSinks":   len(snapshot.DataSinks),
	})
}

func (h *httpHandler) handleReload(w http.ResponseWriter, r *http.Request) {
	if err := h.deps.Cache.Reload(r.Context()); err != nil {
		writeError(w, err)
		return
	}
	if err := h.deps.TD.EnsureProductPropertyTables(r.Context(), h.deps.Cache.Snapshot()); err != nil {
		writeError(w, err)
		return
	}
	writeJSON(w, map[string]any{"ok": true})
}

func (h *httpHandler) handleDownlink(w http.ResponseWriter, r *http.Request) {
	var body struct {
		DeviceID   int64          `json:"deviceId"`
		ProductKey string         `json:"productKey"`
		DeviceName string         `json:"deviceName"`
		RequestID  string         `json:"requestId"`
		Method     string         `json:"method"`
		Params     map[string]any `json:"params"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, err)
		return
	}
	snapshot := h.deps.Cache.Snapshot()
	var device Device
	var ok bool
	if body.DeviceID != 0 {
		device, ok = snapshot.DeviceByID(body.DeviceID)
	} else {
		device, ok = snapshot.DeviceByIdentity(body.ProductKey, body.DeviceName)
	}
	if !ok {
		writeJSONStatus(w, http.StatusNotFound, map[string]any{"error": "device not found"})
		return
	}
	msg := DeviceMessage{
		RequestID: body.RequestID,
		Method:    body.Method,
		Params:    body.Params,
	}
	if err := h.processor.ProcessDownlink(r.Context(), msg, device); err != nil {
		writeError(w, err)
		return
	}
	writeJSON(w, map[string]any{"ok": true, "deviceId": device.ID})
}

func (h *httpHandler) requireToken(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("X-Internal-Token")
		if token == "" && strings.HasPrefix(r.Header.Get("Authorization"), "Bearer ") {
			token = strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
		}
		if h.cfg.InternalToken != "" && token != h.cfg.InternalToken {
			writeJSONStatus(w, http.StatusUnauthorized, map[string]any{"error": "unauthorized"})
			return
		}
		next(w, r)
	}
}

func writeEMQX(w http.ResponseWriter, result string) {
	writeJSON(w, map[string]any{"result": result, "is_superuser": false})
}

func writeJSON(w http.ResponseWriter, body any) {
	writeJSONStatus(w, http.StatusOK, body)
}

func writeJSONStatus(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, err error) {
	writeJSONStatus(w, http.StatusInternalServerError, map[string]any{"error": err.Error()})
}

func now() time.Time {
	return time.Now()
}
