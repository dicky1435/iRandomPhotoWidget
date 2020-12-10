//
//  SettingViewController.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 4/12/2020.
//
import SwiftUI
import UIKit
import WidgetKit

class SettingTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var photoShadow:Bool = false
    var photoTimeNBattery:Bool = false
    
    var info = [
            [localizedString(forKey: "yes"),localizedString(forKey: "no")],
            //[localizedString(forKey: "photoInorder"),localizedString(forKey: "photoRandom")],
            [localizedString(forKey: "yes"),localizedString(forKey: "no")],
            [Language.allCases],
            [localizedString(forKey: "unlimitedCode")]
        ]
    
    var titleArray = [
        localizedString(forKey: "photoShadow"),
        //localizedString(forKey: "photoplay"),
        localizedString(forKey: "photoTimeNBattery"),
        localizedString(forKey: "language"),
        localizedString(forKey: "unlockFunction")
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
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoShadow") == nil) {
            self.photoShadow = true
        } else {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoShadow") == "YES") {
                self.photoShadow = true
            } else {
                self.photoShadow = false
            }
        }
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBattery") == nil) {
            self.photoTimeNBattery = true
        } else {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBattery") == "YES") {
                self.photoTimeNBattery = true
            } else {
                self.photoTimeNBattery = false
            }
        }
        
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

        setFooterView()
        setupLayer()
        setView()
    }
    
    func tableView(_ tableView: UITableView,
      numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
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

        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            
            if let myLabel = cell.textLabel {
                myLabel.text =
                    "\(info[indexPath.section][indexPath.row])"
            }
            
            cell.accessoryType = .none //accessory not selection
            
            if self.photoShadow {
                if indexPath.row == 0 {
                    cell.accessoryType = .checkmark
                }
            } else {
                if indexPath.row == 1 {
                    cell.accessoryType = .checkmark
                }
            }
            
        } else if indexPath.section == 1 {
            
            if let myLabel = cell.textLabel {
                myLabel.text =
                    "\(info[indexPath.section][indexPath.row])"
            }
            
            cell.accessoryType = .none //accessory not selection
            
            if self.photoTimeNBattery {
                if indexPath.row == 0 {
                    cell.accessoryType = .checkmark
                }
            } else {
                if indexPath.row == 1 {
                    cell.accessoryType = .checkmark
                }
            }
            
        } else if indexPath.section == 2 {

            
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
        return self.titleArray[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set("YES", forKey: "settingPhotoShadow")
                self.photoShadow = true
            } else {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set("NO", forKey: "settingPhotoShadow")
                self.photoShadow = false
            }
            WidgetCenter.shared.reloadAllTimelines()
            tableView.reloadData()
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set("YES", forKey: "settingPhotoTimeNBattery")
                self.photoTimeNBattery = true
            } else {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set("NO", forKey: "settingPhotoTimeNBattery")
                self.photoTimeNBattery = false
            }
            WidgetCenter.shared.reloadAllTimelines()
            tableView.reloadData()
        } else if indexPath.section == 2 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
            
            let languageCode = Language.allCases[indexPath.row].rawValue
            setLanguage(languageCode)
            
            self.dismiss(animated: true) {
                // Create the SwiftUI view that provides the window contents.
                let contentView = ContentView(goToHome: true, animateAction: false)
                guard let window = UIApplication.shared.keyWindow else { return }
                window.rootViewController = UIHostingController(rootView: contentView)
            }
           
        } else if indexPath.section == 3 {
            unlockCode()
        }
    }
    
    func unlockCode() {
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "purchaseUnlock") == nil) {
            let dialogMessage = UIAlertController(title: localizedString(forKey: "unlockFunction"), message: localizedString(forKey: "unlockAsking"), preferredStyle: .alert)
            
            dialogMessage.addTextField(configurationHandler: { textField in
                textField.placeholder = localizedString(forKey: "unlockPlaceHolder")
            })
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                if (dialogMessage.textFields?.first?.text?.uppercased() == GlobalConstants.unlockCode) {
                    UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set(GlobalConstants.unlockCode, forKey: "purchaseUnlock")
                    
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let dialogMessage = UIAlertController(title: localizedString(forKey: "unlockFunction"), message: localizedString(forKey: "unlockWrongCode"), preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    })
                    dialogMessage.addAction(ok)
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            })
            
            let cancel = UIAlertAction(title: localizedString(forKey: "cancel"), style: .cancel) { (action) -> Void in
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        } else {
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "purchaseUnlock") == GlobalConstants.unlockCode) {
                let dialogMessage = UIAlertController(title: localizedString(forKey: "unlockFunction"), message: localizedString(forKey: "unlockAlready"), preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            } else {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.removeObject(forKey: "purchaseUnlock")
                unlockCode()
            }
           
        }
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
    
    func setFooterView() {
        let basicView = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.text = "v1.0.0"
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 15)
        basicView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: basicView.centerXAnchor).isActive = true
        tableView.tableFooterView = basicView
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
