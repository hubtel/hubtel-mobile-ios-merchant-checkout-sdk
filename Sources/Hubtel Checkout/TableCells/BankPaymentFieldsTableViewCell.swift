//
//  BankPaymentFieldsTableViewCell.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

protocol SavedCardPaymentDelegate{
    func payWithSavedCard(card: BankDetails?)
}

class BankPaymentFieldsTableViewCell: UITableViewCell {
    
    static var useSavedCardForPayment: Bool = false

    
    static let identifier: String = Strings.bankPaymentCell
    
    weak var delegate: BankCellDelegate?
    
    var walletStack: WalletsTabHolderStack?
    
    var showWalletsMenu: Bool = false
    
    var menuDelegate: ShowMenuItemsDelegate?
    
    var isInternalHubtelMerchant: Bool = false
    
    var savedCarddelegate: SavedCardPaymentDelegate?
    
    lazy var accountNumberTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.attributedPlaceholder = NSAttributedString(string: Strings.cardNumberPlaceHolder , attributes: [NSAttributedString.Key.foregroundColor: Colors.appGreySecondary])
        textField.delegate = self
        textField.tag = Tags.accountNumberTextFieldTag
        textField.addTarget(self, action: #selector(shouldBeginTyping), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(validateInput(_:)), for: .editingChanged)
        textField.addSubview(bankCardTypeImageView)
        return textField
    }()
    
