//
//  OtherPaymentMethodsTableViewCell.swift
//  
//
//  Created by Mark Amoah on 10/3/23.
//

import UIKit


protocol MandateIdSelectorDelegate{
    func enterNewMandateId(value: Bool)
}

class OtherPaymentMethodsTableViewCell: UITableViewCell, AddMobileWallet, WalletHolderStackProtocol {
    func selectWallet(wallet: Wallet?) {
        self.showAccountWallets = false
        self.parentStack.removeArrangedSubview(walletStackHolder ?? UIView())
        walletStackHolder?.isHidden = true
        updateContactField(value: wallet?.accountNo ?? "")
        delegate?.updatePaymentDetails(contact: wallet?.accountNo ?? "", provider: wallet?.provider ?? "")
        delegate?.showMenuForWallet()
        
    }
    
    func selectedCard(card: BankDetails?) {
        
    }
    
    func selectedProvider(provider: MobilePaymentProvider?) {
        
    }
    
    func addMobileWallet() {
        walletAdderDelegate?.addMobileWallet()
    }
    
    
    static let identifier = "OtherPaymentChannelsField"
    
    var showMobileProvidersMenu : Bool = false
    
    var delegate: ShowMenuItemsDelegate?
    
    var otherPaymentChannelChangeDelegate: OtherChannelSelectorProtocol?
    
    var enterNewMandate: Bool = false
    
    var enterNewMandateSelectorDelegate: MandateIdSelectorDelegate?
    
    var showAccountWallets: Bool = false
    
    var wallets: [Wallet]?
    
    var walletAdderDelegate: AddMobileWallet?
    
    let walletSeletorTab: ProviderSelectorView = {
        let selectorView = ProviderSelectorView(provider: "Hubtel", frame: .zero )
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        selectorView.tag = Tags.providerWalletTagSelector
        return selectorView
    }()
    
