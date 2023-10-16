//
//  TabSelectorCard.swift
//  
//
//  Created by Mark Amoah on 9/20/23.
//

import UIKit

protocol WalletTabProtocol{
    func selectedWallet(wallet: Wallet?)
}

protocol SavedWalletProtocol{
    func selectedBankWallet(wallet: BankDetails?)
}

protocol ProviderSelectorProtocol{
    func selectedMobileProvider(provider: MobilePaymentProvider?)
}

protocol AddMobileWallet{
    func addMobileWallet()
}


class TabSelectorCard: UIView {
    
    var wallet: Wallet?
    
    var delegate: WalletTabProtocol?
    
    let titleLabel = MyCustomLabel(text: "title", font: FontManager.getAppFont(size: .m5))
    
    let subtitleLabel = MyCustomLabel(text: "Subtitle", font: FontManager.getAppFont(size: .m5))
    
    var savedBankCardDelegate: SavedWalletProtocol?
    
    var card: BankDetails?
    
    var provider: MobilePaymentProvider?
    
    var providerSelectorDelegate: ProviderSelectorProtocol?
    
    var walletAdderDelegate: AddMobileWallet?
    
    var channelSelected: String?
    
    var channelDelegate: OtherChannelSelectorProtocol?
    
    let providerImage: ProviderImageView = {
        let imageView = ProviderImageView(imageName: "checkout_mastercard_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let providerCarretImage: ProviderImageView = {
        let imageView = ProviderImageView(imageName: "caretforward")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let addWalletIcon: ProviderImageView = {
        let imageView = ProviderImageView(imageName: "plus_addon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    lazy var addWalletAndParentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [addWalletIcon, parentStack])
        stack.spacing = 8
        stack.axis = .horizontal
        return stack
    }()
    
    
    
    lazy var  parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var mainVerticalParentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [addWalletAndParentStackView])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    @objc func selectedWallet(){
        delegate?.selectedWallet(wallet: wallet)
    }
    
    @objc func selectedSavedBankWallet(){
        savedBankCardDelegate?.selectedBankWallet(wallet: card)
    }
    
    @objc func selectedProvider(){
        providerSelectorDelegate?.selectedMobileProvider(provider: provider)
    }
    
    @objc func addMobileWalletAction(){
        walletAdderDelegate?.addMobileWallet()
    }
    
    @objc func selectChannel(){
        channelDelegate?.selectChannel(channel: channelSelected ?? "")
    }
    
    //MARK: Initializer for mobile wallet selctor
    convenience init(wallet: Wallet){
        self.init(frame: .zero)
        self.titleLabel.text =  wallet.accountNo
        self.subtitleLabel.text = getProviderName(value: wallet.provider ?? "") 
        self.subtitleLabel.textColor = Colors.appGreySecondary
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentStack)
        parentStack.addSubview(providerCarretImage)
        setupCaretConstraints()
        setupConstraints()
        self.wallet = wallet
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectedWallet))
        addGestureRecognizer(gesture)
        
    }
    
    //MARK: Initializer for payment Providers
    convenience init(provider: MobilePaymentProvider){
        self.init(frame: .zero)
        self.titleLabel.text =  provider.title
        self.subtitleLabel.isHidden = true
        self.subtitleLabel.textColor = Colors.appGreySecondary
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentStack)
        parentStack.addSubview(providerCarretImage)
        setupConstraints()
        setupCaretConstraints()
        self.provider = provider
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectedProvider))
        addGestureRecognizer(gesture)
        
    }
    
    //MARK: Initializer for payment saved wallets selector Field
    convenience init(card: BankDetails){
        self.init(frame: .zero)
        self.titleLabel.text =  "Card ending with **** \(card.cardHolderNumber.suffix(4))"
        self.subtitleLabel.text = "\(card.expiryMonth)/\(card.expiryYear.suffix(2))"
        self.subtitleLabel.textColor = Colors.appGreySecondary
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentStack)
        parentStack.addSubview(providerImage)
        parentStack.addSubview(providerCarretImage)
        setupConstraints()
        setProviderImageConstraints()
        self.card = card
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectedSavedBankWallet))
        addGestureRecognizer(gesture)
    }
    
    
    //MARK: Initializer to create an add Mobile wallet tab
    convenience init(addTitleMessage: String, imageString: String? = nil){
        self.init(frame: .zero)
        self.subtitleLabel.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = addTitleMessage
        titleLabel.font = FontManager.getAppFont(size: .m4, weight: .bold)
        self.addSubview(mainVerticalParentStack)
//        parentStack.addSubview(mainVerticalParentStack)
        mainVerticalParentStack.addSubview(providerCarretImage)
        setupWalletAddTabConstraints()
        setupCaretConstraints()
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(addMobileWalletAction))
        addGestureRecognizer(gesture)
    }
    
    //MARK: Initializer to show other payment methods
    convenience init(title:String){
        self.init(frame: .zero)
        self.subtitleLabel.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = title
        channelSelected = title
        titleLabel.font = FontManager.getAppFont(size: .m4)
        self.addSubview(parentStack)
        setupConstraints()
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectChannel))
        addGestureRecognizer(gesture)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 func setupConstraints() {
        let parentStackConstraints = [
            parentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            parentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            parentStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            parentStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentStackConstraints)
     
    }
    
    func setupWalletAddTabConstraints(){
        let parentStackConstraints = [
            mainVerticalParentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVerticalParentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainVerticalParentStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainVerticalParentStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentStackConstraints)
        let image2constraints = [
            providerCarretImage.trailingAnchor.constraint(equalTo: mainVerticalParentStack.trailingAnchor, constant: -2),
            providerCarretImage.centerYAnchor.constraint(equalTo:  mainVerticalParentStack.centerYAnchor )
        ]
        NSLayoutConstraint.activate(image2constraints)
    }
    
    func setProviderImageConstraints(){
        let imageconstraints = [
            providerImage.trailingAnchor.constraint(equalTo: providerCarretImage.leadingAnchor, constant: -2),
            providerImage.centerYAnchor.constraint(equalTo:  parentStack.centerYAnchor )
        ]
        NSLayoutConstraint.activate(imageconstraints)
        
        let image2constraints = [
            providerCarretImage.trailingAnchor.constraint(equalTo: parentStack.trailingAnchor, constant: -2),
            providerCarretImage.centerYAnchor.constraint(equalTo:  parentStack.centerYAnchor )
        ]
        NSLayoutConstraint.activate(image2constraints)
    }
    
    func setupCaretConstraints(){
        let image2constraints = [
            providerCarretImage.trailingAnchor.constraint(equalTo: parentStack.trailingAnchor, constant: -2),
            providerCarretImage.centerYAnchor.constraint(equalTo:  parentStack.centerYAnchor )
        ]
        NSLayoutConstraint.activate(image2constraints)
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
