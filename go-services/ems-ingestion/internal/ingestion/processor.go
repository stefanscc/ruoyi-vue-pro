package ingestion

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"strings"
	"time"

	"ems-ingestion/internal/config"

	"github.com/google/uuid"
)

type Processor struct {
	cfg  config.Config
	deps *Dependencies
	pub  func(topic string, payload []byte) error
}

func NewProcessor(cfg config.Config, deps *Dependencies) *Processor {
	return &Processor{cfg: cfg, deps: deps}
}

func (p *Processor) SetPublisher(pub func(topic string, payload []byte) error) {
	p.pub = pub
}

func (p *Processor) ProcessMQTT(ctx context.Context, topic string, payload []byte) error {
	info, ok := ParseTopic(topic)
	if !ok {
		return fmt.Errorf("invalid topic %s", topic)
	}
	var msg DeviceMessage
	if err := json.Unmarshal(payload, &msg); err != nil {
		return err
	}
	msg.RawPayload = append([]byte(nil), payload...)
	if msg.Method == "" {
		msg.Method = info.Method
	}
	if info.IsReply && msg.Code == nil {
		code := 0
		msg.Code = &code
	}
	if msg.Code != nil && len(msg.Method) > 6 && msg.Method[len(msg.Method)-6:] == "_reply" {
		msg.Method = msg.Method[:len(msg.Method)-6]
	}
	if msg.ID == "" {
		msg.ID = uuid.NewString()
	}
	if msg.ReportTime.IsZero() {
		msg.ReportTime = time.Now()
	}
	if msg.RequestID == "" {
		return errors.New("requestId is required for MQTT QoS1 idempotency")
	}
	if msg.Method == MethodDeviceRegister {
		return p.processDeviceRegister(ctx, info, msg)
	}
	device, ok := p.deps.Cache.Snapshot().DeviceByIdentity(info.ProductKey, info.DeviceName)
	if !ok {
		return fmt.Errorf("device %s/%s not found", info.ProductKey, info.DeviceName)
	}
	msg.DeviceID = device.ID
	msg.ServerID = p.cfg.ServerID
	first, err := Dedupe(ctx, p.deps.Redis, p.cfg.DedupeTTL, msg)
	if err != nil {
		return err
	}
	if !first {
		log.Printf("duplicate MQTT message ignored: device=%d method=%s requestId=%s", msg.DeviceID, msg.Method, msg.RequestID)
		return nil
	}
	return p.process(ctx, device, msg, true)
}

func (p *Processor) ProcessDownlink(ctx context.Context, msg DeviceMessage, device Device) error {
	if msg.ID == "" {
		msg.ID = uuid.NewString()
	}
	if msg.RequestID == "" {
		msg.RequestID = msg.ID
	}
	if msg.ReportTime.IsZero() {
		msg.ReportTime = time.Now()
	}
	msg.DeviceID = device.ID
	msg.ServerID = p.cfg.ServerID
	if msg.Params == nil {
		msg.Params = map[string]any{}
	}
	if err := p.deps.TD.InsertMessage(ctx, msg, msg.Identifier()); err != nil {
		return err
	}
	if p.pub == nil {
		return errors.New("MQTT publisher is not ready")
	}
	payload, _ := json.Marshal(msg)
	return p.pub(BuildTopic(device.ProductKey, device.DeviceName, msg.Method, msg.IsReply()), payload)
}

func (p *Processor) process(ctx context.Context, device Device, msg DeviceMessage, reply bool) error {
	identifier := msg.Identifier()
	if err := p.deps.TD.InsertMessage(ctx, msg, identifier); err != nil {
		return err
	}
	if msg.IsReply() {
		return nil
	}
	if err := UpdateRedisRuntime(ctx, p.deps.Redis, device, msg.ServerID, msg.ReportTime, nil); err != nil {
		return err
	}

	var replyData any
	var processErr error
	switch msg.Method {
	case MethodStateUpdate:
		processErr = p.handleState(ctx, msg)
	case MethodSubDeviceStatePack:
		processErr = p.handleSubDeviceStatePack(ctx, msg)
	case MethodPropertyPost:
		processErr = p.handleProperties(ctx, device, msg)
	case MethodEventPost:
		processErr = p.executeDataRules(ctx, msg)
	case MethodPropertyPackPost:
		processErr = p.handlePack(ctx, device, msg)
	case MethodTopoAdd:
		replyData, processErr = p.handleTopoAdd(ctx, device, msg)
	case MethodTopoDelete:
		replyData, processErr = p.handleTopoDelete(ctx, device, msg)
	case MethodTopoGet:
		replyData, processErr = p.handleTopoGet(ctx, device)
	case MethodOTAProgress:
		processErr = nil
	case MethodSubDeviceRegister:
		replyData, processErr = p.handleSubDeviceRegister(ctx, device, msg)
	default:
		processErr = nil
	}
	if reply && !replyDisabled(msg.Method) {
		_ = p.reply(ctx, device, msg, replyData, processErr)
	}
	return processErr
}

