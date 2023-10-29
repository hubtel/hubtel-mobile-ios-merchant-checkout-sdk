//
//  CheckoutViewController.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit



public class CheckoutViewController: UIViewController {
    lazy var viewModel = CheckOutViewModel(delegate: self)
    var bottomConstraint : NSLayoutConstraint!
    var paymentType: PaymentType?
    lazy var paymentProvider: String = viewModel.providerChannel
    var showBankField: Bool = false
    var showMomoField: Bool = false
    var showOtherFieldsTab: Bool = false
    static var callBack: (String)->() = {_ in}
    weak var delegate: PaymentFinishedDelegate?
    var salesID =    UserSetupRequirements.shared.salesID
    var merchantApiKey =   UserSetupRequirements.shared.apiKey
    var callbackUrl: String? =   UserSetupRequirements.shared.callBackUrl
    var paymentChannel: PaymentChannel? = nil
    var task: URLSessionDataTask?
    var progress: UIAlertController?
    static var completedStatusString: String = "here"
    var viewHasAlreadyLoaded: Bool = false
    var usesOnlyBankPayment: Bool = false
    var imageUpdateController = ImageUpdatShowerUpdate()
    var showFees = false
    var wallets: [Wallet]? = nil
    var businessImage: String = ""
    var businessName: String = ""
    
    var customerMobileNumber: String?
    
    var enterNewMandateId: Bool = false
  
    var initCustomerMobilerNumber: String?
    
    var data2 : [Section] = [
        
    ]
    
    
    var order: PurchaseInfo?
    
    ///This static function is used to start the checkout process.
    ///- parameter customController: This is the controller to present the checkout view controller from your code. In most cases, `self` works when the current controller is the presenter.
    ///- parameter configuration: A struct having `salesId`, `callbackUrl`, and `merchantApiKey` as properties. This is used to add prerequisite values to the checkout process
    ///- parameter purchaseInfo: A struct having `businessName`, `itemPrice`, `customerPhoneNumber` and `purchaseDescription` as properties. This object encapsulates info about the purchase item used for payment.
    ///- parameter delegate: An object conforming to the PaymentFinishedDelegate to listen to call backs from the sdk
    ///- parameter tintColor: An optional color used as a theme for the sdk.
    public static func presentCheckout(from customController: UIViewController, with configuration: HubtelCheckoutConfiguration, and purchaseInfo: PurchaseInfo, delegate: PaymentFinishedDelegate, tintColor: UIColor? = nil){
        UserSetupRequirements.shared.apiKey = configuration.merchantApiKey
        UserSetupRequirements.shared.callBackUrl = configuration.callbackUrl
        UserSetupRequirements.shared.salesID = configuration.salesID
        UserSetupRequirements.shared.customerPhoneNumber = purchaseInfo.customerMsisDn
        let controller = CheckoutViewController()
        controller.order = purchaseInfo
        controller.viewModel.order = purchaseInfo
        controller.delegate = delegate
        Colors.globalColor = tintColor
        let myController = UINavigationController(rootViewController: controller)
        myController.presentationController?.delegate = ModalPresentationDelegate.shared
        customController.present(myController, animated: true)
        General.usePresentation = true
        
        
    }
    
    
    public static func presentCheckoutInternal(from customController: UIViewController, with configuration: HubtelCheckoutConfiguration, and purchaseInfo: PurchaseInfo, delegate: PaymentFinishedDelegate, tintColor: UIColor? = nil, savedBankDetails: BankDetails?) {
        UserSetupRequirements.shared.apiKey = configuration.merchantApiKey
        UserSetupRequirements.shared.callBackUrl = configuration.callbackUrl
        UserSetupRequirements.shared.salesID = configuration.salesID
        UserSetupRequirements.shared.customerPhoneNumber = purchaseInfo.customerMsisDn
        UserSetupRequirements.isInternalMerchant = true
        let controller = CheckoutViewController()
        controller.order = purchaseInfo
        controller.viewModel.order = purchaseInfo
        controller.delegate = delegate
        Colors.globalColor = tintColor
        let myController = UINavigationController(rootViewController: controller)
        myController.presentationController?.delegate = ModalPresentationDelegate.shared
        customController.present(myController, animated: true)
        General.usePresentation = true
        
        if let savedBankDetails = savedBankDetails{
            savedBankDetails.saveToDb()
        }
    }
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        return button
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = Colors.bgColorGray
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return table
    }()
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        registerFonts()
        view.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        self.view.addSubview(bottomButton)
        self.view.addSubview(tableView)
        tableView.register(ReceiptTableViewCell.self, forCellReuseIdentifier: ReceiptTableViewCell.identifier)
        tableView.register(PayWithTableViewCell.self, forCellReuseIdentifier: PayWithTableViewCell.identifier)
        tableView.register(PaymentChoiceTableViewCell.self, forCellReuseIdentifier: PaymentChoiceTableViewCell.identifier)
        tableView.register(BottomCornersTableViewCell.self, forCellReuseIdentifier: BottomCornersTableViewCell.identifier)
        tableView.register(BankPaymentFieldsTableViewCell.self, forCellReuseIdentifier: BankPaymentFieldsTableViewCell.identifier)
        tableView.register(ProviderInfoIntakeTableViewCell.self, forCellReuseIdentifier: ProviderInfoIntakeTableViewCell.identifier)
        tableView.register(OtherPaymentMethodsTableViewCell.self, forCellReuseIdentifier: OtherPaymentMethodsTableViewCell.identifier)
        tableView.separatorStyle = .none
        navigationController?.navigationBar.prefersLargeTitles = false
        var blackImage: UIImage?
        if #available(iOS 13.0, *) {
            blackImage = UIImage(named: "close_black", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
         blackImage = UIImage(named: "nil")
        }
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: blackImage, style: .plain, target: self, action: #selector(dismissVC))
        } else {
            // Fallback on earlier versions
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nil"), style: .plain, target: self, action: #selector(dismissVC))
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: ""), style: .plain, target: self, action: nil)
        setupConstraints()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
       
        
