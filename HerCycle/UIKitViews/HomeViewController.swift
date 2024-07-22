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
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
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
        collectionView.register(InsightCell.self, forCellWithReuseIdentifier: "InsightCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let insightTitles = ["Activity", "Medication", "Mood", "Notes", "Nutrition", "Sleep", "Symptoms", "Water"]
    private let insightColors: [UIColor] = [
        .color1, .color2, .color5, .color6,
        .color1, .color2, .color5, .color6
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")
        generateDates()
        setupViews()
        setupConstraints()
        fetchInsights()
        updateMarkedDays()
        calculateCycleInfo()
        updatePeriodTrackerView()
        
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
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
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
        
        let calendar = Calendar.current
        let today = Date()
        let lastPeriodStartDate = userData.lastPeriodStartDate
        let cycleLength = userData.cycleLength
        
        // Calculate the start date of the next period
        let nextPeriodStartDate = calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate)!
        
        // Calculate days until next period
        daysUntilNextPeriod = calendar.dateComponents([.day], from: today, to: nextPeriodStartDate).day ?? 0
        
        // Calculate cycle progress
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
        let indexPath = IndexPath(item: max(0, currentDateIndex - 2), section: 0) // 2 days before current date
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
        navigationController?.navigationBar.tintColor = .color6
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "How are you feeling today?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        subtitleLabel.textColor = .color6
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
            startColor = .systemRed
            endColor = .systemPink
        case 0.75..<0.9:  // 75-90% of cycle
            startColor = .systemPink
            endColor = .systemPurple
        case 0.5..<0.75:
            startColor = .systemPurple
            endColor = .systemBlue
        default:  // First half of cycle
            startColor = .systemBlue
            endColor = .systemTeal
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
            return .systemBlue
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
        
        var currentPeriodStart = lastPeriodStartDate
        let endDate = calendar.date(byAdding: .year, value: 2, to: Date())!
        
        while currentPeriodStart <= endDate {
            for day in 0..<periodLength {
                if let date = calendar.date(byAdding: .day, value: day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .period
                }
            }
            
            if let ovulationDate = calendar.date(byAdding: .day, value: cycleLength - 14, to: currentPeriodStart) {
                let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .ovulation
            }
            
            for day in 1...5 {
                if let pmsDate = calendar.date(byAdding: .day, value: -day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .pms
                }
            }
            
            currentPeriodStart = calendar.date(byAdding: .day, value: cycleLength, to: currentPeriodStart)!
        }
        calendarView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == calendarView ? dates.count : insightTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
            let date = dates[indexPath.item]
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayOfMonth = calendar.component(.day, from: date)
            let cyclePhase = markedDays[date]
            
            let isSelected = (selectedDate == date)
            
            cell.configure(day: daysOfWeek[dayOfWeek - 1], date: String(dayOfMonth), cyclePhase: cyclePhase, isSelected: isSelected)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as! InsightCell
            let iconNames = ["bed.double.fill", "figure.walk", "face.smiling", "fork.knife", "bandage", "drop.fill", "note.text", "pills"]
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
            let width = collectionView.bounds.width / 6 // Show 5 days at a time
            return CGSize(width: width - 8, height: 80) // Subtract 8 for spacing
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
// MARK: - CalendarCell
class CalendarCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24 // Adjust for desired pill shape
        view.clipsToBounds = true
        return view
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setDefaultAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(dayLabel)
        containerView.addSubview(dateLabel)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setDefaultAppearance() {
        containerView.backgroundColor = .white
        dayLabel.textColor = .black
        dateLabel.textColor = .black
        gradientLayer.removeFromSuperlayer() // Remove any existing gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultAppearance()
    }
    
    func configure(day: String, date: String, cyclePhase: CyclePhase?, isSelected: Bool) {
        dayLabel.text = day
        dateLabel.text = date
        
        setDefaultAppearance() // Reset to default before applying specific styling
        updateCellAppearance(cyclePhase: cyclePhase, isSelected: isSelected)
    }
    
    private func updateCellAppearance(cyclePhase: CyclePhase?, isSelected: Bool) {
        if isSelected {
            setupGradient(colors: [UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0),
                                   UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0)])
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            switch cyclePhase {
            case .pms:
                setupGradient(colors: [UIColor.systemBlue.withAlphaComponent(0.3), UIColor.systemBlue.withAlphaComponent(0.6)])
            case .period:
                setupGradient(colors: [UIColor.systemRed.withAlphaComponent(0.5), UIColor.systemRed.withAlphaComponent(0.8)])
            case .ovulation:
                setupGradient(colors: [UIColor.systemYellow.withAlphaComponent(0.3), UIColor.systemYellow.withAlphaComponent(0.6)])
            case .none:
                setDefaultAppearance()
            }
        }
    }
    
    private func setupGradient(colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0, 1]
        
        // Ensure the gradient layer covers the entire cell
        gradientLayer.frame = containerView.bounds
        
        // Add the gradient layer if it's not already added
        if gradientLayer.superlayer == nil {
            containerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Apply corner radius to match the cell's rounded corners
        gradientLayer.cornerRadius = containerView.layer.cornerRadius
    }
}


class InsightCell: UICollectionViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with title: String, color: UIColor, iconName: String) {
        titleLabel.text = title
        contentView.backgroundColor = color
        contentView.layer.cornerRadius = 15
        iconImageView.image = UIImage(systemName: iconName)
    }
}


class WaveView: UIView {
    private var waveLayer: CAShapeLayer!
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        waveLayer = CAShapeLayer()
        waveLayer.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        layer.addSublayer(waveLayer)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func updateWave() {
        if startTime == nil {
            startTime = CACurrentMediaTime()
        }
        
        let elapsed = CACurrentMediaTime() - startTime!
        let phase = CGFloat(elapsed) * 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height))
        
        for x in stride(from: 0, to: bounds.width, by: 1) {
            let relativeX = x / bounds.width
            let sine = sin(relativeX * 4 * .pi + phase)
            let y = bounds.height * 0.5 + sine * 10
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.close()
        
        waveLayer.path = path.cgPath
    }
}
