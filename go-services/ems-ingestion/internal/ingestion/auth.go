package ingestion

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"strings"

	"github.com/google/uuid"
)

const authTypeRegister = "|authType=register|"

func parseUsername(username string) (productKey string, deviceName string, ok bool) {
	parts := strings.Split(username, "&")
	if len(parts) != 2 || parts[0] == "" || parts[1] == "" {
		return "", "", false
	}
	return parts[1], parts[0], true
}

func buildClientID(productKey, deviceName string) string {
	return productKey + "." + deviceName
}

func buildPassword(deviceSecret, clientID, productKey, deviceName string) string {
	content := "clientId" + clientID +
		"deviceName" + deviceName +
		"deviceSecret" + deviceSecret +
		"productKey" + productKey
	mac := hmac.New(sha256.New, []byte(deviceSecret))
	_, _ = mac.Write([]byte(content))
	return hex.EncodeToString(mac.Sum(nil))
}

func buildProductSign(productKey, deviceName, productSecret string) string {
	content := "deviceName" + deviceName + "productKey" + productKey
	mac := hmac.New(sha256.New, []byte(productSecret))
	_, _ = mac.Write([]byte(content))
	return hex.EncodeToString(mac.Sum(nil))
}

func validateProductSign(product Product, deviceName, sign string) bool {
	expected := buildProductSign(product.ProductKey, deviceName, product.ProductSecret)
	return hmac.Equal([]byte(expected), []byte(sign))
}

func newDeviceSecret() string {
	return strings.ReplaceAll(uuid.NewString(), "-", "")
}

func validateDevicePassword(device Device, clientID, username, password string) bool {
	productKey, deviceName, ok := parseUsername(username)
	if !ok {
		return false
	}
	if productKey != device.ProductKey || deviceName != device.DeviceName {
		return false
	}
	if clientID == "" {
		clientID = buildClientID(productKey, deviceName)
	}
	expected := buildPassword(device.DeviceSecret, clientID, productKey, deviceName)
	return hmac.Equal([]byte(expected), []byte(password))
}

func topicAllowed(topic, productKey, deviceName string, subscribe bool) bool {
	prefix := "/sys/" + productKey + "/" + deviceName + "/"
	if subscribe {
		return strings.HasPrefix(topic, prefix) || topic == prefix+"#"
	}
	return !strings.ContainsAny(topic, "#+") && strings.HasPrefix(topic, prefix)
}
