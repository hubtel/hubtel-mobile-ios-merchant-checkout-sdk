//
//  File.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import Foundation
import UIKit
enum FontSize : Int {
    case m1 = 28
    case m2 = 20
    case m2_5 = 18
    case m3 = 16
    case m4 = 14
    case m5 = 12
    case m6 = 11
    case m7 = 10
    case m8 = 8
    case m9 = 24
    case m31 = 31
    case m10 = 15
    case m11 = 9
    case m13 = 13
    case m30 = 30
    case m22 = 22
    case m34 = 34
    case m42 = 42
    case m12 = 5
}

enum FontWeight : String {
    case regular = "NunitoSans-Regular"
    case bold = "NunitoSans-ExtraBold"
    
    var systemEquivalent : UIFont.Weight {
        switch self {
        case .regular:
            return .regular
        case .bold:
            return .bold
        }
    }
}

class FontManager {

    private static func getFontNames() -> [String]{
        return UIFont.familyNames.sorted()
    }
    
    static func getAppFont(size : FontSize , weight : FontWeight = .regular) -> UIFont{
        
        return UIFont(name: weight.rawValue, size: CGFloat(size.rawValue)) ?? .systemFont(ofSize: CGFloat(size.rawValue), weight: weight.systemEquivalent)
    }
    
    static func addCustomFont(name: String, size: FontSize)->UIFont{
        return UIFont(name: name, size: CGFloat(size.rawValue)) ?? UIFont.systemFont(ofSize: 14)
    }
    
}
