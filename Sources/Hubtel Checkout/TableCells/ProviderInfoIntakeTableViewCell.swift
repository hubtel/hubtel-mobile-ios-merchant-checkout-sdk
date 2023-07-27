//
//  ProviderInfoIntakeTableViewCell.swift
//  
//
//  Created by Mark Amoah on 6/15/23.
//

import UIKit

protocol ShowMenuItemsDelegate: AnyObject{
    func showPopOver()

}
class ProviderInfoIntakeTableViewCell: UITableViewCell {
    weak var delegate: ShowMenuItemsDelegate?
    static let identifier = "MobileMoneyInputIntake"
    weak var validateDelegate: BankCellDelegate?
    
    lazy var mobileMoneyTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your mobile money number here"
        textField.attributedPlaceholder = NSAttributedString(string: Strings.mobileMoneyNumberTakerPlaceHolder , attributes: [NSAttributedString.Key.foregroundColor: Colors.appGreySecondary])
        textField.addTarget(self, action: #selector(validateInput(_:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        textField.tag = Tags.mobileMoneyTextFieldTag
        textField.addTarget(self, action: #selector(shouldValidateInuput(_:)), for: .editingDidBegin)
        return textField
    }()
    
    lazy var providerSelectorField: ProviderSelectorView = {
        let view = ProviderSelectorView(provider: "MTN Mobile Money", frame: .zero)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showProviders))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    
    lazy var parentContainer: UIStackView = {
        let container = UIStackView(arrangedSubviews: [mobileMoneyTextField, providerSelectorField])
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        container.spacing = 16
        container.axis = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.isUserInteractionEnabled = true
        return container
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentView.addSubview(parentContainer)
        tag = Tags.mobileMoneySectionCellTag
        contentView.clipsToBounds = true
        contentView.subviews.forEach { view in
            view.clipsToBounds = true
        }
        setupConstraints()
    }
    
    @objc func validateInput(_ sender: UITextField){
        validateDelegate?.activateButton(validate: sender.text!.count > 8)
    }
    
    @objc func shouldValidateInuput(_ sender: UITextField){
        validateDelegate?.activateButton(validate: sender.text!.count > 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showProviders(){
        delegate?.showPopOver()
    }
    
    func setupConstraints(){
        let parentContainerConstraints = [
            parentContainer.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            parentContainer.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            parentContainer.topAnchor.constraint(equalTo: topAnchor),
            parentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentContainerConstraints)
        contentView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        [mobileMoneyTextField, providerSelectorField].forEach { view in
            view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    func setupProviderString(with value: String){
        providerSelectorField.setupString(value: value)
    }
    
    }
    

