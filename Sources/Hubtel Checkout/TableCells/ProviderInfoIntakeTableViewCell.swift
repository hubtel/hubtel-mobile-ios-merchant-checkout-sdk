//
//  ProviderInfoIntakeTableViewCell.swift
//  
//
//  Created by Mark Amoah on 6/15/23.
//

import UIKit

protocol ShowMenuItemsDelegate: AnyObject{
    func showPopOver()
    func showMenuForWallet()
    func updatePaymentDetails(contact: String, provider: String)
}
class ProviderInfoIntakeTableViewCell: UITableViewCell {
    
    weak var delegate: ShowMenuItemsDelegate?
    
    static let identifier = "MobileMoneyInputIntake"
    
    weak var validateDelegate: BankCellDelegate?
    
    var walletStack: WalletsTabHolderStack?
    
    var showMobileWalletsMenu: Bool = false
    
    var walletsStackHeight: NSLayoutConstraint!
    
    var providerStackHeight: NSLayoutConstraint!
    
    var showMobileProvidersMenu: Bool = false
    
    var walletAdderDelegate: AddMobileWallet?
    
    
    var providerStack: WalletsTabHolderStack?
    
    
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
    
    lazy var numberSelectorField: ProviderSelectorView = {
        let view = ProviderSelectorView(provider: "MTN Mobile Money", frame: .zero)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showWallets))
        view.addGestureRecognizer(tapGesture)
        view.tag = Tags.momoNumberSelectorTag
        return view
    }()
    
    lazy var provider2SelectorField: ProviderSelectorView = {
        let view = ProviderSelectorView(provider: "", frame: .zero)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMobileProviders))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    let supportingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        container.distribution = .fill
        container.alignment = .fill
        return container
    }()
    
    @objc func showWallets(){
        
        showMobileWalletsMenu = !showMobileWalletsMenu
        
        showMobileProvidersMenu = false
        
        if !showMobileProvidersMenu{
            parentContainer.arrangedSubviews.forEach { view in
                if (view === providerStack){
                    parentContainer.removeArrangedSubview(view)
                    providerStack?.isHidden = true
                }
            }
        }
        
        if showMobileWalletsMenu{
            parentContainer.insertArrangedSubview(walletStack ?? UIView(), at: 1)
            
            walletStack?.isHidden = false
        }else{
            parentContainer.arrangedSubviews.forEach { view in
                if view is WalletsTabHolderStack{
                    parentContainer.removeArrangedSubview(view)
                    walletStack?.isHidden = true
                }
            }
        }
        
        delegate?.showMenuForWallet()
        
    }
    
    @objc func showMobileProviders(){
        
        showMobileProvidersMenu = !showMobileProvidersMenu
        
        showMobileWalletsMenu = false
        
        
        if !showMobileWalletsMenu{
            parentContainer.arrangedSubviews.forEach { view in
                if (view === walletStack){
                    parentContainer.removeArrangedSubview(view)
                    walletStack?.isHidden = true
                }
            }
        }
        
        if showMobileProvidersMenu{
            
            parentContainer.insertArrangedSubview(providerStack ?? UIView(), at: 2)
            
            providerStack?.isHidden = false
            
        }else{
            self.parentContainer.arrangedSubviews.forEach { view in
                                    if (view === self.providerStack){
                                        self.parentContainer.removeArrangedSubview(view)
                                        self.providerStack?.isHidden = true
                                    }
                                }
//            providerStackHeight.priority = UILayoutPriority.defaultHigh
//            providerStackHeight.constant = 0
//            UIView.animate(withDuration: 0.2) {
//                self.layoutIfNeeded()
//            } completion: { complete in
//                if complete{
////
//                }
//                self.delegate?.showMenuForWallet()
//            }

           
        }
        self.delegate?.showMenuForWallet()
       
        
    }
    
    
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
    
    func configureWallets(wallets: [Wallet]?){
//        print("calllllleeeeeeddddddddddddddd")
        let filteredWallets = wallets?.filter({ wallet in
            wallet.provider?.lowercased() != "hubtel"
        })
        
        if let wallets = wallets{
//            let walletStack = WalletsTabHolderStack(wallets: walle
            parentContainer.arrangedSubviews.forEach { arrView in
                parentContainer.removeArrangedSubview(arrView)
                arrView.isHidden = true
            }
            
            walletStack = WalletsTabHolderStack(wallets: filteredWallets ?? [])
            
            walletStack?.walletAdderDelegate = self
            
            providerStack = WalletsTabHolderStack(providers: [MobilePaymentProvider(title: "MTN Mobile Money", provider: "mtn"), MobilePaymentProvider(title: "Vodafone Cash", provider: "voda"), MobilePaymentProvider(title:"Airtel Tigo Cash", provider: "tigo-gh")])
            
//            providerStackHeight = providerStack?.heightAnchor.constraint(equalToConstant: 0)
            
//            providerStackHeight.isActive = true
            
            providerStack?.delegate = self
            
            walletStack?.delegate = self
            
            if !wallets.isEmpty{
                provider2SelectorField.providerLabel.text = getProviderName(value:wallets[0].provider ?? "")
                numberSelectorField.providerLabel.text = wallets[0].accountNo
            }
            
            parentContainer.addArrangedSubview(numberSelectorField)
            
//            parentContainer.addArrangedSubview(walletStack ?? UIView())
            
            parentContainer.addArrangedSubview(provider2SelectorField)
            
            [numberSelectorField,  provider2SelectorField].forEach { lview in
                lview.isHidden = false
            }
            parentContainer.addArrangedSubview(supportingView)
            
            
        }else{
            parentContainer.addArrangedSubview(mobileMoneyTextField)
            parentContainer.addArrangedSubview(providerSelectorField)
        }
    }
    
    func setupConstraints(){
        let parentContainerConstraints = [
            parentContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            parentContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            parentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            parentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentContainerConstraints)
//        contentView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        [mobileMoneyTextField, providerSelectorField, numberSelectorField, provider2SelectorField].forEach { view in
            view.heightAnchor.constraint(equalToConstant: 50).isActive = true
            view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        }
    }
    
    func setupProviderString(with value: String){
        providerSelectorField.setupString(value: value)
    }
    
    func getProviderName(value: String)->String{
        switch true{
        case value.contains("mtn"):
            return "MTN Mobile Money"
        case value.contains("voda"):
            return "Vodafone Cash"
        case value.contains("tigo"):
            return "Airtel Tigo Cash"
        default:
            return ""
        }
    }
    
    }
    


extension ProviderInfoIntakeTableViewCell : WalletHolderStackProtocol{
    func selectedProvider(provider: MobilePaymentProvider?) {
        self.provider2SelectorField.providerLabel.text = provider?.title ?? ""
        delegate?.updatePaymentDetails(contact: "", provider: provider?.provider ?? "")
        showMobileProviders()
    }
    
    func selectedCard(card: BankDetails?) {
        
    }
    
    func selectWallet(wallet: Wallet?) {
        self.numberSelectorField.providerLabel.text = wallet?.accountNo
        self.provider2SelectorField.providerLabel.text = getProviderName(value: wallet?.provider ?? "")
        delegate?.updatePaymentDetails(contact: wallet?.accountNo ?? "", provider: wallet?.provider ?? "")
        showWallets()
    }
    
    
}


extension ProviderInfoIntakeTableViewCell: AddMobileWallet{
    func addMobileWallet() {
        walletAdderDelegate?.addMobileWallet()
    }
    
    
}
