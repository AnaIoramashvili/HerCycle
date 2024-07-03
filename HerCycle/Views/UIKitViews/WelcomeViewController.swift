//
//  WelcomeViewController.swift
//  HerCycle
//
//  Created by Ana on 7/2/24.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUIElements()
    }

    private func setupGradientBackground() {
        let whiteColor = UIColor.white
        let color1 = UIColor(named: "Color1")
        let color2 = UIColor(named: "Color2")
        let color3 = UIColor(named: "Color3")

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [whiteColor.cgColor, color1!.cgColor, color2!.cgColor, color3!.cgColor]
        gradientLayer.locations = [0.0, 0.3, 0.6, 1.0]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUIElements() {
        let titleLabel = UILabel()
        titleLabel.text = "Keep track of your period"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Easily and accurately track each phase of your menstrual cycle."
        subtitleLabel.textColor = .white
        subtitleLabel.font = UIFont.systemFont(ofSize: 18)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let getStartedButton = UIButton(type: .system)
        getStartedButton.setTitle("Get started", for: .normal)
        getStartedButton.setTitleColor(.systemPink, for: .normal)
        getStartedButton.backgroundColor = UIColor(.white)
        getStartedButton.layer.cornerRadius = 20
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.addTarget(self, action: #selector(didTapGetStarted), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(getStartedButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTapGetStarted() {
        NavigationManager.shared.presentTabBarController(from: self)
    }
}
