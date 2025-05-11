import Foundation

class Service {
    static let shared = Service()

    private let apiKey = "apiKey"
    private let url = URL(string: "https://free.v36.cm/v1/chat/completions")!

    func sendMessage(_ message: String, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": "我的過敏症狀有" + message + "\n請給我個數據的臨界值，超過臨界值我就可能會過敏，並依照以下格式回覆\n濕度: XX\nPM2.5: XX\n花粉: XX\n溫度: XX\n紫外線: XX\n請務必按照此格式回覆，且後面不要有單位，此格式換兩行後可以給予文字建議"]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatResponse.self, from: data)
                let message = response.choices.first?.message.content
                completion(message)
            } catch {
                print("Error decoding response: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

struct ChatResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: ChatMessage
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}
