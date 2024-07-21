//
//  HomeViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let insightsViewModel = InsightsViewModel()

    private lazy var calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
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
    
    private lazy var bellButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(bellTapped))
        return button
    }()
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private var dates: [Date] = []
    
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
    
    private func generateDates() {
        let calendar = Calendar.current
        let today = Date()
        
        dates = (-3...3).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
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
        navigationItem.rightBarButtonItems = [bellButton]
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
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 100)
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
        let startColor: UIColor
        let endColor: UIColor

        switch days {
        case 0...2:
            startColor = .systemRed
            endColor = .systemPink
        case 3...5:
            startColor = .systemPink
            endColor = .systemPurple
        default:
            startColor = .systemPurple
            endColor = .systemBlue
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
    
    @objc private func bellTapped() {
        // Handle bell tap
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate for Calendar
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == calendarView ? dates.count : insightTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
            let date = dates[indexPath.item]
            let dayOfWeek = Calendar.current.component(.weekday, from: date)
            cell.configure(day: daysOfWeek[dayOfWeek - 1], date: String(Calendar.current.component(.day, from: date)))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as! InsightCell
            let iconNames = ["bed.double.fill", "figure.walk", "face.smiling", "fork.knife", "bandage", "drop.fill", "note.text", "pills"]
            cell.configure(with: insightTitles[indexPath.item], color: insightColors[indexPath.item], iconName: iconNames[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == calendarView {
            let width = collectionView.bounds.width / CGFloat(dates.count)
            return CGSize(width: width, height: collectionView.bounds.height)
        }
        return CGSize(width: 100, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == calendarView ? 0 : 15
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
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
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
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configure(day: String, date: String) {
        dayLabel.text = day
        dateLabel.text = date
    }
}

// MARK: - InsightCell
class InsightCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10)
        ])
    }
    
    func configure(with title: String, color: UIColor, iconName: String) {
        titleLabel.text = title
        contentView.backgroundColor = color
        iconImageView.image = UIImage(systemName: iconName)
    }
}

// MARK: - WaveView
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
