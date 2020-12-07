//
//  BundleExtension.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 7/12/2020.
//

import Foundation

extension Bundle {
    
    static var localizedBundle: Bundle {
        let languageCode = Language.language.rawValue
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") else {
            return Bundle.main
        }
        return Bundle(path: path)!
    }
    
    static var appBuildNumber: Int {
        let buildNumberString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        return Int(buildNumberString) ?? 0
    }
}
