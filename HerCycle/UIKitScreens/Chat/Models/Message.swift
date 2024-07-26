//
//  Message.swift
//  HerCycle
//
//  Created by Ana on 7/16/24.
//

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    let choices: [Choice]
}