    lazy var providerStackHolder: WalletsTabHolderStack = {
        let stack = WalletsTabHolderStack(paymentMethods: ["Hubtel", "G-Money", "Zeepay"])
        stack.channelDelegate = self
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
     var walletStackHolder: WalletsTabHolderStack?
    
    
    let contactSeletorTab: ProviderSelectorView = {
        let selectorView = ProviderSelectorView(provider: "233556236739", frame: .zero )
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        selectorView.tag = Tags.contactSelectorTag
        return selectorView
    }()
    
    let imageHolderView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = Colors.appGrey.cgColor
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let saveCardForFutureUseLabel: MyCustomLabel = MyCustomLabel(text: "Enter new Mandate ID", color: Colors.black)
    
    lazy var horizontalStackForImageHolder: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageHolderView, saveCardForFutureUseLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(enterNewMandateIDSelected))
        stackView.addGestureRecognizer(tapGesture)
        return stackView
    }()
    
    
    lazy var parentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [walletSeletorTab, hubtelWalletDescription])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        stackView.spacing = 16
        return stackView
    }()
    
    let hubtelWalletDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = Strings.hubtelWalletDescString
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()
    
    @objc func showProviders(){
        showMobileProviders()
    }
    
    @objc func enterNewMandateIDSelected(){
        enterNewMandate = !enterNewMandate
        enterNewMandateSelectorDelegate?.enterNewMandateId(value: enterNewMandate)
        if enterNewMandate{
            UIView.transition(with: imageHolderView, duration: 0.2, options: .curveLinear) {
                let verificationImage: UIImage?
                if #available(iOS 13.0, *) {
                    verificationImage = UIImage(named: "checkmark", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
                   
                } else {
                    verificationImage = UIImage(named: "nil")
                }
                
                self.imageHolderView.image = verificationImage
            }
        }else{
            self.imageHolderView.image = UIImage(named: "")
        }
    }
    
    func configureWallets(wallets: [Wallet]?){
        //        print("calllllleeeeeeddddddddddddddd")
        let mobileWallets = wallets?.filter({ wallet in
            wallet.provider?.lowercased() != "hubtel"
        })
        
        if let wallets = mobileWallets{
            
            walletStackHolder = WalletsTabHolderStack(wallets: wallets)
            
            walletStackHolder?.walletAdderDelegate = self
            
            walletStackHolder?.delegate = self
            
            self.wallets = wallets
            
            if wallets.count > 0{
                contactSeletorTab.changeProvider(with: wallets[0].accountNo ?? "")
            }
            
        }
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(walletSeletorTab)
        self.contentView.clipsToBounds = true
        contentView.addSubview(parentStack)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProviders))
        walletSeletorTab.addGestureRecognizer(gestureRecognizer)
        let tapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMobileWallets))
        contactSeletorTab.addGestureRecognizer(tapgestureRecognizer)
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func showMobileProviders(){
        
        showMobileProvidersMenu = !showMobileProvidersMenu
        
        showAccountWallets = false

        if !showAccountWallets{
            parentStack.arrangedSubviews.forEach { view in
                if (view === walletStackHolder){
                    parentStack.removeArrangedSubview(view)
                    view.isHidden = true
                }
            }
        }
        
    
        
        if showMobileProvidersMenu{
            
            parentStack.insertArrangedSubview(providerStackHolder, at: 1)
            
            providerStackHolder.isHidden = false
            
        }else{
            self.parentStack.arrangedSubviews.forEach { view in
                                    if (view === self.providerStackHolder){
                                        self.parentStack.removeArrangedSubview(view)
                                        self.providerStackHolder.isHidden = true
                                    }
                                }
        }
        self.delegate?.showMenuForWallet()
       
        
    }
    
    @objc func showMobileWallets(){
        
        showAccountWallets = !showAccountWallets
        showMobileProvidersMenu = false

        if !showMobileProvidersMenu{
            parentStack.arrangedSubviews.forEach { view in
                if (view === providerStackHolder){
                    parentStack.removeArrangedSubview(view)
                    view.isHidden = true
                }
            }
        }
    
        
        if showAccountWallets{
            
            parentStack.insertArrangedSubview(walletStackHolder ?? UIView(), at: 2)
            
            walletStackHolder?.isHidden = false
            
        }else{
            self.parentStack.arrangedSubviews.forEach { view in
                                    if (view === self.walletStackHolder){
                                        self.parentStack.removeArrangedSubview(view)
                                        view.isHidden = true
                                    }
                                }
        }
        self.delegate?.showMenuForWallet()
       
        
    }
    
//    @objc func showWallets(){
//
//        showMobileWalletsMenu = !showMobileWalletsMenu
//
//        showMobileProvidersMenu = false
//
//        if !showMobileProvidersMenu{
//            parentContainer.arrangedSubviews.forEach { view in
//                if (view === providerStack){
//                    parentContainer.removeArrangedSubview(view)
//                    providerStack?.isHidden = true
//                }
//            }
//        }
//
//        if showMobileWalletsMenu{
//            parentContainer.insertArrangedSubview(walletStack ?? UIView(), at: 1)
//
//            walletStack?.isHidden = false
//        }else{
//            parentContainer.arrangedSubviews.forEach { view in
//                if view is WalletsTabHolderStack{
//                    parentContainer.removeArrangedSubview(view)
//                    walletStack?.isHidden = true
//                }
//            }
//        }
//
//        delegate?.showMenuForWallet()
//
//    }

    
    
