//
//  TextAnimation.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 20/8/2021.
//

import SwiftUI

struct TextAnimation: Identifiable {
    var id = UUID().uuidString
    var text: String
    var offset: CGFloat = 110
}
