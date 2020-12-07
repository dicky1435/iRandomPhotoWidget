//
//  SettingViewController.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 4/12/2020.
//
import SwiftUI
import UIKit

class SettingTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var info = [
            ["林書豪","陳信安"],
            [Language.allCases]
        ]
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        button.tintColor = .label
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.text = localizedString(forKey: "setting")
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGroupedBackground
        tableView.register(
          UITableViewCell.self, forCellReuseIdentifier: "Cell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .singleLine

        tableView.separatorInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        tableView.allowsSelection = true

        tableView.allowsMultipleSelection = false

        setupLayer()
        setView()
    }
    
    func tableView(_ tableView: UITableView,
      numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return Language.allCases.count
        } else {
            return info[section].count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath as IndexPath) as
            UITableViewCell

        if indexPath.section == 1 {
            cell.selectionStyle = .none
            
            cell.textLabel?.text = Language.allCases[indexPath.row].name
            
            if Language.allCases[indexPath.row] == Language.language {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                cell.accessoryType = .none
            }
        } else {
            if let myLabel = cell.textLabel {
                myLabel.text =
                    "\(info[indexPath.section][indexPath.row])"
            }
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return info.count
    }
    
    func tableView(_ tableView: UITableView,
      titleForHeaderInSection section: Int) -> String? {
        let title = section == 0 ? "籃球" : localizedString(forKey: "language")
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        let languageCode = Language.allCases[indexPath.row].rawValue
        setLanguage(languageCode)
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(goToHome: true,animateAction: false)
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = UIHostingController(rootView: contentView)
    }
    
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: appLanguagesKey)
    }
    
    // MARK: Setup Layer
    func setupLayer() {
        self.view.addSubview(closeButton)
        self.view.addSubview(titleLabel)
        self.view.addSubview(tableView)
    }
    
    func setView() {
        titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        closeButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor, constant: 0).isActive = true
        closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func closeAction() {
        dismiss(animated: true, completion: nil)
    }
}

struct SettingTableView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let settingTableView = SettingTableViewController()
        settingTableView.modalPresentationStyle = .overCurrentContext
        settingTableView.definesPresentationContext = true
        return settingTableView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
