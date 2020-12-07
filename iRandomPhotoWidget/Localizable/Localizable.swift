//
//  Localizable.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 7/12/2020.
//

import Foundation

let appLanguagesKey = "AppLanguages"

enum Language: String, CaseIterable {
    
    case english = "en"
    case traditionalChineseHK = "zh-HK"
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    
    static var language: Language {
        get {
            if let languageCode = UserDefaults.standard.string(forKey: appLanguagesKey),
               let language = Language(rawValue: languageCode) {
                return language
            } else {
                let preferredLanguage = NSLocale.preferredLanguages[0] as String
                
                if preferredLanguage.contains(Language.traditionalChineseHK.rawValue) {
                    return Language.traditionalChineseHK
                }
                
                if preferredLanguage.contains(Language.traditionalChinese.rawValue) {
                    return Language.traditionalChinese
                }
                
                if preferredLanguage.contains(Language.simplifiedChinese.rawValue) {
                    return Language.simplifiedChinese
                }
                
                return Language.english
            }
        }
        set {
            guard language != newValue else {
                return
            }
            
            UserDefaults.standard.set([newValue.rawValue], forKey: appLanguagesKey)
        }
    }
}

extension Language {
    var name: String {
        let locale = NSLocale(localeIdentifier: self.rawValue)
        return locale.displayName(forKey: .identifier, value: self.rawValue)!
    }
}

func localizedString(forKey: String) -> String {
    return Bundle.localizedBundle.localizedString(forKey: forKey, value: nil, table: nil)
}
