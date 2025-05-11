import SwiftUI

@main
struct AllergyMonitorApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var sensorViewModel = SensorViewModel(bluetoothManager: BluetoothManager()) // ✅ 直接初始化

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sensorViewModel)
                .environmentObject(bluetoothManager)
        }
    }
}