func (p *Processor) processDeviceRegister(ctx context.Context, info TopicInfo, msg DeviceMessage) error {
	snapshot := p.deps.Cache.Snapshot()
	product, ok := snapshot.ProductsByKey[info.ProductKey]
	if !ok {
		err := fmt.Errorf("product %s not found", info.ProductKey)
		_ = p.replyToIdentity(ctx, info, msg, nil, err)
		return err
	}
	params := msg.ParamsMap()
	sign := stringValue(params["sign"])
	if sign == "" {
		sign = stringValue(params["password"])
	}
	device, data, err := RegisterDevice(ctx, p.deps.PG, product, info.DeviceName, sign)
	if err != nil {
		_ = p.replyToIdentity(ctx, info, msg, nil, err)
		return err
	}
	msg.DeviceID = device.ID
	msg.ServerID = p.cfg.ServerID
	first, err := Dedupe(ctx, p.deps.Redis, p.cfg.DedupeTTL, msg)
	if err != nil {
		return err
	}
	if !first {
		log.Printf("duplicate MQTT register ignored: device=%d requestId=%s", msg.DeviceID, msg.RequestID)
		return nil
	}
	if err := p.deps.TD.InsertMessage(ctx, msg, msg.Identifier()); err != nil {
		return err
	}
	_ = p.deps.Cache.Reload(ctx)
	return p.reply(ctx, device, msg, data, nil)
}

func (p *Processor) handleState(ctx context.Context, msg DeviceMessage) error {
	params := msg.ParamsMap()
	state := intFromAny(params["state"])
	if err := UpdateDeviceReportState(ctx, p.deps.PG, msg.DeviceID, state, msg.ReportTime); err != nil {
		return err
	}
	return UpdateRedisRuntime(ctx, p.deps.Redis, Device{ID: msg.DeviceID}, msg.ServerID, msg.ReportTime, nil)
}

func (p *Processor) handleSubDeviceStatePack(ctx context.Context, msg DeviceMessage) error {
	raw, _ := json.Marshal(msg.Params)
	var body struct {
		SubDevices []struct {
			Identity DeviceIdentity `json:"identity"`
			State    int            `json:"state"`
			Time     *int64         `json:"time"`
		} `json:"subDevices"`
	}
	if err := json.Unmarshal(raw, &body); err != nil {
		return err
	}
	snapshot := p.deps.Cache.Snapshot()
	for _, item := range body.SubDevices {
		device, ok := snapshot.DeviceByIdentity(item.Identity.ProductKey, item.Identity.DeviceName)
		if !ok {
			continue
		}
		reportTime := msg.ReportTime
		if item.Time != nil {
			reportTime = time.UnixMilli(*item.Time)
		}
		child := DeviceMessage{
			ID:         uuid.NewString(),
			ReportTime: reportTime,
			DeviceID:   device.ID,
			ServerID:   msg.ServerID,
			RequestID:  msg.RequestID + "-state-" + fmt.Sprint(device.ID),
			Method:     MethodStateUpdate,
			Params:     map[string]any{"state": item.State},
		}
		if err := p.deps.TD.InsertMessage(ctx, child, child.Identifier()); err != nil {
			return err
		}
		if err := UpdateDeviceReportState(ctx, p.deps.PG, device.ID, item.State, reportTime); err != nil {
			return err
		}
	}
	return nil
}

