//
//  SettingViewController.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 4/12/2020.
//
import SwiftUI
import UIKit

class SettingTableViewController: UITableViewController {
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // navigationController?.view.backgroundColor = Color.eClass.themeColor
        
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.allowsMultipleSelection = false
        tableView.tableFooterView = UIView()
    }
    
    func setLanguage(_ languageCode: String) {
//        UserDefaults.standard.set(languageCode, forKey: appLanguagesKey)
//
//        let mainTabVC = MainTabBarViewController()
//        if let arrayVc = mainTabVC.arrayVc {
//            mainTabVC.selectedIndex = arrayVc.count - 1
//        }
//
//        guard let window = UIApplication.shared.keyWindow else { return }
//        window.rootViewController = mainTabVC
    }
}

extension SettingTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "LanguageCell")
        cell.selectionStyle = .none
        
//        cell.textLabel?.text = Language.allCases[indexPath.row].name
//
//        if Language.allCases[indexPath.row] == Language.language {
//            cell.accessoryType = .checkmark
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
//        let languageCode = Language.allCases[indexPath.row].rawValue
//        setLanguage(languageCode)
    }
}

final class SettingTableView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UITableViewController {
        let settingTableView = SettingTableViewController()
        settingTableView.modalPresentationStyle = .overFullScreen
        settingTableView.definesPresentationContext = true
        return settingTableView
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
        
    }
}
