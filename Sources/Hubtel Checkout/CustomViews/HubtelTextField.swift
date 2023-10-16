//
//  HubtelTextField.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class HubtelTextField: UITextField {

    let padding  = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
       
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
    
        return bounds.inset(by: padding)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.backgroundColor = Colors.appGreyDark
        self.textColor = Colors.black
        self.font = FontManager.getAppFont(size: .m4, weight: .regular)
    }

}
