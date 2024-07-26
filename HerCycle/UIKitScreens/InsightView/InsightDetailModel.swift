//
//  InsightDetailModel.swift
//  HerCycle
//
//  Created by Ana on 7/17/24.
//

import Foundation

struct InsightsResponse: Codable {
    let insights: [String: Insight]
}

struct Insight: Codable {
    let articles: [Article]
    let image: String
    let information: String
    let tips: [String]
    let title: String
}

struct Article: Codable {
    let title: String
    let url: String
}
