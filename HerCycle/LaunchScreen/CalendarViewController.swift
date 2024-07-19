//
//  CalendarViewController.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import UIKit
import SwiftUI

class CalendarViewController: UIViewController {
    
    private var calendarHostingController: CalendarHostingController!
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
        
        view.backgroundColor = .white
        
        setupCalendarHostingController()
    }
    
    private func setupCalendarHostingController() {
        calendarHostingController = CalendarHostingController(authViewModel: authViewModel)
        
        addChild(calendarHostingController)
        view.addSubview(calendarHostingController.view)
        calendarHostingController.didMove(toParent: self)
        
        calendarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarHostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
