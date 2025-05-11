import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var transferCharacteristic: CBMutableCharacteristic!
    
    @Published var receivedData: String = "Waiting for data..."
    @Published var isAdvertising: Bool = false

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("BLE Server is powered on.")
            startAdvertising()
        } else {
            print("BLE Server is not available.")
            isAdvertising = false
        }
    }

    private func startAdvertising() {
        let serviceUUID = CBUUID(string: "FFF0")
        let characteristicUUID = CBUUID(string: "FFF1")

        transferCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [transferCharacteristic]

        peripheralManager.add(service)
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        isAdvertising = true

        print("Started advertising BLE service.")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value, request.characteristic.uuid == transferCharacteristic.uuid {
                let receivedString = String(data: value, encoding: .utf8) ?? "Invalid Data"
                DispatchQueue.main.async {
                    self.receivedData = receivedString
                }
                print("Received data: \(receivedString)")
            }
            peripheral.respond(to: request, withResult: .success)
        }
    }
}
