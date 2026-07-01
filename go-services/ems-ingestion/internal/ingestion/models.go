package ingestion

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

const (
	MethodStateUpdate        = "thing.state.update"
	MethodSubDeviceStatePack = "thing.device.state.pack.post"
	MethodTopoAdd            = "thing.topo.add"
	MethodTopoDelete         = "thing.topo.delete"
	MethodTopoGet            = "thing.topo.get"
	MethodDeviceRegister     = "thing.auth.register"
	MethodSubDeviceRegister  = "thing.auth.register.sub"
	MethodPropertyPost       = "thing.property.post"
	MethodPropertySet        = "thing.property.set"
	MethodPropertyPackPost   = "thing.event.property.pack.post"
	MethodEventPost          = "thing.event.post"
	MethodServiceInvoke      = "thing.service.invoke"
	MethodConfigPush         = "thing.config.push"
	MethodOTAProgress        = "thing.ota.progress"

	DataSinkDatabase = 20

	StatusEnable = 0

	DeviceStateInactive = 0
	DeviceStateOnline   = 1
	DeviceStateOffline  = 2

	ProductDeviceTypeGatewaySub = 1
	ProductDeviceTypeGateway    = 2
)

var upstreamMethods = map[string]bool{
	MethodStateUpdate:        true,
	MethodSubDeviceStatePack: true,
	MethodTopoAdd:            true,
	MethodTopoDelete:         true,
	MethodTopoGet:            true,
	MethodDeviceRegister:     true,
	MethodSubDeviceRegister:  true,
	MethodPropertyPost:       true,
	MethodPropertyPackPost:   true,
	MethodEventPost:          true,
	MethodOTAProgress:        true,
	MethodPropertySet:        false,
	MethodServiceInvoke:      false,
	MethodConfigPush:         false,
}

type Device struct {
	ID           int64
	DeviceName   string
	ProductID    int64
	ProductKey   string
	DeviceType   int
	GatewayID    *int64
	State        int
	DeviceSecret string
}

type Product struct {
	ID              int64
	ProductKey      string
	ProductSecret   string
	RegisterEnabled bool
	DeviceType      int
}

type ThingModel struct {
	ID         int64
	ProductID  int64
	ProductKey string
	Identifier string
	Type       int
	DataType   string
	Length     int
}

type DataRule struct {
	ID      int64
	Status  int
	Sources []RuleSource
	SinkIDs []int64
}

type RuleSource struct {
	Method     string `json:"method"`
	ProductID  int64  `json:"productId"`
	DeviceID   int64  `json:"deviceId"`
	Identifier string `json:"identifier"`
}

type DataSink struct {
	ID     int64
	Status int
	Type   int
	Config DatabaseSinkConfig
}

type DatabaseSinkConfig struct {
	Type      string `json:"type"`
	JDBCURL   string `json:"jdbcUrl"`
	Username  string `json:"username"`
	Password  string `json:"password"`
	TableName string `json:"tableName"`
}

type DeviceMessage struct {
	ID         string    `json:"id,omitempty"`
	ReportTime time.Time `json:"reportTime,omitempty"`
	DeviceID   int64     `json:"deviceId,omitempty"`
	ServerID   string    `json:"serverId,omitempty"`
	RequestID  string    `json:"requestId,omitempty"`
	Method     string    `json:"method,omitempty"`
	Params     any       `json:"params,omitempty"`
	Data       any       `json:"data,omitempty"`
	Code       *int      `json:"code,omitempty"`
	Msg        string    `json:"msg,omitempty"`

	RawPayload json.RawMessage `json:"-"`
}

func (m *DeviceMessage) UnmarshalJSON(data []byte) error {
	type Alias DeviceMessage
	aux := struct {
		ReportTime json.RawMessage `json:"reportTime"`
		*Alias
	}{
		Alias: (*Alias)(m),
	}
	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}
	if len(aux.ReportTime) == 0 {
		return nil
	}
	reportTime, err := parseReportTime(aux.ReportTime)
	if err != nil {
		return err
	}
	m.ReportTime = reportTime
	return nil
}