    lazy var accountNameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: Strings.accountHolderPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: Colors.appGreySecondary])
        textField.delegate = self
        textField.tag = Tags.accountNameTextFieldTag
        textField.addTarget(self, action: #selector(shouldBeginTyping), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(validateInput(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var expiryDateTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: Strings.expiryPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: Colors.appGreySecondary])
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.tag = Tags.expiryDateTextFieldTag
        textField.addTarget(self, action: #selector(shouldBeginTyping), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(validateInput(_:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    lazy var cvvTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: Strings.cvvPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: Colors.appGreySecondary])
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.tag = Tags.cvvTextFieldTag
        textField.addTarget(self, action: #selector(shouldBeginTyping), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(validateInput(_:)), for: .editingChanged)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var parentContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubviews(accountNumberTextField, expiryDateTextField, cvvTextField, saveCardForFutureUseLabel,accountNameTextField, switcher)
        return container
    }()
    
    let bankCardTypeImageView:ProviderImageView = {
        let imageView = ProviderImageView(imageName: "checkout_visa_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    let saveCardForFutureUseLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.saveCardForFutureUse
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()
    
    let switcher: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Tags.switcherTag
        return view
    }()
    
  
    
    let useSaveCardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        button.backgroundColor = Colors.fieldColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(Strings.useSavedCard, for: .normal)
        button.titleLabel?.font = FontManager.getAppFont(size: .m4)
        button.layer.cornerRadius = 16
        return button
    }()
    
    lazy var useNewCardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        button.backgroundColor = Colors.globalColor ?? tintColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle(Strings.useNewCard, for: .normal)
        button.titleLabel?.font = FontManager.getAppFont(size: .m4)
        button.layer.cornerRadius = 16
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [useNewCardButton,useSaveCardButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    lazy var buttonVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buttonStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buttonStack, parentContainer, savedCardView, supportingView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0 , trailing: 16)
        stack.spacing = 16
        stack.backgroundColor = .white
        stack.distribution = .fill
        return stack
    }()
    
    let savedCardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()
    
   lazy var savedCardContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [savedCardTextHolder])
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.alignment = .fill
       stackView.spacing = 16
       stackView.axis = .vertical
       return stackView
    }()
    
    let supportingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let savedCardView: UIView = {
        let view = UIView()
//        view.backgroundColor = Colors.fieldColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        view.layer.cornerRadius = 16
        view.isHidden = true
        return view
    }()
    
    lazy var savedCardTextHolder: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.fieldColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.addSubviews(savedCardLabel, providerImage, providerCarretImage)
        return view
    }()
    
    let providerImage: ProviderImageView = {
        let imageView = ProviderImageView(imageName: "checkout_mastercard_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let providerCarretImage: ProviderImageView = {
        let imageView = ProviderImageView(imageName: "caret_down")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
       clipsToBounds = true
//
        contentView.addSubview(parentStack)
        contentView.subviews.forEach { view in
            view.clipsToBounds = true
        }
//        contentView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        savedCardView.addSubview(savedCardContainer)
        setupConstraints()
        useSaveCardButton.addTarget(self, action: #selector(savedCardbuttonAction(_:)), for: .primaryActionTriggered)
        useNewCardButton.addTarget(self, action: #selector(useNewCardbuttonAction(_:)), for: .primaryActionTriggered)
//        accountNumberTextField.becomeFirstResponder()
        useSaveCardButton.isEnabled = UserDefaults.standard.object(forKey: "savedBankDetails") != nil
        //        let myData = UserDefaults.standard.decodeTheData<bankDetails>(forKey: "myCard")
        if let myBankDetails = UserDefaults.standard.object(forKey: Strings.myCard) as? Data{
            let myUnarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: BankDetails.self, from: myBankDetails)
            savedCardLabel.text = "Card ending with **** \((myUnarchivedData?.cardHolderNumber ?? "").suffix(4))"
            
        }
        
        if let myBankCard = UserDefaults.standard.data(forKey: "thisKey"){
            let myUnarchivedData = NSKeyedUnarchiver.unarchiveObject(with: myBankCard) as? [BankDetails]
//            savedCardLabel.text = "Card ending with **** \((myUnarchivedData?.cardHolderNumber ?? "").suffix(4))"
            dump(myUnarchivedData)
            
        }
        
        if let savedCards = BankDetails.getDetails(){
            savedCardLabel.text = "Card ending with **** \((savedCards[0].cardHolderNumber).suffix(4))"
            
            if (savedCards[0].cardHolderNumber.starts(with: "4")){
                providerImage.installImage(imageString: "checkout_visa_logo")
            }else{
                providerImage.installImage(imageString: "checkout_mastercard_logo")
            }
        }
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(showWallets))
        
        savedCardTextHolder.isUserInteractionEnabled = true
        
        savedCardTextHolder.addGestureRecognizer(tapgesture)
        
        useSaveCardButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        parentStack.setCustomSpacing(8, after: savedCardView)
        
        
    }
    
    func setupUI(value: Bool){
        
        let views = ["accountNumberfield":accountNumberTextField, "dobfield": expiryDateTextField, "cvvfield": cvvTextField, "stack": parentStack, "saveCardLabel": saveCardForFutureUseLabel, "switcher": switcher, "savedCardLabel": savedCardContainer, "accountNameField": accountNameTextField]
        
//        print("hereee", CheckOutViewModel.isHubtelInternalMerchant)
        saveCardForFutureUseLabel.isHidden = !value
        switcher.isHidden = !value
        buttonStack.isHidden = !value
        accountNameTextField.isHidden = value
        
        let buttonWidth = (UIScreen.main.bounds.width - 80)/2
        
        let accountNumberTextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[accountNameField(50)]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[accountNameField]|", metrics: nil, views: views)
        ].flatMap {$0}
//        NSLayoutConstraint.activate(accountNumberTextFieldConstraints)
        
        
        let accountNameTextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "V:[accountNameField]-(16)-[accountNumberfield(50)]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[accountNumberfield]|", metrics: nil, views: views)
        ].flatMap {$0}
        
        let accountNameTextField2Constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[accountNumberfield(50)]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[accountNumberfield]|", metrics: nil, views: views)
        ].flatMap {$0}
       
        
        let dobTextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dobfield(\(buttonWidth))]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[accountNumberfield]-(16)-[dobfield(50)]", metrics: nil, views: views)
        ].flatMap {$0}
//        NSLayoutConstraint.activate(dobTextFieldConstraints)
        
        let cvvTextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:[cvvfield(\(buttonWidth))]|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[accountNumberfield]-(16)-[cvvfield(50)]", metrics: nil, views: views)
        ].flatMap {$0}
        
        let saveCardLabelConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[saveCardLabel]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[dobfield]-16-[saveCardLabel]|", metrics: nil, views: views)
        ].flatMap{$0}
        
       
