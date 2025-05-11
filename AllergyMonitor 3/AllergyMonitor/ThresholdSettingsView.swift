import SwiftUI

struct ThresholdSettingsView: View {
    @EnvironmentObject var viewModel: SensorViewModel
    @Environment(\.presentationMode) var presentationMode

    let sensorUnits: [String: String] = [
        "UV": "", "Temperature": "°C", "PM2.5": "µg/m³", "Pollen": "P/m³", "Humidity": "%"
    ]

    var body: some View {
        VStack {
            Text("Set excessive value")
                .font(.largeTitle)
                .bold()
                .padding()

            Form {
                ForEach(viewModel.thresholds.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text("\(key):")
                            .frame(width: 120, alignment: .leading)
                            .font(.headline)

                        Spacer()

                        TextField("Enter value", value: Binding(
                            get: { viewModel.thresholds[key] ?? 0 },
                            set: { viewModel.thresholds[key] = $0 }
                        ), formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 90)
                        .keyboardType(.decimalPad)

                        Text(sensorUnits[key] ?? "")
                            .frame(width: 60, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                }
            }

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save settings")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
