#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Pin definitions
#define DHTPIN 27        // DHT22 on GPIO27
#define DHTTYPE DHT22    
#define POTPIN 34        // Potentiometer on GPIO34
#define LED_YELLOW 26    // Yellow LED
#define LED_BLUE 25      // Blue LED
#define LIGHT_SENSOR_DO 23  // Light sensor Digital pin (DO)

// WiFi credentials
const char* ssid = "Wokwi-GUEST";
const char* password = "";

// ThingSpeak settings
String apiKey = "73054HYD33PZ95EP";
const char* server = "api.thingspeak.com";

// Initialize LCD (20x4 LCD with I2C adapter at address 0x27)
LiquidCrystal_I2C lcd(0x27, 20, 4);

// DHT sensor instance
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  
  // Initialize LCD
  Wire.begin();
  lcd.init();
  lcd.backlight();
  
  // Initialize pins
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);
  pinMode(LIGHT_SENSOR_DO, INPUT);
  
  // Initialize DHT sensor
  dht.begin();
  
  // Display connecting message
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Connecting to WiFi");
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  
  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    lcd.print(".");
  }
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("WiFi connected!");
  delay(2000);
}

void updateDisplay(float temperature, float humidity, float pressure, int lightLevel) {
  lcd.clear();
  
  // First line - Temperature
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temperature, 1);
  lcd.print("C");
  
  // Second line - Humidity
  lcd.setCursor(0, 1);
  lcd.print("Humidity: ");
  lcd.print(humidity, 1);
  lcd.print("%");
  
  // Third line - Pressure
  lcd.setCursor(0, 2);
  lcd.print("Press: ");
  lcd.print(pressure, 1);
  lcd.print(" mbar");
  
  // Fourth line - Light level
  lcd.setCursor(0, 3);
  lcd.print("Light: ");
  // Digital output is LOW when light is detected
  if (lightLevel == LOW) {
    lcd.print("Bright");
  } else {
    lcd.print("Dark");
  }
}

void loop() {
  // Read sensor values
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  int pressureRaw = analogRead(POTPIN);
  float pressure = map(pressureRaw, 0, 4095, 900, 1100);
  
  // Read light sensor digital value
  int lightLevel = digitalRead(LIGHT_SENSOR_DO);
  
  // LED control - LED ON when bright (lightLevel is LOW)
  digitalWrite(LED_YELLOW, !lightLevel);
  
  // Check if DHT readings failed
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Update LCD display
  updateDisplay(temperature, humidity, pressure, lightLevel);

  // Send data to ThingSpeak
  if(WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    
    String url = "http://api.thingspeak.com/update?api_key=" + apiKey;
    url += "&field1=" + String(temperature);
    url += "&field2=" + String(humidity);
    url += "&field3=" + String(pressure);
    url += "&field4=" + String(!lightLevel * 100); // Convert to 0 or 100 for better visualization
    
    http.begin(url);
    int httpCode = http.GET();
    
    if (httpCode > 0) {
      String payload = http.getString();
      Serial.println("ThingSpeak Update: " + payload);
      digitalWrite(LED_BLUE, HIGH);
      delay(100);
      digitalWrite(LED_BLUE, LOW);
    } else {
      Serial.println("Error on HTTP request");
    }
    
    http.end();
  }

  // Print values to Serial Monitor
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print("°C, Humidity: ");
  Serial.print(humidity);
  Serial.print("%, Pressure: ");
  Serial.print(pressure);
  Serial.print("mbar, Light: ");
  Serial.println(lightLevel == LOW ? "Bright" : "Dark");
  
  delay(15000);
}