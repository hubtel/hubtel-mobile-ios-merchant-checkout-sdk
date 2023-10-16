//
//  SuccessOverLayView.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit

class SuccessOverLayView: UIView {
    
    let successImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let orderPlacedLabel = MyCustomLabel(text: "Your Order has been placed", textAlignment: .center)
    
    let customerPhoneNumber = MyCustomLabel(text: "0556236739", textAlignment: .center)
    
   
    
    
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [successImage, orderPlacedLabel, customerPhoneNumber])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 16
        stack.layer.cornerRadius = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 22, leading: 16, bottom: 22, trailing: 16)
        return stack
    }()
    
    func setupConstraints(){
        let stackConstraints = [
            parentStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            parentStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            parentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            parentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(stackConstraints)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(labelString:String, imageString: String, background: UIColor = UIColor(red: 1, green: 244/255, blue: 204/255, alpha: 1), phoneNumber: String? = nil) {
        self.init(frame: .zero)
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        self.addSubview(parentStack)
        parentStack.backgroundColor = background
        setupConstraints()
        self.customerPhoneNumber.isHidden = phoneNumber == nil
        let verificationImage: UIImage?
        if #available(iOS 13.0, *) {
            verificationImage = UIImage(named: imageString, in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            verificationImage = UIImage(named: "nil")
        }
        
        self.successImage.image = verificationImage
        self.successImage.isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        self.customerPhoneNumber.text = phoneNumber ?? ""
        self.orderPlacedLabel.text = labelString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
