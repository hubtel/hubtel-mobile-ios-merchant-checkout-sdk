//
//  WalletsTabHolderStack.swift
//  
//
//  Created by Mark Amoah on 9/20/23.
//

import UIKit

protocol WalletHolderStackProtocol{
    func selectWallet(wallet: Wallet?)
    func selectedCard(card: BankDetails?)
    func selectedProvider(provider: MobilePaymentProvider?)
}

protocol OtherChannelSelectorProtocol{
    func selectChannel(channel: String)
}


class WalletsTabHolderStack: UIView {
    var delegate: WalletHolderStackProtocol?
    
    var walletAdderDelegate: AddMobileWallet?
    
    var channelDelegate: OtherChannelSelectorProtocol?
    
    
    
    let customStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fill
        view.clipsToBounds = true
//        view.alignment = .leading
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
//        self.heightAnchor.constraint(equalToConstant: 70).isActive = true
        setupShadow()
    }
    
    private func setupShadow() {
           // Set the shadow color
           layer.shadowColor = UIColor.black.cgColor
           
           // Set the shadow opacity (0.0 - 1.0)
        layer.shadowOpacity = 0.3
           
           // Set the shadow offset (horizontal and vertical)
           layer.shadowOffset = CGSize(width: 0, height: 2)
           
           // Set the shadow radius (spread of the shadow)
           layer.shadowRadius = 4
           
           // Enable shadow clipping to prevent shadow from overflowing the view
           layer.masksToBounds = false
           
           // Optionally, you can also set a corner radius to round the corners of your view
           layer.cornerRadius = 10
           
           // You can adjust these properties as needed to achieve your desired shadow effect.
       }
    
    convenience init(wallets: [Wallet]){
        self.init(frame: .zero)
        
        for wallet in wallets {
            let walletView = TabSelectorCard(wallet: wallet)
            walletView.delegate = self
            walletView.translatesAutoresizingMaskIntoConstraints = false

            self.customStack.addArrangedSubview(walletView)
        }
        let addMobileWalletTab = TabSelectorCard(addTitleMessage: "Add Mobile Wallet")
        
        addMobileWalletTab.walletAdderDelegate = self
        
        customStack.addArrangedSubview(addMobileWalletTab)
        
        self.addSubviews(customStack)
        
        setupConstraints()
        
        
       
        
//        self.layoutIfNeeded()
        
    }
    
    convenience init(cards: [BankDetails]){
        self.init(frame: .zero)
        
        for card in cards {
            let walletView = TabSelectorCard(card: card)
            walletView.delegate = self
            walletView.savedBankCardDelegate = self
            walletView.translatesAutoresizingMaskIntoConstraints = false
            if card.cardHolderNumber.starts(with: "4") {
             walletView.providerImage.installImage(imageString: "checkout_visa_logo")
            }else{
             walletView.providerImage.installImage(imageString: "checkout_mastercard_logo")
            }
            self.customStack.addArrangedSubview(walletView)
        }
        
        self.addSubviews(customStack)
        
        setupConstraints()
        
        
    }
    
    convenience init(providers: [MobilePaymentProvider]){
        self.init(frame: .zero)
        
        for provider in providers {
            let walletView = TabSelectorCard(provider: provider)
//            walletView.delegate = self
//            walletView.savedBankCardDelegate = self
            walletView.providerSelectorDelegate = self
            walletView.translatesAutoresizingMaskIntoConstraints = false
            self.customStack.addArrangedSubview(walletView)
        }
        
        self.addSubviews(customStack)
        
        setupConstraints()
        
        
    }
    
    convenience init(paymentMethods: [String]){
        self.init(frame: .zero)
        
        for provider in paymentMethods {
            let walletView = TabSelectorCard(title: provider)
//            walletView.delegate = self
//            walletView.savedBankCardDelegate = self
            walletView.channelDelegate = self
            walletView.translatesAutoresizingMaskIntoConstraints = false
            self.customStack.addArrangedSubview(walletView)
        }
        
        self.addSubviews(customStack)
        
        setupConstraints()
        
        
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
    
    
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupConstraints(){
        let stackConstraints = [
            customStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            customStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            customStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            customStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(stackConstraints)
    }
    
}

extension WalletsTabHolderStack: WalletTabProtocol{
    func selectedWallet(wallet: Wallet?) {
        delegate?.selectWallet(wallet: wallet)
    }
    
}


extension WalletsTabHolderStack: SavedWalletProtocol{
    func selectedBankWallet(wallet: BankDetails?){
        delegate?.selectedCard(card: wallet)
    }
    
    
}

extension WalletsTabHolderStack: ProviderSelectorProtocol{
    func selectedMobileProvider(provider: MobilePaymentProvider?) {
        delegate?.selectedProvider(provider: provider)
    }
    
    
}

extension WalletsTabHolderStack: AddMobileWallet{
    func addMobileWallet() {
        walletAdderDelegate?.addMobileWallet()
    }
    
    
}

extension WalletsTabHolderStack: OtherChannelSelectorProtocol{
    func selectChannel(channel: String) {
        self.channelDelegate?.selectChannel(channel: channel)
    }
}
