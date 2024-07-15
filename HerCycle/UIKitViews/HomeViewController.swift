//
//  HomeViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private lazy var calendarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "color4")
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var periodTrackerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 90
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemPink.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var insightsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bellButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(bellTapped))
        return button
    }()
    
    
    private lazy var daysOfWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    private lazy var dates: [String] = ["15", "16", "17", "18", "19", "20", "21"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        setupNavigationBar()
        setupCalendarView()
        setupPeriodTrackerView()
        setupInsightsView()
    }
    
    private func setupConstraints() {
        setupCalendarViewConstraints()
        setupPeriodTrackerViewConstraints()
        setupInsightsViewConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Welcome Back!"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [bellButton]
        navigationController?.navigationBar.tintColor = .systemPink
    }
    
    private func setupCalendarView() {
        view.addSubview(calendarView)
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            calendarView.addSubview(stackView)
            return stackView
        }()
        
        for (index, (day, date)) in zip(daysOfWeek, dates).enumerated() {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let dayLabel: UILabel = {
                let dayLabel = UILabel()
                dayLabel.text = day
                dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                dayLabel.textAlignment = .center
                dayLabel.translatesAutoresizingMaskIntoConstraints = false
                return dayLabel
            }()
            
            let dateLabel: UILabel = {
                let dateLabel = UILabel()
                dateLabel.text = date
                dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                dateLabel.textAlignment = .center
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                return dateLabel
            }()
            
            containerView.addSubview(dayLabel)
            containerView.addSubview(dateLabel)
            
            NSLayoutConstraint.activate([
                dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 17),
                dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                containerView.widthAnchor.constraint(equalToConstant: 30),
                containerView.heightAnchor.constraint(equalToConstant: 70)
            ])
            
            if index == 5 { 
                let backgroundView = UIView()
                backgroundView.backgroundColor = .systemPink
                backgroundView.layer.cornerRadius = 15
                backgroundView.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.insertSubview(backgroundView, at: 0)
                
                NSLayoutConstraint.activate([
                    backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -5),
                    backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -5),
                    backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 5),
                    backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 5)
                ])
                
                dayLabel.textColor = .white
                dateLabel.textColor = .white
            }
            
            stackView.addArrangedSubview(containerView)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupCalendarViewConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupPeriodTrackerView() {
        view.addSubview(periodTrackerView)
        
        let label: UILabel = {
            let label = UILabel()
            label.text = "Period in"
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let daysLabel: UILabel = {
            let daysLabel = UILabel()
            daysLabel.text = "3 Days"
            daysLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            daysLabel.textColor = .systemPink
            daysLabel.textAlignment = .center
            daysLabel.translatesAutoresizingMaskIntoConstraints = false
            return daysLabel
        }()
        
        periodTrackerView.addSubview(label)
        periodTrackerView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: periodTrackerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: periodTrackerView.centerYAnchor, constant: -15),
            
            daysLabel.centerXAnchor.constraint(equalTo: periodTrackerView.centerXAnchor),
            daysLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5)
        ])
    }
    
    private func setupPeriodTrackerViewConstraints() {
        NSLayoutConstraint.activate([
            periodTrackerView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 30),
            periodTrackerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            periodTrackerView.widthAnchor.constraint(equalToConstant: 180),
            periodTrackerView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func setupInsightsView() {
        view.addSubview(insightsView)
        
        let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.text = "My Daily Insights"
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            insightsView.addSubview(titleLabel)
            return titleLabel
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 15
            stackView.translatesAutoresizingMaskIntoConstraints = false
            insightsView.addSubview(stackView)
            return stackView
        }()
        
        let colors: [UIColor] = [.systemGray4, .systemYellow, .systemPurple]
        let titles = ["Sleep", "Activity", "Mood"]
        
        for (color, title) in zip(colors, titles) {
            let insightView = UIView()
            insightView.backgroundColor = color
            insightView.layer.cornerRadius = 15
            
            let label = UILabel()
            label.text = title
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            insightView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: insightView.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: insightView.bottomAnchor, constant: -10)
            ])
            
            stackView.addArrangedSubview(insightView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: insightsView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: insightsView.leadingAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: insightsView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: insightsView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: insightsView.bottomAnchor)
        ])
    }
    
    private func setupInsightsViewConstraints() {
        NSLayoutConstraint.activate([
            insightsView.topAnchor.constraint(equalTo: periodTrackerView.bottomAnchor, constant: 30),
            insightsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            insightsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            insightsView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func bellTapped() {
    }
    
    @objc private func calendarTapped() {
    }
}
