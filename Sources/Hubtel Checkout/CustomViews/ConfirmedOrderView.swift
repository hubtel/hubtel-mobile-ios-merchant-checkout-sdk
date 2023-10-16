//
//  ConfirmedOrderView.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit
import SwiftUI

class ConfirmedOrderView: UIView {
    
    let successLabel = MyCustomLabel(text: "Succcess", font: FontManager.getAppFont(size: .m3, weight: .bold), textAlignment: .center)
    
    let successImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let orderPlacedLabel = MyCustomLabel(text: "Your Order has been placed", textAlignment: .center)
    
    let amountDeductedLabel = MyCustomLabel(text: "GHS 200 has been paid")
    
    let walletNameLabel = MyCustomLabel(text: "lets go", font: FontManager.getAppFont(size: .m4, weight: .bold), textAlignment: .center)
    
    
    let debitedMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [successImage, successLabel, orderPlacedLabel, debitedMessage, amountDeductedLabel, walletNameLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    override init(frame: CGRect){
        super.init(frame: frame )
    }
    
    convenience init(walletName: String, amount: Double, backgroundColor: UIColor = UIColor(red: 219/255, green: 247/255, blue: 224/255, alpha: 1.0), hideAmountLabel: Bool = false,imageString: String = "successMark",  message: String? = nil, title: String? = nil, preapproved: Bool = false, preApprovedString:String = ""){
        self.init(frame: .zero)
        parentStack.setCustomSpacing(8, after: successImage)
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 55, leading: 24, bottom: 55, trailing: 24)
        self.addSubview(parentStack)
        self.debitedMessage.text = self.setWalletString(walletName: walletName, amount: amount)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        let verificationImage: UIImage?
        if #available(iOS 13.0, *) {
            verificationImage = UIImage(named: imageString, in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            verificationImage = UIImage(named: "nil")
        }
        self.successImage.image = verificationImage
        
        debitedMessage.isHidden = hideAmountLabel
        successLabel.isHidden = !hideAmountLabel
        amountDeductedLabel.isHidden = !hideAmountLabel
        orderPlacedLabel.isHidden = hideAmountLabel
        self.walletNameLabel.isHidden = !preapproved
        
        if let message{
            amountDeductedLabel.text = message
        }
        
        if let title{
            successLabel.isHidden = false
            successLabel.text = title
        }
        
        if preapproved{
            walletNameLabel.isHidden = false
            orderPlacedLabel.isHidden = false
            debitedMessage.isHidden = true
            amountDeductedLabel.isHidden = true
        }
        setupConstraints()
    }
    
    
    func setupConstraints(){
        let stackConstraints = [
            parentStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            parentStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            parentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            parentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(stackConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setWalletString(walletName: String, amount: Double) -> String{
        return "Your \(walletName) will be debited with GHS \(amount) after your order is confirmed"
    }
    
    func setAmountDeductedLabel(amount: Double, currency: String){
        
        let attString = NSMutableAttributedString(string: "\(currency) \(amount)", attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4)])
        
        attString.append(NSAttributedString(string: " has been paid", attributes: [NSAttributedString.Key.foregroundColor: Colors.textGreen.cgColor, NSAttributedString.Key.font: FontManager.getAppFont(size: .m4)]))
        
        self.amountDeductedLabel.attributedText = attString
    }
    
}
