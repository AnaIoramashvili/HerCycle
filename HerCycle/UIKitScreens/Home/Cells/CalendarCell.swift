//
//  CalendarCell.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    static let identifier = "CalendarCell"

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
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
        gradientLayer.removeFromSuperlayer()
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
        
        setDefaultAppearance()
        updateCellAppearance(cyclePhase: cyclePhase, isSelected: isSelected)
    }
    
    private func updateCellAppearance(cyclePhase: CyclePhase?, isSelected: Bool) {
        if isSelected {
            setupGradient(colors: [UIColor(named: "primaryPink")!,
                                   UIColor(named: "secondaryPink")!])
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            switch cyclePhase {
            case .pms:
                setupGradient(colors: [UIColor(named: "gradDarkRed")!.withAlphaComponent(0.6), UIColor.white])
            case .period:
                setupGradient(colors: [UIColor(named: "gradDarkRed")!.withAlphaComponent(0.6), UIColor.white])
            case .ovulation:
                setupGradient(colors: [UIColor.systemYellow.withAlphaComponent(0.6), UIColor.white])
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
        
        gradientLayer.frame = containerView.bounds
        
        if gradientLayer.superlayer == nil {
            containerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.cornerRadius = containerView.layer.cornerRadius
    }
}
