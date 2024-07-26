//
//  RatingViewController.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import UIKit

class RatingViewController: UIViewController, UITextViewDelegate {

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.alignment = .fill
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate Our App"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 15
        return stack
    }()

    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.backgroundColor = .white
        textView.delegate = self
        return textView
    }()

    private let placeholderText = "Add your comment here (optional)"

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "primaryPink")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()


    private var selectedRating: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePlaceholder()
    }

    private func updatePlaceholder() {
        commentTextView.text = placeholderText
        commentTextView.textColor = .lightGray
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            updatePlaceholder()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .mainBackground
        
        for i in 1...5 {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "star_empty")?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.setImage(UIImage(named: "star_filled")?.withRenderingMode(.alwaysOriginal), for: .selected)
            button.tag = i
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            ratingStackView.addArrangedSubview(button)
        }
        
        [titleLabel, ratingStackView, commentTextView, submitButton].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            commentTextView.heightAnchor.constraint(equalToConstant: 120),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func ratingButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateRatingButtons()
    }

    private func updateRatingButtons() {
        ratingStackView.arrangedSubviews.enumerated().forEach { (index, view) in
            if let button = view as? UIButton {
                button.isSelected = index < selectedRating
            }
        }
    }

    @objc private func submitButtonTapped() {
        guard selectedRating > 0 else {
            showAlert(message: "Please select a rating before submitting.")
            return
        }

        let comment = commentTextView.textColor == .lightGray ? "" : commentTextView.text
        let rating = Rating(stars: selectedRating, review: comment ?? "", date: Date())
        RatingManager.shared.saveRating(rating)
        
        showAlert(message: "Thank you for your feedback!") { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Feedback", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }
}