//        self.bottomButton.showLoader(value: true)
        navigationItem.titleView = NotificationBarHeader(title: "Checkout")
        UserSetupRequirements.shared.resetStates()
        let purchaseItem = PurchaseOrderItem(id: order?.clientReference, name: "", quantity: 1, amount: order?.amount, section: "checkout", provider: viewModel.providerChannel)
        let purchaseAnalytics = BeginPurchaseAppEvent(section: .checkout, amount: order?.amount ?? 0.00, purchaseOrderItems: [purchaseItem])
        
        AnalyticsHelper.recordBeginPurchase(beginPurchase: purchaseAnalytics)
        
        let name = Notification.Name("doneWithVerification")
        NotificationCenter.default.addObserver(self, selector: #selector(performMomoPaymentAfterVerification(_:)), name: name, object: nil)
        
//        let vc = AddMobileWalletViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        let name4 = Notification.Name(rawValue: "doneAddingWallet")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWallets), name: name4, object: nil)

    }
    
    @objc func reloadWallets(){
        self.viewModel.makeGetWallets(customerMsisdn: viewModel.order?.customerMsisDn ?? "")
    }
    
    @objc func performMomoPaymentAfterVerification(_ sender: NSNotification){
        if let channel = sender.object as? String{
            print(channel)
            self.makeMomoRequest(checkoutChannel: channel)
        }
       
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//                self.viewModel.makeGetWallets(customerMsisdn: viewModel.order?.customerMsisDn ?? "")
        
//       
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        if !viewHasAlreadyLoaded{
            viewModel.paymentChannelsAllowed()
           viewHasAlreadyLoaded = true
        }
       
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutPayViewPagePay)
  
//        bottomButton.validate(false)
    }
    
//    public override func viewDidDisappear(_ animated: Bool) {
//        ReceiptHeaderView.openFees = false
//    }
    @objc func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            if isKeyboardShowing {
                bottomConstraint?.constant =  -keyboardFrame!.height
                self.view.layoutIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.scrollToLastRow()
                }
            }else{
                bottomConstraint?.constant =  0
            }
            
        }
    }
    
    @objc func dismissVC(){
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutPayTapClose)
        CheckoutViewController.cancelTransaction(viewController: self, onCancelled: {
            BankPaymentFieldsTableViewCell.useSavedCardForPayment = false 
            if self.presentingViewController != nil{
                self.dismiss(animated: true){
                    if UserSetupRequirements.shared.checkToShowCancelledState(){
                        self.delegate?.checkStatus(value: .userCancelledPayment)
                    }else if UserSetupRequirements.shared.checkToShowFailedState(){
                        self.delegate?.checkStatus(value: .paymentFailed)
                    }else if UserSetupRequirements.shared.checkToShowTransactionSuccessState(){
                        self.delegate?.checkStatus(value: .paymentSuccessful)
                    }else{
                        self.delegate?.checkStatus(value: .unknown)
                    }
                   
                    CheckoutViewController.completedStatusString = "You cancelled the payment"
                }
            }else{
                self.navigationController?.popToRootViewController(animated: true)
                self.delegate?.checkStatus(value: .userCancelledPayment)
            }
       
            
        })
    }
    
    func setupConstraints(){
        let views = ["bottomButton": bottomButton, "tableView": tableView]
        //Setup bottom constraints for button
        let buttonConstraints = [NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomButton]|", metrics: nil, views: views)].flatMap{$0}
        NSLayoutConstraint.activate(buttonConstraints)
        
        bottomConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        //setup table Constraints
        
        let tableViewConstraints = [NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tableView][bottomButton]", metrics: nil, views: views), NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: views)
        ].flatMap{$0}
        NSLayoutConstraint.activate(tableViewConstraints)
        
    }
    
    deinit{
        CheckOutViewModel.allowPayment = false
    }
}

extension CheckoutViewController: ViewStatesDelegate{
    
    func showErrorToDismiss(message: String, dismiss: Bool) {
        if dismiss{
            progress?.dismiss(animated: true, completion: {
                self.showAlert(with: "Error", message: MyError.someThingHappened.message) { action in
                    self.dismiss(animated: true)
                }
            })
        }
    }
    
    func showLoaderOnBottomButtonIfNeeded(with value: Bool) {
        if value{
            bottomButton.showLoader(value: true)
        }else{
            if CheckOutViewModel.checkoutType == .preapprovalconfirm{
                bottomButton.showLoader(value: false, name: Strings.agreeAndContinue)
               
            }else{
                bottomButton.showLoader(value: false, name: "PAY")
            }
        }
    }
    
    
    func handleBusinessInfoPassed(businessId: String?, businessName: String?, businessImageUrl: String?) {
        
        
        self.businessImage = businessImageUrl ?? ""
        
        self.businessName = businessName ?? ""
        
        
        
        
        
    }
    
