import Foundation
import Combine

class SensorViewModel: ObservableObject {
    @Published var thresholds: [String: Double] = [
        "Temperature": 30.0,
        "PM2.5": 50.0,
        "UV": 8.0,
        "Pollen": 300.0,
        "Humidity": 70.0
    ]

    @Published var sensorData: [String: String] = [:]
    private var bluetoothManager: BluetoothManager
    private var cancellables = Set<AnyCancellable>()

    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager

        bluetoothManager.$receivedData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.parseSensorData(data)
            }
            .store(in: &cancellables)
    }

    private func parseSensorData(_ data: String) {
        let values = data.split(separator: ",").map { String($0) }
        if values.count == 5 {
            DispatchQueue.main.async {
                self.sensorData = [
                    "Temperature": values[0],
                    "PM2.5": values[1],
                    "UV": values[2],
                    "Pollen": values[3],
                    "Humidity": values[4]
                ]
            }
        }
    }
}
