//
//  AppDelegate.swift
//  HerCycle
//
//  Created by Ana on 7/2/24.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Thread.sleep(forTimeInterval: 2)
        return true
    }
}
