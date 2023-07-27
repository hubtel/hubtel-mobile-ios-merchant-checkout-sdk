//
//  FraudFailureDescTableViewCell.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class FraudFailureDescTableViewCell: UITableViewCell {
    static let identifier = "fraudlabsFailureDescriptionTableCellDescriptor"
    let upperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let lowerLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.numberOfLines = 0
        label.text = "If this transaction is urgent, try another bank card or payment option."
        label.textAlignment = .center
        return label
    }()
    
    lazy var parentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [upperLabel, lowerLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(parentStack)
        selectionStyle = .none
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let parentStackConstraints = [
            parentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            parentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            parentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            parentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(parentStackConstraints)
    }
    
    func setupUI(with details: CardDeclinedStatementObj){
        let attributedString = NSMutableAttributedString(string: details.fraudLabsSttus == .review ? "Your " : "We cannot process your ", attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4), NSAttributedString.Key.foregroundColor: UIColor.black.cgColor])
        attributedString.append(NSAttributedString(string: details.cardType, attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor]))
        attributedString.append(NSAttributedString(string: " from ", attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)]))
        attributedString.append(NSAttributedString(string: details.issuingBank, attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor]))
        attributedString.append(NSAttributedString(string: details.fraudLabsSttus == .review ? " is having processing challenges at the moment. We are reviewing this and may contact you. " : " now.", attributes: [NSAttributedString.Key.font: FontManager.getAppFont(size: .m4), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)]))
        upperLabel.attributedText = attributedString
        lowerLabel.text = details.fraudLabsSttus == .review ? "If this transaction is urgent, try another bank card or payment option." : "Try another bank card or payment option."
        
    }
    
    

    
}
