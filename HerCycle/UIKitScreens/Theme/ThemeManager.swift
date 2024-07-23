//
//  ThemeManager.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import Foundation

class ThemeManager {
    static let shared = ThemeManager()
    
    private let defaults = UserDefaults.standard
    private let selectedThemeKey = "SelectedTheme"
    
    private init() {}
    
    func saveSelectedTheme(_ theme: Theme) {
        defaults.set(theme.name, forKey: selectedThemeKey)
    }
    
    func getSelectedTheme() -> Theme? {
        guard let themeName = defaults.string(forKey: selectedThemeKey) else { return nil }
        return allThemes.first { $0.name == themeName }
    }
    
    let allThemes: [Theme] = [
        Theme(name: "Flower", imageName: "flowerBackground"),
        Theme(name: "Aura", imageName: "auraBackground"),
        Theme(name: "Heart", imageName: "heartBackground"),
        Theme(name: "Sea", imageName: "seaBackground"),
        Theme(name: "Flowers", imageName: "flowersBackground"),
        Theme(name: "Bows", imageName: "bowsBackground")
    ]
}
