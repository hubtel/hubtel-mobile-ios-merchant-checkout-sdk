//
//  CustomCardView.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class CustomCardView: UIView {
    
    
    let titleOnCard = MyCustomLabel(text: "Card Details", font: FontManager.getAppFont(size: .m4, weight: .bold))
    let cardNumber = CardDetailsView(key: "Card Number", value: "**** **** **** 1234")
    let expiryNumber = CardDetailsView(key: "Expires", value: "06/23")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(titleOnCard, cardNumber, expiryNumber)
        layer.cornerRadius = 16
        backgroundColor = Colors.appYellowColor
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let titleOnCardConstraints = [
            titleOnCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 21),
            titleOnCard.topAnchor.constraint(equalTo: topAnchor, constant: 21),
        ]
        NSLayoutConstraint.activate(titleOnCardConstraints)
        
        let cardNumberStackConstraints = [
            cardNumber.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 21),
            cardNumber.topAnchor.constraint(equalTo: titleOnCard.bottomAnchor, constant: 21),
            cardNumber.trailingAnchor.constraint(equalTo: expiryNumber.leadingAnchor, constant: 8),
            cardNumber.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21)
        ]
        NSLayoutConstraint.activate(cardNumberStackConstraints)
        
        let expiryNumberConstraints = [
            expiryNumber.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            expiryNumber.topAnchor.constraint(equalTo: titleOnCard.bottomAnchor, constant: 21),
            expiryNumber.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21)
        ]
        NSLayoutConstraint.activate(expiryNumberConstraints)
    }
    
    func setupUI(with cardDetails: CardNumberHolderObj){
        cardNumber.setupValue(value: cardDetails.cardNumber)
        expiryNumber.setupValue(value: cardDetails.expiryNumber)
    }
    
    
    

}
