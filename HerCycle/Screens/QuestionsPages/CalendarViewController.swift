//
//  CalendarViewController.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import UIKit

class CalendarViewController: UIViewController {

    enum PeriodType {
        case period, fertile, ovulation
    }

    var collectionView: UICollectionView!
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    var daysInMonth: [Date] = []
    var markedDays: [Date: PeriodType] = [:]
    var selectedPeriodType: PeriodType?

    let headerView = UIView()
    let monthLabel = UILabel()
    let editButton = UIButton(type: .system)
    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)

    let periodButton = UIButton(type: .system)
    let fertileButton = UIButton(type: .system)
    let ovulationButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        dateComponents.year = 2024
        dateComponents.month = 7

        setupHeaderView()
        setupCollectionView()
        setupPeriodButtons()
        calculateDaysInMonth()
    }

    func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        monthLabel.text = monthYearString(from: Date())
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(monthLabel)

        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.backgroundColor = .blue
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 10
        headerView.addSubview(editButton)

        previousButton.setTitle("<", for: .normal)
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(previousButton)

        nextButton.setTitle(">", for: .normal)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            previousButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            previousButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            nextButton.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 20),
            nextButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")

        view.addSubview(collectionView)

        // Constraints for collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }

    func setupPeriodButtons() {
        let buttonStackView = UIStackView(arrangedSubviews: [periodButton, fertileButton, ovulationButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)

        periodButton.setTitle("Period", for: .normal)
        periodButton.backgroundColor = .red
        periodButton.setTitleColor(.white, for: .normal)
        periodButton.layer.cornerRadius = 15
        periodButton.addTarget(self, action: #selector(periodButtonTapped), for: .touchUpInside)

        fertileButton.setTitle("Fertile", for: .normal)
        fertileButton.backgroundColor = .purple
        fertileButton.setTitleColor(.white, for: .normal)
        fertileButton.layer.cornerRadius = 15
        fertileButton.addTarget(self, action: #selector(fertileButtonTapped), for: .touchUpInside)

        ovulationButton.setTitle("Ovulation", for: .normal)
        ovulationButton.backgroundColor = .blue
        ovulationButton.setTitleColor(.white, for: .normal)
        ovulationButton.layer.cornerRadius = 15
        ovulationButton.addTarget(self, action: #selector(ovulationButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func calculateDaysInMonth() {
        let startOfMonth = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        daysInMonth = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
        
        let startWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        daysInMonth.insert(contentsOf: Array(repeating: Date.distantPast, count: startWeekday), at: 0)
        
        collectionView.reloadData()
    }

    @objc func editTapped() {
        markedDays.removeAll()
        selectedPeriodType = nil
        collectionView.reloadData()
    }

    @objc func previousMonthTapped() {
        dateComponents.month! -= 1
        calculateDaysInMonth()
        monthLabel.text = monthYearString(from: calendar.date(from: dateComponents)!)
    }

    @objc func nextMonthTapped() {
        dateComponents.month! += 1
        calculateDaysInMonth()
        monthLabel.text = monthYearString(from: calendar.date(from: dateComponents)!)
    }

    @objc func periodButtonTapped() {
        selectedPeriodType = .period
    }

    @objc func fertileButtonTapped() {
        selectedPeriodType = .fertile
    }

    @objc func ovulationButtonTapped() {
        selectedPeriodType = .ovulation
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count + 7 // Adding 7 for the days of the week header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell

        if indexPath.item < 7 {
            // Configure days of the week header
            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            cell.label.text = days[indexPath.item]
            cell.label.font = UIFont.boldSystemFont(ofSize: 16)
        } else {
            // Configure calendar days
            let dayIndex = indexPath.item - 7
            if dayIndex < daysInMonth.count {
                let day = calendar.component(.day, from: daysInMonth[dayIndex])
                cell.label.text = daysInMonth[dayIndex].isValid ? "\(day)" : ""

                if let periodType = markedDays[daysInMonth[dayIndex]] {
                    cell.backgroundColor = getColorForPeriodType(periodType)
                } else {
                    cell.backgroundColor = .clear
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = collectionView.frame.height / 6
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayIndex = indexPath.item - 7
        if dayIndex < daysInMonth.count && daysInMonth[dayIndex].isValid {
            toggleMarkedDay(daysInMonth[dayIndex])
            collectionView.reloadItems(at: [indexPath])
        }
    }

    private func toggleMarkedDay(_ date: Date) {
        if let selectedType = selectedPeriodType {
            markedDays[date] = selectedType
        }
    }

    private func getColorForPeriodType(_ periodType: PeriodType) -> UIColor {
        switch periodType {
        case .period:
            return .red
        case .fertile:
            return .purple
        case .ovulation:
            return .blue
        }
    }
}

class CalendarCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.textAlignment = .center
        label.frame = contentView.bounds
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Date {
    var isValid: Bool {
        return self != Date.distantPast
    }
}



#Preview {
    CalendarViewController()
}
