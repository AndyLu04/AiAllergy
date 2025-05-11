import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack {
            Text("Received Data:")
                .font(.title)
                .padding()
            
            Text(bluetoothManager.receivedData)
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
        }
    }
}