//
//    func removeMenu(){
//        showMobileProvidersMenu = !showMobileProvidersMenu
//
//
//
//        if showMobileProvidersMenu{
//
//            parentStack.insertArrangedSubview(providerStackHolder, at: 1)
//
//            providerStackHolder.isHidden = false
//
//        }else{
//            self.parentStack.arrangedSubviews.forEach { view in
//                                    if (view === self.providerStackHolder){
//                                        self.parentStack.removeArrangedSubview(view)
//                                        self.providerStackHolder.isHidden = true
//                                    }
//                                }
//        }
//
//    }
    
    private func updateContactField(value: String){
        self.contactSeletorTab.changeProvider(with: value)
    }
    
    func handleZpaySelection(){
        self.parentStack.arrangedSubviews.forEach { view in
            if (view === self.providerStackHolder){
                self.parentStack.removeArrangedSubview(view)
                self.providerStackHolder.isHidden = true
            }
            if (view === self.horizontalStackForImageHolder){
                self.parentStack.removeArrangedSubview(view)
                view.isHidden = true
            }
            
            }
        
        self.contactSeletorTab.isHidden = false
        self.parentStack.insertArrangedSubview(contactSeletorTab, at: 1)
        
    }
    
    func handleGMoneySelection(){
        self.parentStack.arrangedSubviews.forEach { view in
            if (view === self.providerStackHolder){
                self.parentStack.removeArrangedSubview(view)
                self.providerStackHolder.isHidden = true
            }
            
            }
        self.contactSeletorTab.isHidden = false
        self.horizontalStackForImageHolder.isHidden = false
        self.parentStack.insertArrangedSubview(contactSeletorTab, at: 1)
        self.parentStack.insertArrangedSubview(horizontalStackForImageHolder, at: 2)
        
    }
    
    func handleHubtelSelection(){
        self.parentStack.arrangedSubviews.forEach { view in
            if (view === self.providerStackHolder){
                self.parentStack.removeArrangedSubview(view)
                self.providerStackHolder.isHidden = true
            }
            if (view === self.contactSeletorTab){
                self.parentStack.removeArrangedSubview(view)
                self.contactSeletorTab.isHidden = true
            }
            
            if (view === self.horizontalStackForImageHolder){
                self.parentStack.removeArrangedSubview(view)
                view.isHidden = true
            }
            
            }
        
    }
    
    func setupConstraints(){
        let walletTabSelectorTabConstraints = [
            walletSeletorTab.heightAnchor.constraint(equalToConstant: 50),
            contactSeletorTab.heightAnchor.constraint(equalToConstant: 50),
        ]
        NSLayoutConstraint.activate(walletTabSelectorTabConstraints)
        
        let parentStackConstraints = [
            parentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            parentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            parentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            parentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentStackConstraints)
    }
    
    //MARK: Helper UI methods to live update views
    func setupProviderString(providerString: String){
        self.walletSeletorTab.changeProvider(with: providerString)
    }
    
    func setupDescString(value: String){
        if value.lowercased() == "hubtel"{
            handleHubtelSelection()
            self.hubtelWalletDescription.text = Strings.hubtelWalletDescString
            delegate?.showMenuForWallet()
            return
        }
        
        if value.lowercased() == "zeepay"{
            self.hubtelWalletDescription.text  = "Zee Pay"
            self.hubtelWalletDescription.attributedText = Strings.getSteps()
            handleZpaySelection()
            delegate?.showMenuForWallet()
            return
        }
        
        if value.lowercased() == "g-money"{
            handleGMoneySelection()
            self.hubtelWalletDescription.text = Strings.gmoneyDescString
            delegate?.showMenuForWallet()
            return
        }
    }
    
    func getPaymentType()->PaymentType {
        if walletSeletorTab.getProviderString() == "hubtel"{
            return .hubtel
        }
        
        if walletSeletorTab.getProviderString() == "zeepay"{
            return .zeepay
        }
        
        if walletSeletorTab.getProviderString() == "g-money"{
            return .gmoney
        }
        return .hubtel
    }

}


extension OtherPaymentMethodsTableViewCell: OtherChannelSelectorProtocol{
    func selectChannel(channel: String) {
        self.walletSeletorTab.changeProvider(with: channel)
        self.setupDescString(value: channel)
        self.otherPaymentChannelChangeDelegate?.selectChannel(channel: channel)
//        showMobileProviders()
    }
    
    
}
