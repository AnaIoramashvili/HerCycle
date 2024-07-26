//
//  RatingManager.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import Foundation

class RatingManager {
    static let shared = RatingManager()
    
    private let userDefaults = UserDefaults.standard
    private let ratingsKey = "userRatings"
    
    private init() {}
    
    func saveRating(_ rating: Rating) {
        var ratings = getRatings()
        ratings.append(rating)
        
        if let encoded = try? JSONEncoder().encode(ratings) {
            userDefaults.set(encoded, forKey: ratingsKey)
        }
    }
    
    func getRatings() -> [Rating] {
        if let savedRatings = userDefaults.object(forKey: ratingsKey) as? Data {
            if let loadedRatings = try? JSONDecoder().decode([Rating].self, from: savedRatings) {
                return loadedRatings
            }
        }
        return []
    }
}