    func scrollToLastRow() {
        let indexPath = NSIndexPath(row: data2.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
    }
    
    

    
    func updateFeesValue(value: [GetFeesUpdateView]){
        
        print(value)
        
//        (self.view.viewWithTag(Tags.receiptHeaderViewTag) as? ReceiptHeaderView)?.setupFees(value: value)
        viewModel.fees =  value
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        
        CheckOutViewModel.allowPayment = true
        
        if wallets != nil && paymentType == .momo{
            bottomButton.validate(true)
            return
        }
        
        if paymentType == .zeepay || paymentType == .hubtel || paymentType == .gmoney {
            bottomButton.validate(true)
            return
        }
      
        
        
    }
    
    func showErrorMessagetToUser(message: String) {
        if let progress = progress{
            progress.dismiss(animated: true){
                self.showAlert(with: "Error",message: message)
            }
        }else{
            showAlert(with: "Error",message: message)
        }
    }
    
    
    func showLoadingStateWhileMakingNetworkRequest(with value: Bool) {
        self.progress = showNetworkCallProgress(isCancellable: true)
    }
    
    
    
    func dismissLoaderToPerformAnotherAction() {
        progress?.dismiss(animated: true){
            
        }
    }
    
    func showHideFees(value: Bool){
        
        showFees = value
        
        print(value)
        
        self.viewModel.feesToUpdateFrontend = showFees ? viewModel.fees : []
        
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        self.tableView.performBatchUpdates(nil)
        
    }
    
    func dismissLoaderToPerformWebCheckout() {
        progress?.dismiss(animated: true){
            CheckoutWebViewController.openWebViewForPayment(parentController: self, setupResponse: self.viewModel.setupResponse, with: self.viewModel.merchantApiKey ?? "", delegate: self.delegate, usePresentation: self.presentingViewController != nil)
        }
    }
    
    func dismissLoaderToPerformMomoPayment(){
        progress?.dismiss(animated: true){ [self] in
            
            if paymentType == .zeepay || paymentType == .hubtel || paymentType == .gmoney{
                CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.directDebitText,provider: "", delegate: self.delegate, transactionDetails: self.viewModel.momoResponse, clientReference: self.viewModel.order?.clientReference, amountPaid: self.viewModel.totalAmount)
                return
            }
            
            if CheckOutViewModel.checkoutType == .receivemoneyprompt{
                self.showAlert(with: Strings.success, message: Strings.setMomoPrompt(with: self.viewModel.momoNumber ?? "")){ action in
                    CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.setMomoPrompt(with: self.viewModel.momoNumber ?? ""),provider: self.paymentProvider, delegate: self.delegate, transactionDetails: self.viewModel.momoResponse, clientReference: self.viewModel.order?.clientReference, amountPaid: self.viewModel.totalAmount)
                }
              
            } else if CheckOutViewModel.checkoutType == .preapprovalconfirm{
                if (self.viewModel.preApprovalResponse?.verificationType == "OTP" && self.viewModel.preApprovalResponse?.skipOtp == false){
                    let controller = OtpScreenViewController(mobileNumber: self.viewModel.momoNumber ?? "", preapprovalResponse: self.viewModel.preApprovalResponse, amount: viewModel.totalAmount)
                    controller.delegate = self.delegate
                    self.navigationController?.pushViewController(controller, animated: true)
                }else{
                    if self.viewModel.preApprovalResponse?.preapprovalStatus?.lowercased() == "pending" || self.viewModel.preApprovalResponse?.preapprovalStatus == nil{
                        CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.setMomoPrompt(with: self.viewModel.momoNumber ?? ""),provider: self.paymentProvider, delegate: self.delegate, transactionDetails: self.viewModel.momoResponse, clientReference: self.viewModel.order?.clientReference, amountPaid: self.viewModel.totalAmount
                        )
                    }else{
                        let controller = PreApprovalSuccessVcViewController(walletName: "mobile money wallet", amount: self.viewModel.totalAmount , delegate: self.delegate
                        )
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                    
                    
                    
                   
                }
                
               
                return
            }else if CheckOutViewModel.checkoutType == .directdebit{
                
                if (self.viewModel.momoResponse?.verificationType == "OTP" && self.viewModel.momoResponse?.skipOtp == false){
                    let approvalStatus = PreApprovalResponse(preapprovalStatus: "", verificationType: self.viewModel.momoResponse?.verificationType, clientReference: self.viewModel.momoResponse?.clientReference, hubtelPreapprovalId: self.viewModel.momoResponse?.hubtelPreapprovalId, otpPrefix: self.viewModel.momoResponse?.otpPrefix, customerMsisdn: self.viewModel.momoResponse?.customerMsisdn, skipOtp: viewModel.momoResponse?.skipOtp, clientReferenceId: self.viewModel.order?.clientReference)
                    
                    let controller = OtpScreenViewController(mobileNumber: viewModel.momoNumber ?? "", preapprovalResponse: approvalStatus, checkoutType: .directdebit, clientReference: self.viewModel.momoResponse?.clientReference ?? self.order?.clientReference)
                    controller.delegate = self.delegate
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                    return
                    
                }
               
            }
            
            
            CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.directDebitText,provider: self.paymentProvider, delegate: self.delegate, transactionDetails: self.viewModel.momoResponse, clientReference: self.viewModel.order?.clientReference, amountPaid: self.viewModel.totalAmount)

        }
    }
    
    func handleBankPaymentForRejectCardCase() {
        let data: [TableRenderingData] = [
            CardDeclinedStatusObj(failureImage: "errorx", failureMessage: "Your bank has been declined"),
            CardDeclinedStatementObj(cardType: viewModel.cardWhitelistCheckResponseObj?.fraudCheckResponse?.cardType ?? "", issuingBank: viewModel.cardWhitelistCheckResponseObj?.fraudCheckResponse?.cardIssuingBank ?? "", fraudLabsSttus: viewModel.cardWhitelistCheckResponseObj?.fraudLabsStatus ?? .review),
            CardNumberHolderObj(cardNumber: viewModel.cardWhitelistCheckResponseObj?.cardNumber ?? "", expiryNumber: viewModel.cardWhitelistCheckResponseObj?.getExpiry ?? "")
        ]
        CardVerificationViewController.makeCardVerificationViewController(with: data, parentController: self)
    }
    
    func handleBankPaymentForApproveCardCase() {
        print("go to 3ds")
    }
    
    func handleBankPaymentForReviewCardCase() {
        let data: [TableRenderingData] = [
            CardDeclinedStatusObj(failureImage: "errorx", failureMessage: "Your bank has been declined"),
            CardDeclinedStatementObj(cardType: viewModel.cardWhitelistCheckResponseObj?.fraudCheckResponse?.cardType ?? "", issuingBank: viewModel.cardWhitelistCheckResponseObj?.fraudCheckResponse?.cardIssuingBank ?? "", fraudLabsSttus: viewModel.cardWhitelistCheckResponseObj?.fraudLabsStatus ?? .review),
            CardNumberHolderObj(cardNumber: viewModel.cardWhitelistCheckResponseObj?.cardNumber ?? "", expiryNumber: viewModel.cardWhitelistCheckResponseObj?.getExpiry ?? "")
        ]
        CardVerificationViewController.makeCardVerificationViewController(with: data, parentController: self)
    }
    
    func handleBothBankAndMobileMoney() {
        func handleData(){
            self.data2 = [
                Section(title: "", imageName: "", cellStyle: .receiptHeader),
                Section(title: Strings.payWith, imageName: Strings.emptyString, cellStyle: .payWithTitle),
                Section(title: Strings.mobileMoney, imageName: "", cellStyle: .paymentChoiceHeader),
                Section(title: "", imageName: "", cellStyle: .momoInputs),
                Section(title: Strings.bankCard, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bankCardInputs),
//                Section(title: Strings.others, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
//                Section(title: Strings.emptyString, imageName: Strings.emptyString, cellStyle: .otherPaymentMethods),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bottomCell)
            ]
        }
        
        if let progress = progress{
            progress.dismiss(animated: true){
                handleData()
                self.tableView.reloadData()
            }
        }else{
            handleData()
            self.tableView.reloadData()
        }
        
    }
  
    
    func handleWalletsForInternalMerchants() {
        func handleData(){
            self.data2 = [
                Section(title: "", imageName: "", cellStyle: .receiptHeader),
                Section(title: Strings.payWith, imageName: Strings.emptyString, cellStyle: .payWithTitle),
                Section(title: Strings.mobileMoney, imageName: "", cellStyle: .paymentChoiceHeader),
                Section(title: "", imageName: "", cellStyle: .momoInputs),
                Section(title: Strings.bankCard, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: false),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bankCardInputs),
                Section(title: Strings.others, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
                Section(title: Strings.emptyString, imageName: Strings.emptyString, cellStyle: .otherPaymentMethods),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bottomCell)
            ]
        }
        
        if let progress = progress{
            progress.dismiss(animated: true){
                handleData()
                self.tableView.reloadData()
            }
        }else{
            handleData()
            self.tableView.reloadData()
        }
        
    }
    
    func handleOnlyMobileMoney() {
        func handleData(){
            self.data2 = [
                Section(title: "", imageName: "", cellStyle: .receiptHeader),
                Section(title: Strings.payWith, imageName: Strings.emptyString, cellStyle: .payWithTitle),
                Section(title: Strings.mobileMoney, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
                Section(title: "", imageName: "", cellStyle: .momoInputs),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bottomCell)
            ]
        }
        if let progress = progress{
            progress.dismiss(animated: true){
               handleData()
                self.tableView.reloadData()
            }
        }else{
            handleData()
             self.tableView.reloadData()
        }
       
    }
    
    func handleOnlyCheckoutHeader() {
        func handleData(){
            self.data2 = [
                Section(title: "", imageName: "", cellStyle: .receiptHeader),
//                Section(title: Strings.payWith, imageName: Strings.emptyString, cellStyle: .payWithTitle),
//                Section(title: Strings.mobileMoney, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
//                Section(title: "", imageName: "", cellStyle: .momoInputs),
//                Section(title: Strings.emptyString, imageName: "", cellStyle: .bottomCell)
            ]
        }
        if let progress = progress{
            progress.dismiss(animated: true){
               handleData()
                self.tableView.reloadData()
            }
        }else{
            handleData()
             self.tableView.reloadData()
        }
       
    }
    
    func handleOnlyBankPayment() {
        self.usesOnlyBankPayment = true
        func handleData(){
            self.data2 = [
                Section(title: "", imageName: "", cellStyle: .receiptHeader),
                Section(title: Strings.payWith, imageName: Strings.emptyString, cellStyle: .payWithTitle),
                Section(title: Strings.bankCard, imageName: "", cellStyle: .paymentChoiceHeader, hideDivider: true),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bankCardInputs),
                Section(title: Strings.emptyString, imageName: "", cellStyle: .bottomCell)
            ]
        }
        if let progress = progress{
            progress.dismiss(animated: true){
                handleData()
                self.tableView.reloadData()
            }
        }else{
            handleData()
            self.tableView.reloadData()
        }
       
    }
    
    func handleVerificationStatus(value: VerificationResponse?) {
        let textField = view.viewWithTag(Tags.mobileMoneyTextFieldTag)
        self.progress?.dismiss(animated: true){
            if let value = value, let status = value.status{
               switch status.lowercased(){
                    case VerificationStatus.verified.rawValue:
                         self.makeMomoRequest()
               case VerificationStatus.unverified.rawValue:
                   let controller = GovernmentVerificationViewController(verificationDetails: value, customerMsisdn: self.customerMobileNumber ?? (textField as? UITextField)?.text ?? "", provider: self.paymentChannel?.rawValue)
                   self.present(controller, animated: true)
                    default:
                        print("This is the default payment")

                    }
               
            }else{
                let controller = GovernmentIdIntakeViewController()
                controller.msisdn = self.customerMobileNumber ?? (textField as? UITextField)?.text
                let navController = UINavigationController(rootViewController: controller)
                self.present(navController, animated: true)
            }

        }
    }
    
    
}


extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return data2.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = data2[indexPath.row]
        
//        if indexPath.row == 0{
            switch section.cellStyle{
            case .payWithTitle:
                let cell = tableView.dequeueReusableCell(withIdentifier: PayWithTableViewCell.identifier) as! PayWithTableViewCell
                return cell
            case .receiptHeader:
                let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.identifier) as! ReceiptTableViewCell
                cell.setupUI(with: order, totalAmount: self.viewModel.totalAmount)
                cell.setupFeesUpdate(with: viewModel.feesToUpdateFrontend)
                if showFees{
                    dump(viewModel.feeAmount)
                    cell.setupFeesUpdate(with: viewModel.fees)
                }
                cell.receiptView.delegate = self
                cell.setBusinessDetails(imageUrl: businessImage, businessName: businessName)
                return cell
                
            case .momoInputs:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProviderInfoIntakeTableViewCell.identifier, for: indexPath) as! ProviderInfoIntakeTableViewCell
                cell.delegate = self
                cell.validateDelegate = self
                cell.setupProviderString(with: viewModel.providerChannel.getPaymentChannelString())
                cell.configureWallets(wallets: wallets)
                cell.walletAdderDelegate = self
                return cell
            case .bankCardInputs:
                let cell = tableView.dequeueReusableCell(withIdentifier: BankPaymentFieldsTableViewCell.identifier) as! BankPaymentFieldsTableViewCell
                cell.setupUI(value: viewModel.isHubtelInternalMerchant)
                cell.delegate = self
                cell.configureWallets(wallets: BankDetails.getDetails())
                cell.isInternalHubtelMerchant = viewModel.isHubtelInternalMerchant
                cell.menuDelegate = self
                cell.savedCarddelegate = self
                return cell
            case .paymentChoiceHeader:
                let cell = tableView.dequeueReusableCell(withIdentifier: PaymentChoiceTableViewCell.identifier) as! PaymentChoiceTableViewCell
                print(viewModel.imageUpdater)
                cell.render(with: section, imageUpdater: viewModel.imageUpdater)
                cell.hideDivider(with: section.hideDivider)
                if section.isOpened{
                    cell.turnImage()
                }else{
                    cell.revert()
                }
                return cell
            case .otherPaymentMethods:
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherPaymentMethodsTableViewCell.identifier) as! OtherPaymentMethodsTableViewCell
                cell.delegate = self
                cell.otherPaymentChannelChangeDelegate = self
                cell.enterNewMandateSelectorDelegate = self
                cell.configureWallets(wallets: wallets)
                cell.walletAdderDelegate = self
                return cell
            case .bottomCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: BottomCornersTableViewCell.identifier) as! BottomCornersTableViewCell
                return cell
            }
     
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row{
        case 3:
            return showMomoField ? tableView.rowHeight : 0
        case 5:
            return showBankField ? tableView.rowHeight : 0
        case 7:
            return showOtherFieldsTab ? tableView.rowHeight : 0
        default:
            return tableView.rowHeight
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        let section = data2[indexPath.row]
        
        if indexPath.row == 2{
            
            print(paymentProvider)
            print(PaymentChannel.getChannel(string: paymentProvider))
            shadeCellSelected(tableView: tableView, indexPath: indexPath, isSelected: true)
             shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 4, section: 0), isSelected: false)
            shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 6, section: 0), isSelected: false)
            showBankField = false
            showMomoField = true
            showOtherFieldsTab = false
            self.customerMobileNumber = ((self.view.viewWithTag(Tags.momoNumberSelectorTag) as? ProviderSelectorView)?.getProviderString())
            if usesOnlyBankPayment{
                handleBankPaymentLogic()
            }else{
                 paymentType = .momo
                
//                 viewModel.getFees(for: PaymentChannel.getChannel(string: paymentProvider).rawValue)
                
                viewModel.makeGetFeesNewEndPoint(channel: PaymentChannel.getChannel(string: paymentProvider).rawValue, amount: viewModel.order?.amount ?? 0.00)
                
                 let momoTextField = view.viewWithTag(Tags.mobileMoneyTextFieldTag) as? UITextField
                 UIView.animate(withDuration: 0.5) {
                     if self.wallets == nil{
                         momoTextField?.becomeFirstResponder()
                     }
                 }
            }
           
            
            
        }else if indexPath.row == 4 {
            shadeCellSelected(tableView: tableView, indexPath: indexPath, isSelected: true)
             shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 2, section: 0), isSelected: false)
            shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 6, section: 0), isSelected: false)
            showBankField = true
            showMomoField = false
            showOtherFieldsTab = false
            handleBankPaymentLogic()
        }else if indexPath.row == 6 && section.cellStyle != .bottomCell {
            showBankField = false
            showMomoField = false
            showOtherFieldsTab = true
            shadeCellSelected(tableView: tableView, indexPath: indexPath, isSelected: true)
             shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 4, section: 0), isSelected: false)
            shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 2, section: 0), isSelected: false)
            paymentType = (self.view.viewWithTag(Tags.providerWalletTagSelector) as? ProviderSelectorView)?.getPaymentType()
            
            customerMobileNumber = (self.view.viewWithTag(Tags.contactSelectorTag) as? ProviderSelectorView)?.getProviderString() ?? initCustomerMobilerNumber
            
            viewModel.makeGetFeesNewEndPoint(channel: "hubtel-gh", amount: viewModel.order?.amount ?? 0.00)
        }
        
        tableView.performBatchUpdates(nil)
    }
    
    func handleBankPaymentLogic(){
        paymentType = .bank
        paymentChannel = .visa
        
//        viewModel.getFees(for: PaymentChannel.visa.rawValue)
        
        viewModel.makeGetFeesNewEndPoint(channel: PaymentChannel.getChannel(string: paymentProvider).rawValue, amount: viewModel.order?.amount ?? 0.00)
        
        
        if !BankPaymentFieldsTableViewCell.useSavedCardForPayment{
            let bankNameField = self.view.viewWithTag(Tags.accountNameTextFieldTag) as? UITextField
            let accountNumberTextFieldTag =  self.view.viewWithTag(Tags.accountNumberTextFieldTag) as? UITextField
            UIView.animate(withDuration: 0.5) {
                if self.viewModel.isHubtelInternalMerchant{
                    accountNumberTextFieldTag?.becomeFirstResponder()
                }else{
                    bankNameField?.becomeFirstResponder()
                }
                
               
            }
            self.bottomButton.validate(false)
        }else{
            self.bottomButton.validate(true)
        }
    }
    
    func shadeCellSelected(tableView: UITableView,indexPath: IndexPath, isSelected: Bool){
        let cell = tableView.cellForRow(at: indexPath) as? PaymentChoiceTableViewCell
        if isSelected{
            data2[indexPath.row].isOpened = true
            cell?.turnImage()
        }else{
            data2[indexPath.row].isOpened = false
            cell?.revert()
        }
        
    }
    
}
    
    


