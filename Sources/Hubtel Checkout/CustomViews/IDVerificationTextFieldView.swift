//
//  IDVerificationTextFieldView.swift
//  Hubtel.me
//
//  Created by Mark Amoah on 10/7/22.
//  Copyright © 2022 HUBTEL LIMITED. All rights reserved.
//

import UIKit
import SwiftUI

class IDVerificationTextFieldView: UIView {
    
    let formfieldHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4, weight: .regular)
        return label
    }()
    
    let textField: HubtelTextField = {
        let field = HubtelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    lazy var containerHolerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [formfieldHeader, textField])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    init(placeHoleder: String, HeaderText: String){
        super.init(frame: .zero)
        textField.placeholder = placeHoleder
        formfieldHeader.text = HeaderText
        addSubview(containerHolerStack)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let containerStack = [containerHolerStack.leadingAnchor.constraint(equalTo: leadingAnchor), containerHolerStack.trailingAnchor.constraint(equalTo: trailingAnchor), containerHolerStack.topAnchor.constraint(equalTo: topAnchor), containerHolerStack.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(containerStack)
        textField.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    
    
}