//        let switcherConstraints = [
//            NSLayoutConstraint.constraints(withVisualFormat: "H:[switcher]|", metrics: nil, views: views),
//            NSLayoutConstraint.constraints(withVisualFormat: "V:[cvvfield]-16-[switcher]|", metrics: nil, views: views)
//        ].flatMap{$0}
        
        let switcherConstraints = [
            switcher.trailingAnchor.constraint(equalTo: parentContainer.trailingAnchor),
            switcher.bottomAnchor.constraint(equalTo: parentContainer.bottomAnchor),
            switcher.topAnchor.constraint(equalTo: cvvTextField.bottomAnchor, constant: 16)
        ]
        
        let dob2TextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dobfield(\(buttonWidth))]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[accountNumberfield]-(16)-[dobfield(50)]|", metrics: nil, views: views)
        ].flatMap {$0}
       
        
        let cvv2TextFieldConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:[cvvfield(\(buttonWidth))]|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[accountNumberfield]-(16)-[cvvfield(50)]|", metrics: nil, views: views)
        ].flatMap {$0}
       
       
        
        if value{
//            NSLayoutConstraint.deactivate(saveCardLabelConstraints)
//            parentContainer.removeConstraints(dob2TextFieldConstraints)
//            parentContainer.removeConstraints(cvv2TextFieldConstraints)
            NSLayoutConstraint.activate(accountNameTextField2Constraints)
            NSLayoutConstraint.activate(accountNumberTextFieldConstraints)
            NSLayoutConstraint.activate(cvvTextFieldConstraints)
            NSLayoutConstraint.activate(dobTextFieldConstraints)
            NSLayoutConstraint.activate(switcherConstraints)
            NSLayoutConstraint.activate(saveCardLabelConstraints)
            
        }else{
            NSLayoutConstraint.deactivate(cvvTextFieldConstraints)
            NSLayoutConstraint.deactivate(dobTextFieldConstraints)
            NSLayoutConstraint.deactivate(switcherConstraints)
            NSLayoutConstraint.deactivate(saveCardLabelConstraints)
            NSLayoutConstraint.activate(dob2TextFieldConstraints)
            NSLayoutConstraint.activate(cvv2TextFieldConstraints)
            NSLayoutConstraint.activate(accountNameTextFieldConstraints)
            NSLayoutConstraint.activate(accountNumberTextFieldConstraints)
        }
        
        setProviderImageConstraints()
        
        parentStack.layoutIfNeeded()
        
    }
    
    func setProviderImageConstraints(){
        let imageconstraints = [
            providerImage.trailingAnchor.constraint(equalTo: providerCarretImage.leadingAnchor, constant: -8),
            providerImage.centerYAnchor.constraint(equalTo:  savedCardTextHolder.centerYAnchor ),
            providerImage.widthAnchor.constraint(equalToConstant: 26),
            providerImage.heightAnchor.constraint(equalToConstant: 18),
        ]
        NSLayoutConstraint.activate(imageconstraints)
        
        let image2constraints = [
            providerCarretImage.trailingAnchor.constraint(equalTo: savedCardTextHolder.trailingAnchor, constant: -8),
            providerCarretImage.centerYAnchor.constraint(equalTo:  savedCardTextHolder.centerYAnchor ),
            providerCarretImage.widthAnchor.constraint(equalToConstant: 12),
            providerCarretImage.heightAnchor.constraint(equalToConstant: 12),
            
        ]
        NSLayoutConstraint.activate(image2constraints)
    }
    
    
    @objc func shouldBeginTyping(){
        if allInputsEmpty() || cvvTextField.getTextCount() < 3 || accountNumberTextField.getTextCountWithoutSpacing() < 16 || expiryDateTextField.getTextCount() < 5{
            delegate?.activateButton(validate: false)
        }
       
    }
    
    func deactivateButtonOnTextInput(){
        
    }
    
    func allInputsEmpty()->Bool{
        print(self.isInternalHubtelMerchant)
        if self.isInternalHubtelMerchant{
          return cvvTextField.getTextCount() == 0 || expiryDateTextField.getTextCount() == 0 
        }
        return accountNameTextField.getTextCount() == 0 || cvvTextField.getTextCount() == 0 || expiryDateTextField.getTextCount() == 0 || accountNameTextField.getTextCount() == 0
    }
    @objc func validateInput(_ textField: CustomTextField){
        var allowCvvType = true
        
        if allInputsEmpty(){
            delegate?.activateButton(validate: false)
        }
        
        if self.isInternalHubtelMerchant{
            if (textField ) === accountNameTextField{
                if !allInputsEmpty() && (textField ).getInputText().shouldNotContainumbers(){
                    delegate?.activateButton(validate: true)
                }else{
                    delegate?.activateButton(validate: false)
                }
                
            }
        }
        
        
        if (textField) === accountNumberTextField{
            if (textField.text?.starts(with: "4") ?? false){
                self.bankCardTypeImageView.installImage(imageString: "checkout_visa_logo", showImage: true)
            }else if (textField.text?.starts(with: "5") ?? false){
                self.bankCardTypeImageView.installImage(imageString: "checkout_mastercard_logo", showImage: true)
            }
            if textField.getTextCountWithoutSpacing() == 16{
                textField.resignFirstResponder()
                expiryDateTextField.becomeFirstResponder()
            }
            
            if !allInputsEmpty() && textField.getTextCountWithoutSpacing() == 16 && !(cvvTextField.getTextCount() < 3)   {
                delegate?.activateButton(validate: true)
            }else{
                delegate?.activateButton(validate: false)
            }
        }
        
        if (textField ) === cvvTextField{
        
            if textField.getTextCount() >= 3{
                textField.resignFirstResponder()
            }
            
            if !allInputsEmpty() && (textField ).getTextCount() == 3{
                delegate?.activateButton(validate: true)
            }else{
                delegate?.activateButton(validate: false)
            }
          
        }
        
       
        if textField === expiryDateTextField{
            if (textField ).getTextCount() == 5{
                textField.resignFirstResponder()
                cvvTextField.becomeFirstResponder()
            }
            if !allInputsEmpty() && (textField ).getTextCount() == 5{
                delegate?.activateButton(validate: true)
            }else{
                delegate?.activateButton(validate: false)
            }
        }
        shouldBeginTyping()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func savedCardbuttonAction(_ sender: UIButton){
        if savedCardView.isHidden == true{

            savedCardView.isHidden = false
        }
        parentContainer.isHidden = true
        sender.backgroundColor = Colors.globalColor ?? tintColor
        sender.setTitleColor(.white, for: .normal)
        useNewCardButton.backgroundColor = Colors.fieldColor
        useNewCardButton.setTitleColor(UIColor.black, for: .normal)
        Self.useSavedCardForPayment = true
        self.delegate?.resizeCell?()
        delegate?.activateButton(validate: true)
        delegate?.endTableEditing?()
        UIView.animate(withDuration: 0.5) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    @objc func useNewCardbuttonAction(_ sender: UIButton){
        shouldBeginTyping()
        savedCardView.isHidden = true
        parentContainer.isHidden = false
        sender.backgroundColor = Colors.globalColor ?? tintColor
        sender.setTitleColor(.white, for: .normal)
        useSaveCardButton.backgroundColor = Colors.fieldColor
        useSaveCardButton.setTitleColor(UIColor.black, for: .normal)
        Self.useSavedCardForPayment = false
        self.delegate?.resizeCell?()
        UIView.animate(withDuration: 0.5) {
            self.contentView.layoutIfNeeded()
        }completion: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if CheckOutViewModel.isHubtelMerchantEnabled{
                    self.accountNumberTextField.becomeFirstResponder()
                }else{
                    self.accountNameTextField.becomeFirstResponder()
                }
            }
        }
        
    }
    

    
    
    
   
}


