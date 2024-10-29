//
//  AudioPlayerViewController.swift
//  HerCycle
//
//  Created by Ana on 9/8/24.
//

import UIKit

final class AudioPlayerViewController: UIViewController {
    
    private let viewModel: AudioPlayerViewModel
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemBlue
        slider.maximumTrackTintColor = .darkGray
        slider.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50)), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var updateTimer: Timer?
    
    init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
        setupActions()
        startUpdateTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(containerView)
        
        containerView.addSubview(coverImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)
        containerView.addSubview(progressSlider)
        containerView.addSubview(currentTimeLabel)
        containerView.addSubview(totalTimeLabel)
        containerView.addSubview(playPauseButton)
        containerView.addSubview(previousButton)
        containerView.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            coverImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            coverImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            coverImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            progressSlider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            progressSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 8),
            
            totalTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 8),
            
            playPauseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 20),
            
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor)
        ])
    
    }
    
    private func configureUI() {
        let track = viewModel.track
        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(named: track.coverImageName)
        backgroundImageView.image = UIImage(named: track.coverImageName)
        
        updateTimeLabels()
        updatePlayPauseButton()
    }
    
    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        progressSlider.value = viewModel.progress
        updateTimeLabels()
    }
    
    private func updateTimeLabels() {
        currentTimeLabel.text = formatTime(viewModel.currentTime)
        totalTimeLabel.text = formatTime(viewModel.duration)
    }
    
    private func updatePlayPauseButton() {
        let imageName = viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playPauseButton.setImage(UIImage(systemName: imageName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50)), for: .normal)
    }
    
    @objc private func playPauseTapped() {
        if viewModel.isPlaying {
            viewModel.pause()
        } else {
            viewModel.play()
        }
        updatePlayPauseButton()
    }
    
    @objc private func previousTapped() {
        viewModel.playPreviousTrack()
        configureUI()
    }
    
    @objc private func nextTapped() {
        viewModel.playNextTrack()
        configureUI()
    }
    
    @objc private func sliderValueChanged() {
        let time = TimeInterval(progressSlider.value) * viewModel.duration
        currentTimeLabel.text = formatTime(time)
    }
    
    @objc private func sliderTouchEnded() {
        let time = TimeInterval(progressSlider.value) * viewModel.duration
        viewModel.seek(to: time)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