extension CheckoutViewController{
    fileprivate func registerFonts(){
        if let fontURL = Bundle.module.url(forResource: Strings.regularSans, withExtension: Strings.fontExtension) {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
      
        if let fontURL = Bundle.module.url(forResource: Strings.extraBoldSans, withExtension: Strings.fontExtension) {
          
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
      
        
        if let fontURL = Bundle.module.url(forResource: Strings.sansSemiBold, withExtension: Strings.fontExtension) {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
}

extension CheckoutViewController: BankCellDelegate{
    func activateButton(validate: Bool ) {
      
        bottomButton.validate(validate)
    }
    
    func resizeCell() {
        self.tableView.performBatchUpdates(nil)
    }
    
    func endTableEditing() {
        self.view.endEditing(true)
    }
}

extension CheckoutViewController {
    static func cancelTransaction(viewController:UIViewController?,onCancelled:@escaping ()->Void){
        let alert = UIAlertController(title: Strings.alert , message:Strings.wantToCancelTransaction , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Strings.no, style: .default, handler: {  _ in
            
        }))
        alert.addAction(UIAlertAction(title: Strings.yes, style: .destructive, handler: {  _ in
           onCancelled()
        }))
        
        viewController?.present(alert, animated: true)
    }
}



extension CheckoutViewController: OtherChannelSelectorProtocol, MandateIdSelectorDelegate{
    func enterNewMandateId(value: Bool) {
        self.enterNewMandateId = value
    }
    
    
    func handleOtherPaymentChannelSelected(value: String){
        if value.lowercased() == "hubtel"{
            self.paymentType = .hubtel
            viewModel.makeGetFeesNewEndPoint(channel: "hubtel-gh", amount: viewModel.order?.amount ?? 0.00)
            return
        }
        
        if value.lowercased() == "zeepay"{
            self.paymentType = .zeepay
            viewModel.makeGetFeesNewEndPoint(channel: "zeepay", amount: viewModel.order?.amount ?? 0.00)
            return
        }
        
        if value.lowercased() == "g-money"{
            self.paymentType = .gmoney
            viewModel.makeGetFeesNewEndPoint(channel: "g-money", amount: viewModel.order?.amount ?? 0.00)
            return
        }
    }
    
    func selectChannel(channel: String) {
        handleOtherPaymentChannelSelected(value: channel)
        customerMobileNumber = (self.view.viewWithTag(Tags.contactSelectorTag) as? ProviderSelectorView)?.getProviderString()
        initCustomerMobilerNumber = (self.view.viewWithTag(Tags.contactSelectorTag) as? ProviderSelectorView)?.getProviderString()
    }
    
    
}

extension CheckoutViewController: ButtonActionDelegate{
    
    func payWithHubtelWallet(){
        
        let hubtelWallet = wallets?.first(where: {
            $0.provider?.lowercased() == "hubtel"
        })
        
    
        let formattedAmount = String(format: "%.2f", order?.amount ?? 0.00)
        
        let request = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: hubtelWallet?.accountNo, channel: "hubtel-gh", amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: nil)
        viewModel.paywithMomo(request: request)
    }
    
    func payWithZeePay(){
        payWithMomo()
    }
    
    func payWithGmoney(){
        
        let formattedAmount = String(format: "%.2f", order?.amount ?? 0.00)
        
        let mandateId = MandateIdManager.shared.getMandateIdFromCache()
        
        let request = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber, channel: "g-money", amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: mandateId)
      
        if enterNewMandateId || mandateId == nil{
            let controller = MandateIdIntakeViewController(mobileMoneyRequest: request, delegate: delegate)
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            viewModel.paywithMomo(request: request)
        }
        
        
    }
    
    func performAction() {
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutPayTapButtonPay)
        UserSetupRequirements.shared.resetStates()
        switch paymentType{
        case .bank:
            payWithBank()
        case .momo:
            payWithMomo()
        case .zeepay:
            payWithZeePay()
        case .hubtel:
            payWithHubtelWallet()
        case .gmoney:
            payWithGmoney()
        default:
            print("no payment here")
        }

        
//        self.present(controller, animated: true)
////
////        let controller = FinalSuccessVerificationViewController()
//        self.navigationController?.pushViewController(controller, animated: true)
       
//        let controller = GovernmentIdIntakeViewController()
//        self.present(controller, animated: true)
    }
}