extension BankPaymentFieldsTableViewCell{
    
    func setupConstraints(){
        let views = ["accountNumberfield":accountNumberTextField, "dobfield": expiryDateTextField, "cvvfield": cvvTextField, "stack": parentStack, "saveCardLabel": saveCardForFutureUseLabel, "switcher": switcher, "savedCardLabel": savedCardContainer, "accountNameField": accountNameTextField]
       
       
        
        
        
        let parentStackConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stack]-|", metrics: nil, views: views)
        ].flatMap {$0}
        NSLayoutConstraint.activate(parentStackConstraints)
        
        let savedCardLabelConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[savedCardLabel]-|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[savedCardLabel]-|", metrics: nil, views: views)
        ].flatMap{$0}
        NSLayoutConstraint.activate(savedCardLabelConstraints)
        savedCardTextHolder.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        useNewCardButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let savedCardLabelnewConstraints = [savedCardLabel.centerYAnchor.constraint(equalTo: savedCardTextHolder.centerYAnchor), savedCardLabel.leadingAnchor.constraint(equalTo: savedCardTextHolder.layoutMarginsGuide.leadingAnchor), savedCardLabel.trailingAnchor.constraint(equalTo: savedCardTextHolder.layoutMarginsGuide.trailingAnchor)]
        NSLayoutConstraint.activate(savedCardLabelnewConstraints)
        
        
        let bankCardTypeImageConstraints = [
            bankCardTypeImageView.trailingAnchor.constraint(equalTo: accountNumberTextField.trailingAnchor, constant: -8),
            bankCardTypeImageView.centerYAnchor.constraint(equalTo: accountNumberTextField.centerYAnchor)
        ]
        NSLayoutConstraint.activate(bankCardTypeImageConstraints)
        
    }
    
    
}