func (p *Processor) handleProperties(ctx context.Context, device Device, msg DeviceMessage) error {
	models := p.deps.Cache.Snapshot().ThingModels[device.ProductID]
	params := msg.ParamsMap()
	valid := make(map[string]any)
	for key, value := range params {
		model, ok := models[stringsLower(key)]
		if !ok {
			log.Printf("unknown property ignored: device=%d property=%s", device.ID, key)
			continue
		}
		valid[model.Identifier] = normalizePropertyValue(value, model)
	}
	if len(valid) == 0 {
		return nil
	}
	if err := p.deps.TD.InsertProperties(ctx, device, msg.ReportTime, valid, models); err != nil {
		return err
	}
	if err := UpdateRedisRuntime(ctx, p.deps.Redis, device, msg.ServerID, msg.ReportTime, valid); err != nil {
		return err
	}
	return p.executeDataRules(ctx, msg)
}

type subDeviceRegisterReq struct {
	ProductKey string `json:"productKey"`
	DeviceName string `json:"deviceName"`
}

func (p *Processor) handleSubDeviceRegister(ctx context.Context, gateway Device, msg DeviceMessage) (any, error) {
	if gateway.DeviceType != ProductDeviceTypeGateway {
		return nil, fmt.Errorf("device %d is not a gateway", gateway.ID)
	}
	raw, _ := json.Marshal(msg.Params)
	var reqs []subDeviceRegisterReq
	if err := json.Unmarshal(raw, &reqs); err != nil || len(reqs) == 0 {
		var wrapper struct {
			SubDevices []subDeviceRegisterReq `json:"subDevices"`
		}
		if err := json.Unmarshal(raw, &wrapper); err != nil {
			return nil, err
		}
		reqs = wrapper.SubDevices
	}
	if len(reqs) == 0 {
		return nil, errors.New("sub device register params is empty")
	}
	snapshot := p.deps.Cache.Snapshot()
	results := make([]map[string]any, 0, len(reqs))
	changed := false
	for _, req := range reqs {
		product, ok := snapshot.ProductsByKey[req.ProductKey]
		if !ok || product.DeviceType != ProductDeviceTypeGatewaySub {
			log.Printf("sub device register product skipped: productKey=%s", req.ProductKey)
			continue
		}
		device, ok := snapshot.DeviceByIdentity(req.ProductKey, req.DeviceName)
		if !ok {
			log.Printf("sub device register device not found: %s/%s", req.ProductKey, req.DeviceName)
			continue
		}
		if device.GatewayID != nil && *device.GatewayID != gateway.ID {
			log.Printf("sub device already belongs to another gateway: device=%d gateway=%d", device.ID, *device.GatewayID)
			continue
		}
		if device.GatewayID == nil {
			if err := UpdateDeviceGateway(ctx, p.deps.PG, device.ID, &gateway.ID); err != nil {
				return results, err
			}
			changed = true
		}
		results = append(results, registerResponse(device))
	}
	if changed {
		_ = p.deps.Cache.Reload(ctx)
	}
	return results, nil
}

func (p *Processor) handlePack(ctx context.Context, gateway Device, msg DeviceMessage) error {
	raw, _ := json.Marshal(msg.Params)
	var pack PackMessage
	if err := json.Unmarshal(raw, &pack); err != nil {
		return err
	}
	if len(pack.Properties) > 0 {
		child := msg
		child.ID = uuid.NewString()
		child.Method = MethodPropertyPost
		child.RequestID = msg.RequestID + "-gateway-properties"
		child.Params = pack.Properties
		if err := p.process(ctx, gateway, child, false); err != nil {
			return err
		}
	}
	for eventID, eventValue := range pack.Events {
		child := buildPackEventMessage(msg, gateway.ID, eventID, eventValue)
		if err := p.process(ctx, gateway, child, false); err != nil {
			return err
		}
	}
	snapshot := p.deps.Cache.Snapshot()
	for _, sub := range pack.SubDevices {
		device, ok := snapshot.DeviceByIdentity(sub.Identity.ProductKey, sub.Identity.DeviceName)
		if !ok {
			log.Printf("pack sub-device not found: %s/%s", sub.Identity.ProductKey, sub.Identity.DeviceName)
			continue
		}
		if len(sub.Properties) > 0 {
			child := msg
			child.ID = uuid.NewString()
			child.DeviceID = device.ID
			child.Method = MethodPropertyPost
			child.RequestID = msg.RequestID + "-sub-properties-" + fmt.Sprint(device.ID)
			child.Params = sub.Properties
			if err := p.process(ctx, device, child, false); err != nil {
				return err
			}
		}
		for eventID, eventValue := range sub.Events {
			child := buildPackEventMessage(msg, device.ID, eventID, eventValue)
			if err := p.process(ctx, device, child, false); err != nil {
				return err
			}
		}
	}
	return nil
}

