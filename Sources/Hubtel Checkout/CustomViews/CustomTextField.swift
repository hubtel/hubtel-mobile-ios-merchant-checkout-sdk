//
//  CustomTextField.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class CustomTextField: UITextField {
    let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    func getInputText()->String{
        return self.text!
    }
    
    func getInputTextWithoutSpace()->String{
        return self.text?.replacingOccurrences(of: " ", with: "") ?? ""
    }
    
//    func getTextCount()->Int{
//        return self.text?.count ?? 0
//    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = Colors.fieldColor
        layer.cornerRadius = 8
        font = FontManager.getAppFont(size: .m4)
        textColor = .black
    }
   

}


extension UITextField{
    func getTextCount()->Int{
        return self.text?.count ?? 0
    }
    
    func getTextCountWithoutSpacing()->Int{
        return self.text?.replacingOccurrences(of: " ", with: "").count ?? 0
    }
}
