//
//  MyCustomLabel.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class MyCustomLabel: UILabel {

    init(text: String, font: UIFont = FontManager.getAppFont(size: .m4), textAlignment: NSTextAlignment = .left, color: UIColor = UIColor.black){
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.font = font
        self.textAlignment = textAlignment
        self.textColor = color
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
