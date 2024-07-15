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
    private var selectedDate = Date()
    private var markedDays: [Date: PeriodType] = [:]
    private var selectedPeriodType: PeriodType?
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background
        
        setupCalendarHostingController()
        setupEditButton()
    }
    
    private func setupCalendarHostingController() {
        calendarHostingController = CalendarHostingController(
            selectedDate: Binding(
                get: { self.selectedDate },
                set: { self.selectedDate = $0 }
            ),
            markedDays: Binding(
                get: { self.markedDays },
                set: { self.markedDays = $0 }
            ),
            selectedPeriodType: Binding(
                get: { self.selectedPeriodType },
                set: { self.selectedPeriodType = $0 }
            )
        )
        
        calendarHostingController.view.backgroundColor = .clear

        
        calendarHostingController.onPreviousMonth = { [weak self] in
            self?.previousMonth()
        }
        
        calendarHostingController.onNextMonth = { [weak self] in
            self?.nextMonth()
        }
        
        calendarHostingController.onDaySelected = { [weak self] date in
            self?.toggleMarkedDay(date)
        }
        
        addChild(calendarHostingController)
        view.addSubview(calendarHostingController.view)
        calendarHostingController.didMove(toParent: self)
        
        calendarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarHostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            calendarHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEditButton() {
        view.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func editButtonTapped() {
        markedDays.removeAll()
        selectedPeriodType = nil
        updateCalendarView()
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        updateCalendarView()
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        updateCalendarView()
    }
    
    private func toggleMarkedDay(_ date: Date) {
        if let selectedType = selectedPeriodType {
            markedDays[date] = selectedType
        }
        updateCalendarView()
    }
    
    private func updateCalendarView() {
        calendarHostingController.rootView = CalendarView(
            selectedDate: Binding(
                get: { self.selectedDate },
                set: { self.selectedDate = $0 }
            ),
            markedDays: Binding(
                get: { self.markedDays },
                set: { self.markedDays = $0 }
            ),
            selectedPeriodType: Binding(
                get: { self.selectedPeriodType },
                set: { self.selectedPeriodType = $0 }
            ),
            onPreviousMonth: { [weak self] in self?.previousMonth() },
            onNextMonth: { [weak self] in self?.nextMonth() },
            onDaySelected: { [weak self] date in self?.toggleMarkedDay(date) }
        )
    }
}
