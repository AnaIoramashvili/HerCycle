//
//  WeeksPodcastCell.swift
//  HerCycle
//
//  Created by Ana on 9/8/24.
//

import UIKit

final class WeeksPodcastCell: UICollectionViewCell {
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let innerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 1
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
        contentView.addSubview(coverImageView)
        contentView.addSubview(innerCardView)
        innerCardView.addSubview(titleLabel)
        innerCardView.addSubview(artistLabel)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            innerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            innerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            innerCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: innerCardView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: innerCardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: innerCardView.trailingAnchor, constant: -12),
            
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: innerCardView.leadingAnchor, constant: 12),
            artistLabel.trailingAnchor.constraint(equalTo: innerCardView.trailingAnchor, constant: -12),
            artistLabel.bottomAnchor.constraint(equalTo: innerCardView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with track: AudioTrack) {
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist
    }
}

