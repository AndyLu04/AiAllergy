#include <SoftwareSerial.h>
#include "PMS.h"
#include <DHT22.h>

// === DHT22 溫濕度感測器 ===
#define DHT_PIN SDA // 可更改其他 I/O 腳位
DHT22 dht22(DHT_PIN);

// === PMS5003T 空氣品質感測器 ===
#define PMS_TX_PIN 3 // PMS5003T TX 連到 D3
#define PMS_RX_PIN 4 // PMS5003T RX 連到 D4

SoftwareSerial pmsSerial(PMS_RX_PIN, PMS_TX_PIN);
PMS pms(pmsSerial);
PMS::DATA data;

// === HC-08 藍牙模組 ===
#define HC08_TX_PIN 5 // HC-08 TX 連到 Arduino D5
#define HC08_RX_PIN 6 // HC-08 RX 連到 Arduino D6

SoftwareSerial hc08Serial(HC08_RX_PIN, HC08_TX_PIN);

// === UV 感測器 ===
#define UVOUT A0   // UV 輸出腳位
#define REF_3V3 A1 // 3.3V 參考腳位

// === 計時變數 ===
unsigned long lastDHT_Time = 0;
unsigned long lastPMS_Time = 0;
unsigned long lastUV_Time = 0;
const unsigned long dht_interval = 5000; // 10 秒更新一次 DHT22
const unsigned long pms_interval = 5000; // 30 秒更新一次 PMS5003T
const unsigned long uv_interval = 5000;  // 15 秒更新一次 UV 感測器

void setup() {
  Serial.begin(9600);
  Serial.println("\n=== 初始化感測器 ===");

  // 初始化 DHT22
  Serial.println("初始化 DHT22...");

  // 初始化 PMS5003T
  pmsSerial.begin(9600);
  Serial.println("初始化 PMS5003T...");
  pms.passiveMode(); // 設為被動模式

  // 初始化 HC-08 藍牙
  hc08Serial.begin(115200);
  Serial.println("初始化 HC-08...");
}

void loop() {
  unsigned long currentMillis = millis();

  // === 每 10 秒更新 DHT22 ===
  if (currentMillis - lastDHT_Time >= dht_interval) {
    lastDHT_Time = currentMillis;
    readDHT22();
  }

  // === 每 30 秒更新 PMS5003T ===
  if (currentMillis - lastPMS_Time >= pms_interval) {
    lastPMS_Time = currentMillis;
    readPMS5003T();
  }

  // === 每 15 秒更新 UV 感測器 ===
  if (currentMillis - lastUV_Time >= uv_interval) {
    lastUV_Time = currentMillis;
    readUVSensor();
  }

  // === 檢查 HC-08 是否有來自手機或藍牙設備的數據 ===
  if (hc08Serial.available()) {
    String command = hc08Serial.readStringUntil('\n'); // 讀取一行數據
    Serial.print("[HC-08] 接收到命令: ");
    Serial.println(command);
  }
}

// === 讀取 DHT22 溫濕度數據 ===
void readDHT22() {
  Serial.println("\n[📡 DHT22 讀取數據]");

  float temperature = dht22.getTemperature();
  float humidity = dht22.getHumidity();

  if (dht22.getLastError() != dht22.OK) {
    Serial.print("DHT22 錯誤碼: ");
    Serial.println(dht22.getLastError());
  } else {
    Serial.print("🌡 溫度: "); Serial.print(temperature, 1); Serial.print("°C\t");
    Serial.print("💧 濕度: "); Serial.print(humidity, 1); Serial.println("%");

    // 將數據傳送到 HC-08
    hc08Serial.print("DHT22 溫度: "); hc08Serial.print(temperature, 1); hc08Serial.print("°C ");
    hc08Serial.print("濕度: "); hc08Serial.print(humidity, 1); hc08Serial.println("%");
  }
}

// === 讀取 PMS5003T 空氣品質數據 ===
void readPMS5003T() {
  Serial.println("\n[💨 PMS5003T 讀取 PM2.5 數據]");

  pmsSerial.listen(); // 確保 PMS5003T 的 SoftwareSerial 被啟動
  delay(100);

  Serial.println("🟢 喚醒 PMS5003T，等待 30 秒...");
  // pms.wakeUp();
  // delay(30000);

  Serial.println("📡 發送讀取請求...");
  pms.requestRead();

  if (pms.readUntil(data)) {
    Serial.print("🌫 PM 1.0 (ug/m3): ");
    Serial.println(data.PM_AE_UG_1_0);

    Serial.print("🌫 PM 2.5 : (ug/m3)");
    Serial.println(data.PM_AE_UG_2_5);

    Serial.print("🌫 PM 10.0 (ug/m3): ");
    Serial.println(data.PM_AE_UG_10_0);

    hc08Serial.print("PM2.5: "); hc08Serial.print(data.PM_AE_UG_2_5); hc08Serial.println("(ug/m3)");
  } else {
    Serial.println("❌ PMS5003T 無數據。");
    hc08Serial.print("PM2.5: ❌ PMS5003T 無數據。");
  }
  // pms.sleep();
}

// === 讀取 UV 感測器 ===
void readUVSensor() {
  Serial.println("\n[🌞 UV 感測器 讀取數據]");

  int uvLevel = analogRead(UVOUT);
  int refLevel = analogRead(REF_3V3);
  float outputVoltage = 3.3 / refLevel * uvLevel;
  float uvIntensity = map(outputVoltage, 0.99, 2.9, 0.0, 15.0);

  Serial.print("🔆 UV 感測值: "); Serial.print(uvLevel);
  Serial.print(" ⚡ UV 電壓: "); Serial.print(outputVoltage, 2);
  Serial.print(" 🌍 UV 強度 (mW/cm^2): "); Serial.println(uvIntensity);
  hc08Serial.print(" 🌍 UV 強度: "); hc08Serial.print(uvIntensity); hc08Serial.println("(mW/cm^2)");
}
