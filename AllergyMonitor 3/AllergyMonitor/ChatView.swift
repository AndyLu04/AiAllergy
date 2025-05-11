import SwiftUI

struct ChatView: View {
    @State private var userMessage: String = ""
    @AppStorage("chatMessage") private var chatMessage: String = ""
    @EnvironmentObject var viewModel: SensorViewModel

    var body: some View {
        VStack {
            HStack {
                TextField("Enter symptoms", text: $userMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Send") {
                    sendMessage()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 7)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            VStack(spacing: 15) {
                HStack {
                    Text("Allergen threshold:")
                        .font(.headline)
                    
                    Spacer()
                }
                
                HStack{
                    Text(chatMessage)
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .padding()
    }

    private func sendMessage() {
        let message = userMessage
        userMessage = ""

        Service.shared.sendMessage(message) { response in
            if let response = response {
                DispatchQueue.main.async {
                    chatMessage = response
                    updateThresholds(from: response)
                }
            }
        }
    }
    
    private func updateThresholds(from input: String) {
        let patterns: [String: String] = [
            "濕度: (\\d+)": "Humidity",
            "PM2\\.5: (\\d+)": "PM2.5",
            "花粉: (\\d+)": "Pollen",
            "溫度: (\\d+)": "Temperature",
            "紫外線: (\\d+)": "UV"
        ]

        for (pattern, key) in patterns {
            if let match = input.range(of: pattern, options: .regularExpression) {
                let valueString = input[match].split(separator: ":").last?.trimmingCharacters(in: .whitespaces) ?? "0"
                if let value = Double(valueString) {
                    viewModel.thresholds[key] = value
                }
            }
        }
    }
}
