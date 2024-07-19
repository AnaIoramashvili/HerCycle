//
//  ChatViewController.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import UIKit

class ChatViewController: UIViewController {
    
    private let viewModel = ChatViewModel()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Chatty AI"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = UIColor.color6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "• Online"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let messageInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write your message"
        textField.font = .systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sendButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()
    
    var chat = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        configureUI()
        setupBindings()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureUI() {
        view.addSubview(headerLabel)
        view.addSubview(statusLabel)
        view.addSubview(dividerLine)
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        messageInputView.addSubview(messageTextField)
        messageInputView.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            statusLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            
            dividerLine.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 14),
            dividerLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            tableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            messageInputView.heightAnchor.constraint(equalToConstant: 50),
            
            messageTextField.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant: -8),
            
            submitButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -16),
            submitButton.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 30),
            submitButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupBindings() {
        viewModel.didUpdateMessages = { [weak self] in
            self?.tableView.reloadData()
            if let count = self?.viewModel.messages.count, count > 0 {
                let indexPath = IndexPath(row: count - 1, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func didTapSubmit() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        viewModel.sendMessage(text)
        messageTextField.text = ""
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let message = viewModel.messages[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            cell.configure(message: message, isUser: true)
        } else {
            cell.configure(message: message, isUser: false)
        }
        return cell
    }
}