func buildPackEventMessage(parent DeviceMessage, deviceID int64, eventID string, value PackEventValue) DeviceMessage {
	reportTime := parent.ReportTime
	if value.Time != nil {
		reportTime = time.UnixMilli(*value.Time)
	}
	return DeviceMessage{
		ID:         uuid.NewString(),
		ReportTime: reportTime,
		DeviceID:   deviceID,
		ServerID:   parent.ServerID,
		RequestID:  parent.RequestID + "-event-" + fmt.Sprint(deviceID) + "-" + eventID,
		Method:     MethodEventPost,
		Params: map[string]any{
			"identifier": eventID,
			"value":      value.Value,
			"time":       value.Time,
		},
	}
}

func (p *Processor) handleTopoAdd(ctx context.Context, gateway Device, msg DeviceMessage) (any, error) {
	raw, _ := json.Marshal(msg.Params)
	var body struct {
		SubDevices []struct {
			Username string `json:"username"`
			ClientID string `json:"clientId"`
			Password string `json:"password"`
		} `json:"subDevices"`
	}
	if err := json.Unmarshal(raw, &body); err != nil {
		return nil, err
	}
	added := make([]DeviceIdentity, 0)
	snapshot := p.deps.Cache.Snapshot()
	for _, sub := range body.SubDevices {
		productKey, deviceName, ok := parseUsername(sub.Username)
		if !ok {
			continue
		}
		device, ok := snapshot.DeviceByIdentity(productKey, deviceName)
		if !ok || !validateDevicePassword(device, sub.ClientID, sub.Username, sub.Password) {
			continue
		}
		if err := UpdateDeviceGateway(ctx, p.deps.PG, device.ID, &gateway.ID); err != nil {
			return added, err
		}
		added = append(added, DeviceIdentity{ProductKey: productKey, DeviceName: deviceName})
	}
	_ = p.deps.Cache.Reload(ctx)
	return map[string]any{"subDevices": added}, nil
}

func (p *Processor) handleTopoDelete(ctx context.Context, gateway Device, msg DeviceMessage) (any, error) {
	raw, _ := json.Marshal(msg.Params)
	var body struct {
		SubDevices []DeviceIdentity `json:"subDevices"`
	}
	if err := json.Unmarshal(raw, &body); err != nil {
		return nil, err
	}
	deleted := make([]DeviceIdentity, 0)
	snapshot := p.deps.Cache.Snapshot()
	for _, item := range body.SubDevices {
		device, ok := snapshot.DeviceByIdentity(item.ProductKey, item.DeviceName)
		if !ok || device.GatewayID == nil || *device.GatewayID != gateway.ID {
			continue
		}
		if err := UpdateDeviceGateway(ctx, p.deps.PG, device.ID, nil); err != nil {
			return deleted, err
		}
		deleted = append(deleted, item)
	}
	_ = p.deps.Cache.Reload(ctx)
	return map[string]any{"subDevices": deleted}, nil
}

