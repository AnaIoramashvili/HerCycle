//
//  ThemeManager.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import Foundation

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme?
    
    private let defaults = UserDefaults.standard
    private let selectedThemeKey = "SelectedTheme"
    
    private init() {
        currentTheme = getSelectedTheme()
    }
    
    let defaultTheme = Theme(name: "Default", imageName: "")
    
    func saveSelectedTheme(_ theme: Theme) {
        defaults.set(theme.name, forKey: selectedThemeKey)
        currentTheme = theme
    }
    
    func getSelectedTheme() -> Theme? {
        guard let themeName = defaults.string(forKey: selectedThemeKey) else { return nil }
        return allThemes.first { $0.name == themeName }
    }
    
    let allThemes: [Theme] = [
        Theme(name: "Default", imageName: "mainBackgroundColorImage"),
        Theme(name: "Aura", imageName: "auraBackground"),
        Theme(name: "Heart", imageName: "heartBackground"),
        Theme(name: "Sea", imageName: "seaBackground"),
        Theme(name: "Flowers", imageName: "flowersBackground"),
        Theme(name: "Fun", imageName: "funBackground"),
        Theme(name: "Blue Aura", imageName: "blueAuraBackrground"),
        Theme(name: "Lemons", imageName: "lemonBackground"),
        Theme(name: "Sparckles", imageName: "sparcklesBackground"),
    ]
}