extension CheckoutViewController: ShowMenuItemsDelegate{
    func showMenuForWallet() {
        
        tableView.performBatchUpdates(nil)
        self.tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .bottom, animated: true)
//        
//        self.view.layoutIfNeeded()
    }
    
    func updatePaymentDetails(contact: String, provider: String) {
        print(provider)
        if contact.isEmpty{
            self.paymentProvider = PaymentChannel.getChannel(string: provider).rawValue
            viewModel.makeGetFeesNewEndPoint(channel: PaymentChannel.getChannel(string: provider).rawValue, amount: viewModel.order?.amount ?? 0.00)
            return
        }
        self.customerMobileNumber = contact
        self.paymentProvider = PaymentChannel.getChannel(string: provider).rawValue
        
        viewModel.makeGetFeesNewEndPoint(channel: PaymentChannel.getChannel(string: provider).rawValue, amount: viewModel.order?.amount ?? 0.00)
    }
    
    
    
    func showPopOver() {
      let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: alertWidth, height: alertHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: alertWidth, height: alertHeight))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select a momo provider", message: "", preferredStyle: .actionSheet)
        if let myView = view.viewWithTag(Tags.mobileMoneySectionCellTag){
            alert.popoverPresentationController?.sourceView = myView
            alert.popoverPresentationController?.sourceRect = myView.bounds
            alert.setValue(vc, forKey: "contentViewController")
        }
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { action in
            let selectedValue = pickerView.selectedRow(inComponent: 0)
        
          
            let myView = self.view.viewWithTag(Tags.mobileMoneySectionCellTag) as? ProviderInfoIntakeTableViewCell
            
            myView?.setupProviderString(with:Array(PaymentOptions.options.keys)[selectedValue])
            
            print(PaymentOptions.options.keys)
            
            print(Array(PaymentOptions.options.keys)[selectedValue])
            
            self.paymentProvider = PaymentOptions.options[Array(PaymentOptions.options.keys)[selectedValue]] ?? ""
            
            print("\n\n\(PaymentChannel(rawValue: self.paymentProvider))")
            
            self.paymentChannel = PaymentChannel(rawValue: self.paymentProvider)

            self.viewModel.makeGetFeesNewEndPoint(channel: PaymentChannel.getChannel(string: self.paymentProvider).rawValue, amount: self.order?.amount ?? 0.00)
            print(self.paymentChannel)
            print(self.paymentProvider)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("action")
        }))
        
        self.present(alert, animated: true)
        
    }
   
    
    
}

