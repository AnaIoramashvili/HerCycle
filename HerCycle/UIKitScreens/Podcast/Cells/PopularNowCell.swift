//
//  PopularNowCell.swift
//  HerCycle
//
//  Created by Ana on 9/10/24.
//

import UIKit

final class PopularNowCell: UICollectionViewCell {
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.4)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryPurple
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(coverImageView)
        backgroundCardView.addSubview(titleLabel)
        backgroundCardView.addSubview(durationLabel)
        backgroundCardView.addSubview(playButtonContainer)
        playButtonContainer.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 100),

            
            coverImageView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 8),
            coverImageView.centerYAnchor.constraint(equalTo: backgroundCardView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 80),
            coverImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -8),
            
            durationLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            durationLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -8),
            
            playButtonContainer.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            playButtonContainer.centerYAnchor.constraint(equalTo: backgroundCardView.centerYAnchor),
            playButtonContainer.widthAnchor.constraint(equalToConstant: 30),
            playButtonContainer.heightAnchor.constraint(equalToConstant: 30),
            
            playButton.centerXAnchor.constraint(equalTo: playButtonContainer.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: playButtonContainer.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 15),
            playButton.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func configure(with track: AudioTrack) {
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        durationLabel.text = formatDuration(track.duration)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


