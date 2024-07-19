////
////  CustomTabBarView.swift
////  HerCycle
////
////  Created by Ana on 7/17/24.
////
//
//import UIKit
//
//protocol CustomTabBarDelegate: AnyObject {
//    func didSelectTab(at index: Int)
//}
//
//class CustomTabBarView: UIView {
//    weak var delegate: CustomTabBarDelegate?
//    
//    private let tabItems: [TabItem] = [
//        TabItem(title: "Home", iconName: "house"),
//        TabItem(title: "Calendar", iconName: "calendar"),
//        TabItem(title: "Chat", iconName: "message"),
//        TabItem(title: "Profile", iconName: "person")
//    ]
//    
//    private var buttons: [UIButton] = []
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupView() {
//        backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        layer.cornerRadius = 35
//        layer.masksToBounds = true
//        
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.alignment = .center
//        stackView.spacing = 6
//        
//        for (index, item) in tabItems.enumerated() {
//            let button = createButton(for: item, tag: index)
//            stackView.addArrangedSubview(button)
//            buttons.append(button)
//        }
//        
//        addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
//            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
//            heightAnchor.constraint(equalToConstant: 70)
//        ])
//    }
//    
//    private func createButton(for item: TabItem, tag: Int) -> UIButton {
//        let button = UIButton()
//        button.tag = tag
//        button.setImage(UIImage(systemName: item.iconName), for: .normal)
//        button.setTitle(item.title, for: .normal)
//        button.setTitleColor(.gray, for: .normal)
//        button.setTitleColor(.black, for: .selected)
//        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
//        
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
//        
//        return button
//    }
//    
//    @objc private func tabButtonTapped(_ sender: UIButton) {
//        for button in buttons {
//            button.isSelected = false
//        }
//        sender.isSelected = true
//        delegate?.didSelectTab(at: sender.tag)
//    }
//}
//
//struct TabItem {
//    let title: String
//    let iconName: String
//}
//
