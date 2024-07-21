//
//  InsightDetailViewController.swift
//  HerCycle
//
//  Created by Ana on 7/17/24.
//

import UIKit

class InsightDetailViewController: UIViewController {
    
    private let insight: Insight
    private let insightTitle: String
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.text = "Tips 🌟:"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let articlesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.text = "Related Articles:"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let articlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 8
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(insight: Insight, title: String) {
        self.insight = insight
        self.insightTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureViews()
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mainTabBarController = tabBarController as? MainTabBarController {
            mainTabBarController.setCustomTabBarHidden(true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let mainTabBarController = tabBarController as? MainTabBarController {
            mainTabBarController.setCustomTabBarHidden(false)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.background
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(informationLabel)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(tipsStackView)
        containerView.addSubview(articlesLabel)
        containerView.addSubview(articlesStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),   
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 270),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            informationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            informationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            tipsLabel.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 16),
            tipsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tipsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            tipsStackView.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: 8),
            tipsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tipsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            articlesLabel.topAnchor.constraint(equalTo: tipsStackView.bottomAnchor, constant: 16),
            articlesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            articlesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            articlesStackView.topAnchor.constraint(equalTo: articlesLabel.bottomAnchor, constant: 8),
            articlesStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            articlesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            articlesStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureViews() {
        navigationItem.title = nil
        
        if let imageUrl = URL(string: insight.image) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
        
        titleLabel.text = insight.title
        informationLabel.text = insight.information
        
        for tip in insight.tips {
            let tipLabel = UILabel()
            tipLabel.text = "✨ " + tip
            tipLabel.font = UIFont.systemFont(ofSize: 14)
            tipLabel.textColor = .darkGray
            tipLabel.numberOfLines = 0
            tipsStackView.addArrangedSubview(tipLabel)
        }
        
        for article in insight.articles {
            let articleButton = UIButton(type: .system)
            articleButton.setTitle(article.title, for: .normal)
            articleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            articleButton.contentHorizontalAlignment = .left
            articleButton.addTarget(self, action: #selector(openArticle(_:)), for: .touchUpInside)
            articlesStackView.addArrangedSubview(articleButton)
        }
    }
    
    @objc private func openArticle(_ sender: UIButton) {
        guard let index = articlesStackView.arrangedSubviews.firstIndex(of: sender),
              let url = URL(string: insight.articles[index].url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