extension CheckoutViewController{
   
    
    func payWithBank() {
        let cardNumberFieldText = (view.viewWithTag(Tags.accountNumberTextFieldTag) as? CustomTextField)?.getInputTextWithoutSpace()
        
        let expiryDetails = (view.viewWithTag(Tags.expiryDateTextFieldTag) as? CustomTextField)?.getInputText().getExpiryInfo()
        
        let cvv = (view.viewWithTag(Tags.cvvTextFieldTag) as? CustomTextField)?.getInputText()
        
        let cardHolderName =  (view.viewWithTag(Tags.accountNameTextFieldTag) as? CustomTextField)?.getInputText()
        
        let switcherValue = (view.viewWithTag(Tags.switcherTag) as? UISwitch)?.isOn
        
        let cardDetails = BankDetails(cardHolderName: cardHolderName ?? "", cardHolderNumber: cardNumberFieldText ?? "", cvv: cvv ?? "", expiryMonth: expiryDetails?.month ?? "", expiryYear: expiryDetails?.year ?? "")
        
                if switcherValue ?? false{
//                    cardDetails.save()
                    cardDetails.saveToDb()
                }
        
        let requestBody : SetupPayerAuthRequest?
        
        print(BankPaymentFieldsTableViewCell.useSavedCardForPayment)
        
        if BankPaymentFieldsTableViewCell.useSavedCardForPayment{
            requestBody = viewModel.generateSetupRequest(with: viewModel.bankCardForPayment, useSavedCard: BankPaymentFieldsTableViewCell.useSavedCardForPayment)
        }else{
            requestBody = viewModel.generateSetupRequest(with: cardDetails)
        }
        
        dump(requestBody)
       
        viewModel.payWithBank(with: requestBody)

        
  }
                
    
    
    
    func makeMomoRequest(checkoutChannel: String? = nil){

        let channel = paymentProvider
        
        let textField = view.viewWithTag(Tags.mobileMoneyTextFieldTag)
        
        let formattedAmount = String(format: "%.2f", order?.amount ?? 0.00)
        
        let momoRequest = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, channel:checkoutChannel ?? channel, amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription ?? "", clientReference: order?.clientReference, mandateId: nil)
        
