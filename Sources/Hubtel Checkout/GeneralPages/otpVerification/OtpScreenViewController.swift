//
//  OtpScreenViewController.swift
//  
//
//  Created by Mark Amoah on 9/17/23.
//

import UIKit

class OtpScreenViewController: UIViewController {
    
    var progress: UIAlertController?
    
    var buttonConstraint: NSLayoutConstraint!
    
    var amount: Double?
    
    var checkoutType: CheckoutType? = nil
    
    private var otpString: String?
    
    private var otpResponse: PreApprovalResponse?
    
    var clientReference: String?
    
    lazy var viewModel = OtpRequestViewModel(delegate: self)
    
    let hubtelIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    let otpHeader: MyCustomLabel = MyCustomLabel(text: "", font: FontManager.getAppFont(size: .m4))
    
    let otpError: MyCustomLabel = MyCustomLabel(text: "The OTP you have entered is incorrect", font: FontManager.getAppFont(size: .m4), color: UIColor.red)
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonTitle(with: "Verify")
        button.delegate = self
        return button
    }()
    
    lazy var pinView: OTPFieldView = {
        let otpTextFieldView = OTPFieldView(frame: .zero)
        otpTextFieldView.fieldsCount = 4
        otpTextFieldView.fieldBorderWidth = 2
        otpTextFieldView.defaultBorderColor = UIColor.clear
        otpTextFieldView.defaultBackgroundColor = Colors.appGreyDark
        otpTextFieldView.filledBackgroundColor = Colors.appGreyDark
        otpTextFieldView.cursorColor = UIColor.red
        otpTextFieldView._DisplayType = _DisplayType.roundedCorner
        otpTextFieldView.fieldSize = 64
        otpTextFieldView.separatorSpace = 64/2
        otpTextFieldView.shouldAllowIntermediateEditing = true
        otpTextFieldView.delegate = self
        otpTextFieldView.secureEntry = false
        otpTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return otpTextFieldView
    }()
    
    func handleOtpEnteredComplete(){
        self.bottomButton.validate(true)
        
        let otpString = "\(otpResponse?.otpPrefix ?? "")-\(self.otpString ?? "")"
        
        let otpRequest = OtpBodyRequest(customerMsisdn: otpResponse?.customerMsisdn ?? "", hubtelPreApprovalId: otpResponse?.hubtelPreapprovalId, clientReferenceId: otpResponse?.clientReference ?? clientReference, otpCode: otpString)
        print(otpRequest)
        
        self.viewModel.makeotpVerification(body: otpRequest)
        
        
        
    }
    
    
    init(mobileNumber: String, preapprovalResponse: PreApprovalResponse?, amount: Double? = nil, checkoutType: CheckoutType? = nil, clientReference: String? = nil ){
        super.init(nibName: nil, bundle: nil)
        self.otpHeader.text = Strings.generateOtpPromptText(mobileNumber: mobileNumber, otpPrefix: preapprovalResponse?.otpPrefix ?? "")
        self.otpResponse = preapprovalResponse
        
        let hubtelLogoImage: UIImage?
        
        if #available(iOS 13.0, *) {
            hubtelLogoImage = UIImage(named: "hubtel_icon", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            hubtelLogoImage = UIImage(named: "nil")
        }
        
        self.hubtelIconImage.image = hubtelLogoImage
        self.amount = amount
        self.checkoutType = checkoutType
        self.clientReference = clientReference
        otpError.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify"
        subscribeToShowKeyboardNotifications()
        self.view.addSubviews(hubtelIconImage, otpHeader, bottomButton, pinView, otpError)
        setupConstraints()
        pinView.initializeUI()
        view.backgroundColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        pinView.initializeUI()
        (view.viewWithTag(1) as? OTPTextField)?.becomeFirstResponder()
    }
    
    
    
    
    func setupConstraints(){
        let  buttonConstraints = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ]
        
       buttonConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        buttonConstraint.isActive = true
        
        NSLayoutConstraint.activate(buttonConstraints)
        
        let otpHeaderConstraints = [
            hubtelIconImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            hubtelIconImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(otpHeaderConstraints)
        
        
        let otpTextConstraints = [
            otpHeader.topAnchor.constraint(equalTo: hubtelIconImage.bottomAnchor, constant: 30),
            otpHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            otpHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(otpTextConstraints)
        
        let pinViewConstraints = [
            pinView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pinView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pinView.topAnchor.constraint(equalTo: otpHeader.bottomAnchor, constant: 16),
            pinView.heightAnchor.constraint(equalToConstant: 70)
        ]
        NSLayoutConstraint.activate(pinViewConstraints)
        
        let otpErrorViewConstraints = [
            otpError.leadingAnchor.constraint(equalTo: pinView.leadingAnchor),
            otpError.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 8),
        ]
        NSLayoutConstraint.activate(otpErrorViewConstraints)
        
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pinView.fieldSize = 100
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        print(UIScreen.main.bounds.height)
        switch UIScreen.main.bounds.height{
        case 600...813:
            buttonConstraint.constant = -keyboardHeight+8
        default:
            buttonConstraint.constant = -keyboardHeight+8
        }
            
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        switch UIScreen.main.bounds.height{
        case 600...813:
            buttonConstraint.constant = -10
        default:
            buttonConstraint.constant = 0
        }
            
        
    }
    

    
}

extension OtpScreenViewController: ViewStatesDelegate{
    
    func dismissLoaderToPerformMomoPayment() {
        progress?.dismiss(animated: true){
            
            if self.checkoutType == .directdebit{
                CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.clientReference ?? self.otpResponse?.clientReference ?? "", text: Strings.directDebitText, delegate: nil)
                return
            }
           
            let controller = PreApprovalSuccessVcViewController(walletName: "mobile wallet", amount: self.amount ?? 0.00)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showLoadingStateWhileMakingNetworkRequest(with value: Bool) {
        self.progress = showProgress(isCancellable: true)
    }
    
    func showErrorMessagetToUser(message: String) {
//        self.bottomButton.validate(false)
        otpError.isHidden = false
        if let progress = progress{
            progress.dismiss(animated: true){
                self.showAlert(with: "Error",message: message)
            }
        }else{
            showAlert(with: "Error",message: message)
        }
    }
    
}



extension OtpScreenViewController : OTPFieldViewDelegate, ButtonActionDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String, view: OTPFieldView) {
//       self.beganEnteringOTP(otp)
       self.otpString = otp
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        if hasEnteredAll {
            self.handleOtpEnteredComplete()
            
        }else{
            bottomButton.validate(false)
        }
        
        return false
    }
    
    func currentOTPView(view: OTPFieldView) {
        
    }
    
//    func getOtpString()->String{
//        return   ""
//    }
    func performAction() {
        handleOtpEnteredComplete()
    }

    
   
    
}
