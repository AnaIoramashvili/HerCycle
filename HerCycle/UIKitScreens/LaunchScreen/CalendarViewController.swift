//
//  CalendarViewController.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import UIKit
import SwiftUI

class CalendarViewController: UIViewController {
    private var calendarHostingController: UIHostingController<AnyView>?
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarHostingController()
    }
    
    private func setupCalendarHostingController() {
        let calendarView = CalendarView().environmentObject(authViewModel)
        calendarHostingController = UIHostingController(rootView: AnyView(calendarView))
        
        if let hostingController = calendarHostingController {
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    func updateTheme(_ theme: Theme) {
        ThemeManager.shared.saveSelectedTheme(theme)
        if let hostingController = calendarHostingController {
            hostingController.rootView = AnyView(
                CalendarView()
                    .environmentObject(authViewModel)
            )
        }
    }
}