func (p *Processor) handleTopoGet(ctx context.Context, gateway Device) (any, error) {
	rows, err := p.deps.PG.Query(ctx, `SELECT product_key, device_name FROM iot_device WHERE deleted = 0 AND gateway_id = $1`, gateway.ID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := make([]DeviceIdentity, 0)
	for rows.Next() {
		var item DeviceIdentity
		if err := rows.Scan(&item.ProductKey, &item.DeviceName); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return map[string]any{"subDevices": items}, rows.Err()
}

func (p *Processor) executeDataRules(ctx context.Context, msg DeviceMessage) error {
	snapshot := p.deps.Cache.Snapshot()
	device, _ := snapshot.DeviceByID(msg.DeviceID)
	identifiers := identifiersForRule(msg)
	processed := map[int64]struct{}{}
	for _, rule := range snapshot.DataRules {
		if rule.Status != StatusEnable || !ruleMatches(rule, msg, device, identifiers) {
			continue
		}
		for _, sinkID := range rule.SinkIDs {
			if _, ok := processed[sinkID]; ok {
				continue
			}
			processed[sinkID] = struct{}{}
			sink, ok := snapshot.DataSinks[sinkID]
			if !ok || sink.Status != StatusEnable {
				continue
			}
			if err := p.deps.Sinks.Execute(ctx, sink, msg); err != nil {
				log.Printf("database sink failed, enqueue retry: sink=%d msg=%s err=%v", sink.ID, msg.ID, err)
				_ = EnqueueRetry(ctx, p.deps.Redis, p.cfg.RetryStream, RetryPayload{SinkID: sink.ID, Message: msg, Attempt: 1, Error: err.Error()})
			}
		}
	}
	return nil
}

func (p *Processor) reply(ctx context.Context, device Device, request DeviceMessage, data any, err error) error {
	code := 0
	msg := "成功"
	if err != nil {
		code = 500
		msg = err.Error()
	}
	reply := DeviceMessage{
		ID:         uuid.NewString(),
		ReportTime: time.Now(),
		DeviceID:   device.ID,
		ServerID:   p.cfg.ServerID,
		RequestID:  request.RequestID,
		Method:     request.Method,
		Data:       data,
		Code:       &code,
		Msg:        msg,
	}
	if err := p.deps.TD.InsertMessage(ctx, reply, reply.Identifier()); err != nil {
		log.Printf("reply log insert failed: %v", err)
	}
	if p.pub == nil {
		return nil
	}
	payload, _ := json.Marshal(reply)
	return p.pub(BuildTopic(device.ProductKey, device.DeviceName, reply.Method, true), payload)
}

func (p *Processor) replyToIdentity(ctx context.Context, info TopicInfo, request DeviceMessage, data any, err error) error {
	code := 0
	message := "成功"
	if err != nil {
		code = 500
		message = err.Error()
	}
	reply := DeviceMessage{
		ID:         uuid.NewString(),
		ReportTime: time.Now(),
		ServerID:   p.cfg.ServerID,
		RequestID:  request.RequestID,
		Method:     request.Method,
		Data:       data,
		Code:       &code,
		Msg:        message,
	}
	if p.pub == nil {
		return nil
	}
	payload, _ := json.Marshal(reply)
	return p.pub(BuildTopic(info.ProductKey, info.DeviceName, reply.Method, true), payload)
}

func replyDisabled(method string) bool {
	return method == MethodStateUpdate || method == MethodOTAProgress
}

func identifiersForRule(msg DeviceMessage) []string {
	if msg.Method == MethodPropertyPost {
		return msg.PropertyIdentifiers()
	}
	if id := msg.Identifier(); id != "" {
		return []string{id}
	}
	return []string{""}
}

func ruleMatches(rule DataRule, msg DeviceMessage, device Device, identifiers []string) bool {
	for _, source := range rule.Sources {
		if source.Method != "" && source.Method != msg.Method {
			continue
		}
		if source.DeviceID != 0 && source.DeviceID != msg.DeviceID {
			continue
		}
		if source.ProductID != 0 && source.ProductID != device.ProductID {
			continue
		}
		if source.Identifier == "" {
			return true
		}
		for _, identifier := range identifiers {
			if source.Identifier == identifier {
				return true
			}
		}
	}
	return false
}

func normalizePropertyValue(value any, model ThingModel) any {
	if model.DataType == "array" || model.DataType == "struct" {
		return jsonCompact(value)
	}
	return value
}

func intFromAny(value any) int {
	switch v := value.(type) {
	case int:
		return v
	case int64:
		return int(v)
	case float64:
		return int(v)
	case json.Number:
		i, _ := v.Int64()
		return int(i)
	default:
		return 0
	}
}

func stringsLower(value string) string {
	for _, r := range value {
		if r >= 'A' && r <= 'Z' {
			return strings.ToLower(value)
		}
	}
	return value
}
