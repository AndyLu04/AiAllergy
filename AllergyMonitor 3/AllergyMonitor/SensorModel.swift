import Foundation

struct SensorData {
    var uv: Double
    var temperature: Double
    var pm25: Double
    var pollen: Double
    var humidity: Double

    // 取得對應數值的函式
    func getValue(for key: String) -> Double {
        switch key {
        case "UV": return uv
        case "Temperature": return temperature
        case "PM2.5": return pm25
        case "Pollen": return pollen
        case "Humidity": return humidity
        default: return 0
        }
    }
}