func parseReportTime(raw json.RawMessage) (time.Time, error) {
	value := strings.TrimSpace(string(raw))
	if value == "" || value == "null" {
		return time.Time{}, nil
	}
	var text string
	if err := json.Unmarshal(raw, &text); err == nil {
		for _, layout := range []string{time.RFC3339Nano, time.RFC3339, "2006-01-02 15:04:05"} {
			if parsed, err := time.Parse(layout, text); err == nil {
				return parsed, nil
			}
		}
		return time.Time{}, fmt.Errorf("invalid reportTime %q", text)
	}
	decoder := json.NewDecoder(strings.NewReader(value))
	decoder.UseNumber()
	var number json.Number
	if err := decoder.Decode(&number); err != nil {
		return time.Time{}, err
	}
	millis, err := number.Int64()
	if err != nil {
		return time.Time{}, err
	}
	if millis > 1_000_000_000_000 {
		return time.UnixMilli(millis), nil
	}
	return time.Unix(millis, 0), nil
}

type TopicInfo struct {
	ProductKey string
	DeviceName string
	Method     string
	IsReply    bool
}

type PackMessage struct {
	Properties map[string]any            `json:"properties"`
	Events     map[string]PackEventValue `json:"events"`
	SubDevices []PackSubDevice           `json:"subDevices"`
}

type PackSubDevice struct {
	Identity   DeviceIdentity            `json:"identity"`
	Properties map[string]any            `json:"properties"`
	Events     map[string]PackEventValue `json:"events"`
}

type PackEventValue struct {
	Value any    `json:"value"`
	Time  *int64 `json:"time"`
}

type DeviceIdentity struct {
	ProductKey string `json:"productKey"`
	DeviceName string `json:"deviceName"`
}

func (m DeviceMessage) IsReply() bool {
	return m.Code != nil
}

func (m DeviceMessage) IsUpstream() bool {
	upstream, ok := upstreamMethods[m.Method]
	if !ok {
		return true
	}
	if m.IsReply() {
		return !upstream
	}
	return upstream
}

func (m DeviceMessage) Identifier() string {
	params := m.ParamsMap()
	if m.Method == MethodEventPost || m.Method == MethodServiceInvoke {
		return stringValue(params["identifier"])
	}
	if m.Method == MethodStateUpdate {
		return stringValue(params["state"])
	}
	return ""
}

func (m DeviceMessage) PropertyIdentifiers() []string {
	if m.Method != MethodPropertyPost {
		return nil
	}
	params := m.ParamsMap()
	keys := make([]string, 0, len(params))
	for key := range params {
		keys = append(keys, key)
	}
	return keys
}

func (m DeviceMessage) ParamsMap() map[string]any {
	if m.Params == nil {
		return map[string]any{}
	}
	if params, ok := m.Params.(map[string]any); ok {
		return params
	}
	bytes, err := json.Marshal(m.Params)
	if err != nil {
		return map[string]any{}
	}
	var params map[string]any
	if err := json.Unmarshal(bytes, &params); err != nil {
		return map[string]any{}
	}
	return params
}

func ParseTopic(topic string) (TopicInfo, bool) {
	parts := strings.Split(strings.Trim(topic, "/"), "/")
	if len(parts) < 5 || parts[0] != "sys" {
		return TopicInfo{}, false
	}
	methodParts := parts[3:]
	if len(methodParts) == 0 {
		return TopicInfo{}, false
	}
	last := methodParts[len(methodParts)-1]
	isReply := strings.HasSuffix(last, "_reply")
	if isReply {
		methodParts[len(methodParts)-1] = strings.TrimSuffix(last, "_reply")
	}
	return TopicInfo{
		ProductKey: parts[1],
		DeviceName: parts[2],
		Method:     strings.Join(methodParts, "."),
		IsReply:    isReply,
	}, true
}

func BuildTopic(productKey, deviceName, method string, reply bool) string {
	suffix := strings.ReplaceAll(method, ".", "/")
	if reply {
		suffix += "_reply"
	}
	return "/sys/" + productKey + "/" + deviceName + "/" + suffix
}

func stringValue(v any) string {
	switch value := v.(type) {
	case string:
		return value
	case json.Number:
		return value.String()
	case nil:
		return ""
	default:
		bytes, _ := json.Marshal(value)
		return strings.Trim(string(bytes), `"`)
	}
}
