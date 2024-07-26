//
//  ChatViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/16/24.
//

import Foundation

final class ChatViewModel {
    private let apiKey = "sk-proj-gKisHXSQ1fTPOxFjo3VLT3BlbkFJPIHRBeYBtUGBdhH7mtte"
    var messages: [Message] = []
    
    var didUpdateMessages: (() -> Void)?
    
    func sendMessage(_ text: String) {
        let message = Message(role: "user", content: text)
        messages.append(message)
        didUpdateMessages?()
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Failed to serialize JSON")
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
                
                guard (200...299).contains(response.statusCode) else {
                    print("Wrong response or status code")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseBody)")
                    }
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ChatResponse.self, from: data)
                if let reply = response.choices.first?.message {
                    self?.messages.append(reply)
                    DispatchQueue.main.async {
                        self?.didUpdateMessages?()
                    }
                }
            } catch {
                print("Decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
