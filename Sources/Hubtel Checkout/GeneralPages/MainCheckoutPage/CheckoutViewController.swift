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
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
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
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            if isKeyboardShowing {
                bottomConstraint?.constant =  -keyboardFrame!.height
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true
                    )
                }
            }else{
                bottomConstraint?.constant =  0
            }
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
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
            bottomButton.showLoader(value: false, name: "PAY")
        }
    }
    
    func updateFeesValue(value: Double) {
        (self.view.viewWithTag(Tags.receiptHeaderViewTag) as? ReceiptHeaderView)?.setFees(value: String(value))
        ( self.view.viewWithTag(Tags.receiptHeaderViewTag) as? ReceiptHeaderView)?.updateTotalValue(value: String(  self.order?.updateItemPrice(value: value) ?? 0.00))
    }
    
    func updateFeesValue(value: [GetFeesUpdateView]){
        print(value)
//        (self.view.viewWithTag(Tags.receiptHeaderViewTag) as? ReceiptHeaderView)?.setupFees(value: value)
        CheckOutViewModel.allowPayment = true
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.performBatchUpdates(nil)
        
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
        self.progress = showProgress(isCancellable: true)
    }
    
    func dismissLoaderToPerformAnotherAction() {
        progress?.dismiss(animated: true){
            
        }
    }
    
    func dismissLoaderToPerformWebCheckout() {
        progress?.dismiss(animated: true){
            CheckoutWebViewController.openWebViewForPayment(parentController: self, setupResponse: self.viewModel.setupResponse, with: self.viewModel.merchantApiKey ?? "", delegate: self.delegate, usePresentation: self.presentingViewController != nil)
        }
    }
    
    func dismissLoaderToPerformMomoPayment(){
        progress?.dismiss(animated: true){
            self.showAlert(with: Strings.success, message: Strings.setMomoPrompt(with: self.viewModel.momoNumber ?? "")){ action in
                CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.setMomoPrompt(with: self.viewModel.momoNumber ?? ""),provider: self.paymentProvider, delegate: self.delegate)
            }
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
                cell.setupFeesUpdate(with: viewModel.fees)
                return cell
            case .momoInputs:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProviderInfoIntakeTableViewCell.identifier, for: indexPath) as! ProviderInfoIntakeTableViewCell
                cell.delegate = self
                cell.validateDelegate = self
                cell.setupProviderString(with: Array(PaymentOptions.options.keys).count > 0 ? Array(PaymentOptions.options.keys)[0] : "")
                return cell
            case .bankCardInputs:
                let cell = tableView.dequeueReusableCell(withIdentifier: BankPaymentFieldsTableViewCell.identifier) as! BankPaymentFieldsTableViewCell
                cell.delegate = self
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
        default:
            return tableView.rowHeight
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.row == 2{
            print(paymentProvider)
            print(PaymentChannel.getChannel(string: paymentProvider))
            shadeCellSelected(tableView: tableView, indexPath: indexPath, isSelected: true)
             shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 4, section: 0), isSelected: false)
            showBankField = false
            showMomoField = true
            if usesOnlyBankPayment{
                handleBankPaymentLogic()
            }else{
                 paymentType = .momo
                 viewModel.getFees(for: PaymentChannel.getChannel(string: paymentProvider).rawValue)
                 let momoTextField = view.viewWithTag(Tags.mobileMoneyTextFieldTag) as? UITextField
                 UIView.animate(withDuration: 0.5) {
                     momoTextField?.becomeFirstResponder()
                 }
            }
           
            
            
        }else if indexPath.row == 4{
            shadeCellSelected(tableView: tableView, indexPath: indexPath, isSelected: true)
             shadeCellSelected(tableView: tableView, indexPath: IndexPath(row: 2, section: 0), isSelected: false)
            showBankField = true
            showMomoField = false
            handleBankPaymentLogic()
        }
        
        tableView.performBatchUpdates(nil)
    }
    
    func handleBankPaymentLogic(){
        paymentType = .bank
        paymentChannel = .visa
        viewModel.getFees(for: PaymentChannel.visa.rawValue)
        if !BankPaymentFieldsTableViewCell.useSavedCardForPayment{
            let bankNameField = self.view.viewWithTag(Tags.accountNameTextFieldTag) as? UITextField
            UIView.animate(withDuration: 0.5) {
                bankNameField?.becomeFirstResponder()
            }
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


extension CheckoutViewController: ButtonActionDelegate{
    func performAction() {
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutPayTapButtonPay)
        UserSetupRequirements.shared.resetStates()
        switch paymentType{
        case .bank:
            payWithBank()
        case .momo:
            payWithMomo()
        default:
            print("no payment here")
        }

        
        
    }
}

extension CheckoutViewController: ShowMenuItemsDelegate{
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
            self.paymentProvider = PaymentOptions.options[Array(PaymentOptions.options.keys)[selectedValue]] ?? ""
            self.paymentChannel = PaymentChannel(rawValue: self.paymentProvider)
            self.viewModel.getFees(for: PaymentChannel.getChannel(string: self.paymentProvider).rawValue)
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
                let uuid = UUID()
        
        
                let cardDetails = BankDetails(cardHolderName: cardHolderName ?? "", cardHolderNumber: cardNumberFieldText ?? "", cvv: cvv ?? "", expiryMonth: expiryDetails?.month ?? "", expiryYear: expiryDetails?.year ?? "")
        
                if switcherValue ?? false{
                    cardDetails.save()
        //            cardDetails.saveToDb()
                }
        let requestBody = viewModel.generateSetupRequest(with: cardDetails, useSavedCard: BankPaymentFieldsTableViewCell.useSavedCardForPayment)
        
        viewModel.payWithBank(with: requestBody)
//        let controller = UINavigationController(rootViewController:CardVerificationViewController())
//        controller.modalTransitionStyle = .crossDissolve
//        controller.presentationController?.delegate = ModalPresentationDelegate.shared
//        self.present(controller, animated: true)
//        dump(viewModel.cardWhitelistCheckResponseObj?.fraudLabsStatus)
//        viewModel.handleBankPaymentWhitelist()
        
  }
                
    
    
    
    
    func payWithMomo() {
        let amount = self.viewModel.totalAmount
        let channel = paymentProvider
        let textField = view.viewWithTag(Tags.mobileMoneyTextFieldTag)
        let uuid = UUID()
        print(channel)
        let momoRequest = MobileMoneyPaymentRequest(customerName: "", customerMsisdn: (textField as? UITextField)?.text, channel: channel, amount: amount, primaryCallbackUrl: callbackUrl, description: description, clientReference: order?.clientReference)
    
        viewModel.momoNumber = (textField as? UITextField)?.text
        viewModel.paywithMomo(request: momoRequest)
        
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
