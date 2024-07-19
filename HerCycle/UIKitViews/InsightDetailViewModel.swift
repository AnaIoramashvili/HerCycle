//
//  InsightDetailViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/17/24.
//

import Foundation
import myNetworkPackage

class InsightsViewModel {
    private let networkService = NetworkService()
    private(set) var insights: [String: Insight] = [:]
    
    func fetchInsights(completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://hercycle-1376f-default-rtdb.firebaseio.com/Insights.json"
        
        networkService.getData(urlString: urlString) { (result: Result<InsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self.insights = response.insights
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getInsightTitles() -> [String] {
        return insights.keys.sorted()
    }
    
    func getInsight(for title: String) -> Insight? {
        return insights[title]
    }
}