        switch CheckOutViewModel.checkoutType{
        case .preapprovalconfirm:
            viewModel.makePreapprovalConfirm(body: momoRequest)
        case .receivemoneyprompt:
            let momoRequest = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, channel: channel, amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: nil)
            viewModel.paywithMomo(request: momoRequest)
        case .directdebit:
            let directDebitRequest  = MakeDirectDebitCallBody(channel: "\(channel)-direct-debit", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, primaryCallbackUrl: callbackUrl, clientReference: order?.clientReference, amount:formattedAmount, description: order?.purchaseDescription)
            viewModel.makeDirectDebit(request: directDebitRequest)
        
        }
    }
    
    func payWithMomo() {
        print(paymentProvider)
        let amount = self.viewModel.totalAmount.roundValue(toPlaces: 2)
        let channel = paymentProvider
        let textField = view.viewWithTag(Tags.mobileMoneyTextFieldTag)
        
        let formattedAmount = String(format: "%.2f", order?.amount ?? 0.00)
        
        let mobileNumberText = customerMobileNumber ?? (textField as? UITextField)?.text
        
        let momoRequest = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, channel: channel, amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: nil)
//
//        viewModel.momoNumber = (textField as? UITextField)?.text
//        viewModel.paywithMomo(request: momoRequest)
//
       
        let directDebitRequest  = MakeDirectDebitCallBody(channel: "\(channel)-direct-debit", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, primaryCallbackUrl: callbackUrl, clientReference: order?.clientReference, amount:formattedAmount, description: order?.purchaseDescription)
        
        let preApprovalCall = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, channel: channel.contains("tigo") ? channel : "\(channel)-direct-debit", amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: nil)
        
        viewModel.momoNumber = customerMobileNumber ?? (textField as? UITextField)?.text
        
        if paymentType == .zeepay{
            let request = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: customerMobileNumber ?? (textField as? UITextField)?.text, channel: "zeepay", amount: formattedAmount, primaryCallbackUrl: callbackUrl, description: order?.purchaseDescription, clientReference: order?.clientReference, mandateId: nil)
            viewModel.paywithMomo(request: request)
            return
        }
        
        switch CheckOutViewModel.checkoutType{
        case .receivemoneyprompt:
            if viewModel.merchantRequiresKyc{
                continueToKycFlow(mobileNumber: mobileNumberText ?? "")
                return
            }
            viewModel.paywithMomo(request: momoRequest)
        case .directdebit:
            viewModel.makeDirectDebit(request: directDebitRequest)
        case .preapprovalconfirm:
            if viewModel.merchantRequiresKyc{
                continueToKycFlow(mobileNumber: mobileNumberText ?? "")
                return
            }
           
            viewModel.makePreapprovalConfirm(body: preApprovalCall)
        default:
            viewModel.paywithMomo(request: momoRequest)
        }
        
        
    }
    
    func continueToKycFlow(mobileNumber: String){
        self.viewModel.checkUserVerificationStatus(mobileNumber: mobileNumber)
    }
    
    
}



class CustomPopoverBackgroundView: UIPopoverBackgroundView {

    override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override static func arrowHeight() -> CGFloat {
        return 0.0 // Set the arrow height to 0 to remove the arrow
    }
    
    override static func arrowBase() -> CGFloat {
        return 0.0 // Set the arrow base width to 0 to remove the arrow
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return .any // Set the arrow direction to .any to hide it
        }
        set {
            // No need to do anything here since we're overriding the getter and setter
        }
    }
    
    override var arrowOffset: CGFloat {
        get {
            return 0.0 // Set the arrow offset to 0 to remove the arrow
        }
        set {
            // No need to do anything here since we're overriding the getter and setter
        }
    }
}


extension CheckoutViewController: ReceiptHeaderViewDelegate{
    func handleWalletsUpdate(value: [Wallet]) {
        self.progress?.dismiss(animated: true)
        self.wallets = value
        let wallet: Wallet? = value.count > 0 ? value[0] : nil
        
        self.customerMobileNumber = wallet?.accountNo
        
        self.paymentProvider = PaymentChannel.getChannel(string:wallet?.provider ?? "").rawValue
        
        self.tableView.reloadData()
        
        
        self.view.layoutIfNeeded()
//        tableView.performBatchUpdates(nil)
       
    }
}


extension CheckoutViewController: SavedCardPaymentDelegate{
    func payWithSavedCard(card: BankDetails?) {
        self.viewModel.bankCardForPayment = card
    }
    
    
}


extension CheckoutViewController: AddMobileWallet{
    func addMobileWallet() {
        let controller = AddMobileWalletViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

