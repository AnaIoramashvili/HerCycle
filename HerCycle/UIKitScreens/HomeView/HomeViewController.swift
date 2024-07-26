//
//  HomeViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let insightsViewModel = InsightsViewModel()
    private var currentDate: Date = Date()
    private var dates: [Date] = []
    
    private var markedDays: [Date: CyclePhase] = [:]
    private let calendar = Calendar.current
    private let pmsColor = UIColor.systemBlue.withAlphaComponent(0.4)
    private let periodColor = UIColor.systemRed.withAlphaComponent(0.7)
    private let ovulationColor = UIColor.systemYellow
    
    var selectedDate: Date?
    private var daysUntilNextPeriod: Int = 0
    private var cycleProgress: CGFloat = 0.0
    private var updateTimer: Timer?
    
    private lazy var calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var periodTrackerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 90
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private lazy var outerRingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 6
        layer.lineCap = .round
        return layer
    }()
    
    private lazy var outerRingBackgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemGray4.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 6
        return layer
    }()
    
    private lazy var waveView: WaveView = {
        let view = WaveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var insightsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    private lazy var insightsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150)
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(InsightCell.self, forCellWithReuseIdentifier: InsightCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let insightTitles = ["Activity", "Medication", "Mood", "Notes", "Nutrition", "Sleep", "Symptoms", "Water"]
    private let insightColors: [UIColor] = [
        .primaryPink, .secondaryPink, .insightPink, .tertiaryPink,
        .primaryPink, .secondaryPink, .insightPink, .tertiaryPink
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mainBackgroundColor")
        generateDates()
        setupViews()
        setupConstraints()
        fetchInsights()
        updateMarkedDays()
        calculateCycleInfo()
        updatePeriodTrackerView()
        startPulsatingAnimation()

        
        DispatchQueue.main.async {
            self.calendarView.performBatchUpdates({
                let indexSet = IndexSet(integer: 0)
                self.calendarView.reloadSections(indexSet)
            }) { _ in
                self.scrollToCurrentDate()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = periodTrackerView.bounds
        
        let center = CGPoint(x: periodTrackerView.bounds.midX, y: periodTrackerView.bounds.midY)
        let radius = min(periodTrackerView.bounds.width, periodTrackerView.bounds.height) / 2 - 3
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        outerRingBackgroundLayer.path = circlePath.cgPath
        outerRingLayer.path = circlePath.cgPath
    }
    
    private func fetchInsights() {
        insightsViewModel.fetchInsights { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.insightsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching insights: \(error)")
            }
        }
    }
    
    private func setupViews() {
        setupNavigationBar()
        setupInsightsView()
        view.addSubview(calendarView)
        view.addSubview(periodTrackerView)
        view.addSubview(insightsView)
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    private func generateDates() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        guard let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) else { return }
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return }
        
        var date = startOfMonth
        while date <= endOfMonth {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
    }
    
    private func calculateCycleInfo() {
        guard let userData = authViewModel.userData else { return }
        
        let cycleLength = userData.cycleLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        let nextPeriodStartDate = calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate)!
        
        let today = Date()
        daysUntilNextPeriod = calendar.dateComponents([.day], from: today, to: nextPeriodStartDate).day ?? 0
        
        let daysSinceLastPeriod = calendar.dateComponents([.day], from: lastPeriodStartDate, to: today).day ?? 0
        cycleProgress = CGFloat(daysSinceLastPeriod) / CGFloat(cycleLength)
    }
    
    private func updatePeriodTrackerView() {
        let label = periodTrackerView.subviews.compactMap { $0 as? UILabel }.first { $0.text == "Period in" }
        let daysLabel = periodTrackerView.subviews.compactMap { $0 as? UILabel }.first { $0.text?.contains("Days") == true }
        
        label?.text = daysUntilNextPeriod == 0 ? "Period starts" : "Period in"
        daysLabel?.text = daysUntilNextPeriod == 0 ? "Today" : "\(daysUntilNextPeriod) Days"
        
        updateColors(days: daysUntilNextPeriod)
        updateOuterRingProgress(progress: cycleProgress, days: daysUntilNextPeriod)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUpdateTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdateTimer()
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.calculateCycleInfo()
            self?.updatePeriodTrackerView()
        }
    }
    
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func scrollToCurrentDate() {
        let calendar = Calendar.current
        guard let currentDateIndex = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: currentDate) }) else { return }
        let indexPath = IndexPath(item: max(0, currentDateIndex - 2), section: 0)
        calendarView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    private func setupConstraints() {
        setupCalendarViewConstraints()
        setupPeriodTrackerViewConstraints()
        setupInsightsViewConstraints()
        setupPeriodTrackerView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Welcome Back!"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = UIColor(named: "tertiaryPink")
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "How are you feeling today?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        subtitleLabel.textColor = UIColor(named: "tertiaryPink")
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCalendarViewConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    private func setupPeriodTrackerView() {
        periodTrackerView.layer.insertSublayer(gradientLayer, at: 0)
        periodTrackerView.layer.addSublayer(outerRingBackgroundLayer)
        periodTrackerView.layer.addSublayer(outerRingLayer)
        
        periodTrackerView.layer.shadowColor = UIColor.black.cgColor
        periodTrackerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        periodTrackerView.layer.shadowRadius = 10
        periodTrackerView.layer.shadowOpacity = 0.1
        
        let label: UILabel = {
            let label = UILabel()
            label.text = "Period in"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let daysLabel: UILabel = {
            let daysLabel = UILabel()
            daysLabel.text = "3 Days"
            daysLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            daysLabel.textColor = .white
            daysLabel.textAlignment = .center
            daysLabel.translatesAutoresizingMaskIntoConstraints = false
            return daysLabel
        }()
        
        periodTrackerView.addSubview(waveView)
        periodTrackerView.addSubview(label)
        periodTrackerView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            waveView.leadingAnchor.constraint(equalTo: periodTrackerView.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: periodTrackerView.trailingAnchor),
            waveView.bottomAnchor.constraint(equalTo: periodTrackerView.bottomAnchor),
            waveView.heightAnchor.constraint(equalTo: periodTrackerView.heightAnchor, multiplier: 0.5),
            
            label.centerXAnchor.constraint(equalTo: periodTrackerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: periodTrackerView.centerYAnchor, constant: -15),
            
            daysLabel.centerXAnchor.constraint(equalTo: periodTrackerView.centerXAnchor),
            daysLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5)
        ])
        
        startPulsatingAnimation()
        updateColors(days: 3)
        updateOuterRingProgress(progress: 0.75, days: 3)
    }
    
    private func setupPeriodTrackerViewConstraints() {
        NSLayoutConstraint.activate([
            periodTrackerView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            periodTrackerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            periodTrackerView.widthAnchor.constraint(equalToConstant: 180),
            periodTrackerView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func setupInsightsView() {
        let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.text = "My Daily Insights"
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            insightsView.addSubview(titleLabel)
            return titleLabel
        }()
        
        insightsView.addSubview(insightsCollectionView)
        insightsCollectionView.dataSource = self
        insightsCollectionView.delegate = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: insightsView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: insightsView.leadingAnchor),
            
            insightsCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            insightsCollectionView.leadingAnchor.constraint(equalTo: insightsView.leadingAnchor),
            insightsCollectionView.trailingAnchor.constraint(equalTo: insightsView.trailingAnchor),
            insightsCollectionView.bottomAnchor.constraint(equalTo: insightsView.bottomAnchor)
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
    
    private func startPulsatingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 0.98
        pulseAnimation.toValue = 1.02
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        periodTrackerView.layer.add(pulseAnimation, forKey: "pulsing")
    }
    
    private func updateColors(days: Int) {
        guard let userData = authViewModel.userData else { return }
        let cycleLength = userData.cycleLength
        
        let percentageOfCycle = Double(cycleLength - days) / Double(cycleLength)
        
        let startColor: UIColor
        let endColor: UIColor
        
        switch percentageOfCycle {
        case 0.9...1.0:  // Last 10% of cycle
            startColor = UIColor(named: "gradLightRed")!
            endColor = .tertiaryPink
        case 0.75..<0.9:  // 75-90% of cycle
            startColor = .tertiaryPink
            endColor = UIColor(named: "gradLightPurple")!
        case 0.5..<0.75:
            startColor = UIColor(named: "gradLightPurple")!
            endColor = UIColor(named: "gradDarkPurple")!
        default:  // First half of cycle
            startColor = .circleDefaultGrad
            endColor = .primaryPink
        }
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    private func updateOuterRingProgress(progress: CGFloat, days: Int) {
        let clampedProgress = min(max(progress, 0), 1)
        
        let center = CGPoint(x: periodTrackerView.bounds.midX, y: periodTrackerView.bounds.midY)
        let radius = min(periodTrackerView.bounds.width, periodTrackerView.bounds.height) / 2 - 3
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * clampedProgress
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        outerRingLayer.path = circlePath.cgPath
        
        let color = self.colorForDays(days)
        outerRingLayer.strokeColor = color.cgColor
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = outerRingLayer.presentation()?.strokeEnd ?? 0
        animation.toValue = clampedProgress
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        outerRingLayer.add(animation, forKey: "animateProgress")
        
        outerRingLayer.strokeEnd = clampedProgress
    }
    
    private func colorForDays(_ days: Int) -> UIColor {
        
        
        switch days {
        case 0...2:
            return .systemRed
        case 3...5:
            return .systemPink
        case 6...10:
            return .systemPurple
        case 11...20:
            return UIColor(named: "gradDarkRed")!
        default:
            return .systemGreen
        }
        
    }
    
    private func updateMarkedDays() {
        guard let userData = authViewModel.userData else { return }
        
        let cycleLength = userData.cycleLength
        let periodLength = userData.periodLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        markedDays.removeAll()
        
        let nextPeriodStartDate = calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate)!
        
        for day in 0..<periodLength {
            if let date = calendar.date(byAdding: .day, value: day, to: lastPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .period
            }
        }
        
        for day in 1...5 {
            if let pmsDate = calendar.date(byAdding: .day, value: -day, to: lastPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .pms
            }
        }
        
        for day in 1...5 {
            if let pmsDate = calendar.date(byAdding: .day, value: -day, to: nextPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .pms
            }
        }
        
        if let ovulationDate = calendar.date(byAdding: .day, value: -14, to: nextPeriodStartDate) {
            let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
            let normalizedDate = calendar.date(from: components)!
            markedDays[normalizedDate] = .ovulation
        }
        
        calendarView.reloadData()
    }
    
    func updateBackground(with theme: Theme) {
        view.backgroundColor = UIColor(patternImage: theme.image)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == calendarView ? dates.count : insightTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
            let date = dates[indexPath.item]
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayOfMonth = calendar.component(.day, from: date)
            let cyclePhase = markedDays[date]
            
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate ?? Date())
            
            cell.configure(day: daysOfWeek[dayOfWeek - 1], date: String(dayOfMonth), cyclePhase: cyclePhase, isSelected: isSelected)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsightCell.identifier, for: indexPath) as! InsightCell
            let iconNames = ["figure.walk", "pills", "face.smiling", "note.text", "fork.knife", "bed.double.fill", "bandage", "drop.fill"]
            cell.configure(with: insightTitles[indexPath.item], color: insightColors[indexPath.item], iconName: iconNames[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == calendarView, let cell = cell as? CalendarCell {
            let date = dates[indexPath.item]
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayOfMonth = calendar.component(.day, from: date)
            let cyclePhase = markedDays[date]
            
            let isSelected = (selectedDate == date)
            
            cell.configure(day: daysOfWeek[dayOfWeek - 1], date: String(dayOfMonth), cyclePhase: cyclePhase, isSelected: isSelected)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == calendarView {
            let width = collectionView.bounds.width / 6
            return CGSize(width: width - 8, height: 80)
        }
        return CGSize(width: 100, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == calendarView ? 8 : 15
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == insightsCollectionView {
            let titles = insightsViewModel.getInsightTitles()
            let title = titles[indexPath.item]
            if let insight = insightsViewModel.getInsight(for: title) {
                let detailVC = InsightDetailViewController(insight: insight, title: title)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}



