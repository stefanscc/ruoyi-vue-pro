package ingestion

import (
	"context"
	"fmt"
	"log"
	"time"

	"ems-ingestion/internal/config"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type MQTTClient struct {
	cfg       config.Config
	processor *Processor
	client    mqtt.Client
}

func NewMQTTClient(cfg config.Config, processor *Processor) *MQTTClient {
	return &MQTTClient{cfg: cfg, processor: processor}
}

func (m *MQTTClient) Start(ctx context.Context) error {
	opts := mqtt.NewClientOptions()
	opts.AddBroker(m.cfg.MQTTBroker)
	opts.SetClientID(m.cfg.MQTTClientID)
	opts.SetUsername(m.cfg.MQTTUsername)
	opts.SetPassword(m.cfg.MQTTPassword)
	opts.SetCleanSession(m.cfg.MQTTCleanSession)
	opts.SetAutoReconnect(true)
	opts.SetConnectRetry(true)
	opts.SetKeepAlive(60 * time.Second)
	opts.SetOrderMatters(true)
	opts.SetConnectionLostHandler(func(_ mqtt.Client, err error) {
		log.Printf("MQTT connection lost: %v", err)
	})
	opts.SetOnConnectHandler(func(client mqtt.Client) {
		log.Printf("MQTT connected: broker=%s clientId=%s", m.cfg.MQTTBroker, m.cfg.MQTTClientID)
		for _, topic := range m.cfg.MQTTTopics {
			token := client.Subscribe(topic, m.cfg.MQTTQoS, func(_ mqtt.Client, message mqtt.Message) {
				if err := m.processor.ProcessMQTT(context.Background(), message.Topic(), message.Payload()); err != nil {
					log.Printf("MQTT message failed: topic=%s err=%v", message.Topic(), err)
				}
			})
			token.Wait()
			if err := token.Error(); err != nil {
				log.Printf("MQTT subscribe failed: topic=%s err=%v", topic, err)
			} else {
				log.Printf("MQTT subscribed: topic=%s qos=%d", topic, m.cfg.MQTTQoS)
			}
		}
	})
	m.client = mqtt.NewClient(opts)
	m.processor.SetPublisher(m.Publish)
	token := m.client.Connect()
	token.Wait()
	if err := token.Error(); err != nil {
		return err
	}
	<-ctx.Done()
	return nil
}

func (m *MQTTClient) Stop() {
	if m.client != nil && m.client.IsConnected() {
		m.client.Disconnect(5000)
	}
}

func (m *MQTTClient) Publish(topic string, payload []byte) error {
	if m.client == nil || !m.client.IsConnectionOpen() {
		return fmt.Errorf("MQTT client is not connected")
	}
	token := m.client.Publish(topic, m.cfg.MQTTQoS, false, payload)
	token.Wait()
	return token.Error()
}