extension BankPaymentFieldsTableViewCell: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var activateLogic = false
        var activateCardNumberInputLogic = false
        
        if textField === accountNumberTextField && string != ""{
            if textField.getTextCountWithoutSpacing() == 16{
                accountNumberTextField.resignFirstResponder()
                expiryDateTextField.becomeFirstResponder()
                return false
            }
        }
        
        if textField === expiryDateTextField{
            if textField.getTextCount() == 5 && string != ""{
                textField.resignFirstResponder()
                cvvTextField.becomeFirstResponder()
                return false
            }
        }
        
        if textField === cvvTextField{
            
            if cvvTextField.getTextCount() == 3{
                textField.text = string
                return false
            }
           
        }
        
        if textField === accountNumberTextField{
       
            if textField.getTextCountWithoutSpacing() % 4  == 0 && string != "" && textField.getTextCount() != 0{
                textField.text = textField.text! + " " + string
                return false
            }
        }
        //handle text in expiry date textField.
        if textField === expiryDateTextField{
            if textField.getTextCount() < 2 && string != ""{
                activateLogic = true
            }
            if textField.getTextCount() == 1 && activateLogic && string != ""{
                let currentText = textField.text ?? ""
                let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
                textField.text = updatedText + "/"
                activateLogic = false
                return false
               
            }
            if textField.getTextCount() == 2 && string != "" {
                textField.text = textField.text! + "/" + string
                activateLogic = false
                return false
            }
        }

        return true
    }
    
}

@objc protocol BankCellDelegate: AnyObject{
    @objc optional func resizeCell()
    @objc optional func endTableEditing()
    func activateButton(validate: Bool)
}


extension BankPaymentFieldsTableViewCell{
    
    func configureWallets(wallets: [BankDetails]?){
//        print("calllllleeeeeeddddddddddddddd")
        if let wallets = wallets{
             walletStack = WalletsTabHolderStack(cards: wallets)
            savedCardContainer.arrangedSubviews.forEach { arrView in
                savedCardContainer.removeArrangedSubview(arrView)
                arrView.isHidden = true
            }
//            walletStack = WalletsTabHolderStack(cards: wallets)
            
            walletStack?.delegate = self
            
            if !wallets.isEmpty{
//                savedCardLabel.text = "Card ending with **** \(wallets[0].cardHolderNumber.suffix(4))"
                savedCarddelegate?.payWithSavedCard(card: wallets[0])
            }
            
            savedCardContainer.addArrangedSubview(savedCardTextHolder)
            
//            savedCardContainer.addArrangedSubview(walletStack ?? UIView())
            
//            parentContainer.addArrangedSubview(provider2SelectorField)
            
            savedCardTextHolder.isHidden = false
            
            
        }
    }
    
    @objc func showWallets(){
        showWalletsMenu = !showWalletsMenu
        if showWalletsMenu{
            savedCardContainer.insertArrangedSubview(walletStack ?? UIView(), at: 1)
            walletStack?.isHidden = false
        }else{
            savedCardContainer.arrangedSubviews.forEach { view in
                if view is WalletsTabHolderStack{
                    savedCardContainer.removeArrangedSubview(view)
                    walletStack?.isHidden = true
                }
            }
        }
    
        self.menuDelegate?.showMenuForWallet()
        
    }
}


extension BankPaymentFieldsTableViewCell: WalletHolderStackProtocol{
    func selectedProvider(provider: MobilePaymentProvider?) {
        
    }
    
    func selectWallet(wallet: Wallet?) {

    }
    
    func selectedCard(card: BankDetails?) {
        savedCardLabel.text = "Card ending with **** \(card?.cardHolderNumber.suffix(4) ?? "")"
        if (card?.cardHolderNumber.starts(with: "4") ?? false){
            providerImage.installImage(imageString: "checkout_visa_logo")
        }else{
            providerImage.installImage(imageString: "checkout_mastercard_logo")
        }
        showWallets()
        savedCarddelegate?.payWithSavedCard(card: card)
    }
    
    
}
