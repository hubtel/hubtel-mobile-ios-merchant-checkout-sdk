//
//  CheckTransactionStatusViewController.swift
//  
//
//  Created by Mark Amoah on 6/20/23.
//

import UIKit

class CheckTransactionStatusViewController: UIViewController {
    var transactionId: String?
    var mobileNumber: String?
    var timer: Timer? = nil
    var seconds  = 5
    var mobileMoneyConfirmed: Bool = false
    var checkStatusCount: Int = 0
    var transactionStatusCheck: PaymentStatus?
    weak var delegate: PaymentFinishedDelegate?
    var imageString: String?
    var provider: String?
    var transactionDetails: MomoResponse?
    var clientReference: String?
    var amountPaid: Double?
    var amount: Double{
        Double(transactionDetails?.amount ?? amountPaid ?? 0.00)
    }
    
    lazy var viewModel = CheckoutTransactionStatusViewModel(delegate: self)
    
    static func openTransactionHistory(navController: UINavigationController?, transactionId: String, text: String, provider: String? = nil, delegate: PaymentFinishedDelegate?, transactionDetails: MomoResponse? = nil, clientReference: String? = nil, amountPaid: Double? = nil){
        let controller = CheckTransactionStatusViewController()
        controller.transactionId = transactionId
        controller.setDescriptionLabelText(value: text)
        controller.delegate = delegate
        controller.provider = provider
        controller.transactionDetails = transactionDetails
        controller.clientReference = clientReference
        controller.amountPaid = amountPaid
        navController?.pushViewController(controller, animated: true)
    }
    
    let promptHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4, weight: .bold)
        label.text = "Not receiving a payment prompt?"
        label.textColor = Colors.appGreySecondary
        return label
    }()
    
    
    
    let additionalMtnInformation: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = FontManager.getAppFont(size: .m4, weight: .regular)
        view.textColor = Colors.appGreySecondary
        let style = NSMutableParagraphStyle()
        style.headIndent = 1
        style.alignment = .left
        let title = NSMutableAttributedString(string: "Follow the steps below to authorize payment requests ", attributes: [NSAttributedString.Key.paragraphStyle: style])

        let title1Str = NSMutableAttributedString(string: "\n 1.  Dial *170# and select Option 6, ", attributes: [NSAttributedString.Key.paragraphStyle: style])
        let mWalletStr = NSMutableAttributedString(string: "My Wallet.", attributes: [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: FontManager.getAppFont(size: .m4, weight: .bold)])
        let approvalStr = NSMutableAttributedString(string: "My Approvals.", attributes: [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: FontManager.getAppFont(size: .m4, weight: .bold)])
        let title2Str = NSMutableAttributedString(string: "\n 2. Select Option 3 for ", attributes: [NSAttributedString.Key.paragraphStyle: style])
        let title3Str = NSMutableAttributedString(string: "\n 3.  Enter PIN to get your Pending Approval List.", attributes: [NSAttributedString.Key.paragraphStyle: style])

    
        let title4Str = NSMutableAttributedString(string: "\n 4. Select pending transaction to approve.", attributes: [NSAttributedString.Key.paragraphStyle: style ])

        let title5Str = NSMutableAttributedString(string: "\n 5. Pay", attributes: [NSAttributedString.Key.paragraphStyle: style])
        title1Str.append(mWalletStr)
        title2Str.append(approvalStr)
        title.append(title1Str)
        title.append(title2Str)
        title.append(title3Str)
        title.append(title4Str)
        title.append(title5Str)
        view.attributedText = title
        return view
    }()
    
    lazy var mtnInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [promptHeader, additionalMtnInformation])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.distribution = .fill
        stack.isHidden = !((provider == "mtn-gh") && CheckOutViewModel.checkoutType == .receivemoneyprompt)
        return stack
    }()
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.validate(true)
        button.delegate = self
        button.setButtonTitle(with: "I HAVE PAID")
        return button
    }()
    
    let receiptImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.image = UIImage(named: "payment_status", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        }else{
            view.image = UIImage(named: "payment_status")
        }
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bottomButton)
        self.view.addSubview(receiptImageView)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(mtnInfoStack)
        setupConstraints()
//        mtnInfoStack.isHidden = true
        UserSetupRequirements.shared.userCheckStatusReached = true
        
        view.backgroundColor = .white
        navigationItem.titleView = NotificationBarHeader(title: "Confirm Order")
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelMomoOperation))
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutCheckStatusViewPageCheckStatus)
    }
    
    func setupConstraints(){
        let bottomButtonConstraints = [
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(bottomButtonConstraints)
        
        let receiptImageViewConstraints = [
            receiptImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            receiptImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  !((provider == "mtn-gh") && CheckOutViewModel.checkoutType == .receivemoneyprompt) ? 0 : -100),
        ]
        NSLayoutConstraint.activate(receiptImageViewConstraints)
        
        let descriptionLabelConstraints = [
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            descriptionLabel.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(descriptionLabelConstraints)
        
        let imageConstraints = [
            receiptImageView.heightAnchor.constraint(equalToConstant: 75),
            receiptImageView.widthAnchor.constraint(equalToConstant: 75)
        ]
        NSLayoutConstraint.activate(imageConstraints)
        
        let mtnInfoStackConstraints = [
            mtnInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mtnInfoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mtnInfoStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32)
        ]
        NSLayoutConstraint.activate(mtnInfoStackConstraints)
    }
    
    func setDescriptionLabelText(value: String){
        self.descriptionLabel.text = value
    }
    
    func replaceImage(with imageString: String){
        UIView.transition(with: receiptImageView, duration: 0.5) {
            if #available(iOS 13.0, *) {
                self.receiptImageView.image = UIImage(named: imageString, in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
            }else{
                self.receiptImageView.image = UIImage(named: imageString)
            }
        }
    }

    
    @objc func cancelMomoOperation(){
        AnalyticsHelper.recordCheckoutEvent(event: .checkoutCheckStatusTapCancel)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CheckTransactionStatusViewController: ButtonActionDelegate{
    func performAction() {
//       checkStatusCount += 1
        if let buttonTitle = bottomButton.getButtonTitle(){
            switch buttonTitle {
            case "I HAVE PAID":
                AnalyticsHelper.recordCheckoutEvent(event: .checkoutCheckStatusTapIHavePaid)
            case "CHECK AGAIN":
                AnalyticsHelper.recordCheckoutEvent(event: .checkoutCheckStatusTapCheckAgain)
            default:
                print("nothing happening here")
            }
        }
       
       
        if  mobileMoneyConfirmed{
            if General.usePresentation{
                self.dismiss(animated: true){
            
                    self.delegate?.checkStatus(value: self.transactionStatusCheck ?? .paymentFailed)
                    General.usePresentation = false
                }
            }else{
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: true)
                self.delegate?.checkStatus(value: self.transactionStatusCheck ?? .paymentFailed)
            }
        }else{

        bottomButton.showLoader(value: true, name: "I HAVE PAID")
        
            if CheckOutViewModel.checkoutType == .directdebit{
                viewModel.checkTransactionStatus(clientReference: self.transactionDetails?.clientReference ?? clientReference  ?? self.transactionId ?? "")
            }else{
                viewModel.checkTransactionStatus(clientReference: self.transactionId ?? "")
            }
//
           
        }
    }
    
    @objc func countDownToenableButton(){
        self.bottomButton.showLoader(value: false, name: Strings.checkStatus )
        seconds -= 1
        self.bottomButton.validate(false)
        self.bottomButton.setButtonTitle(with: "\(Strings.checkStatus) (00 : 0\(seconds))")
        if seconds == 0 {
            self.timer?.invalidate()
            self.timer = nil
            self.bottomButton.validate(true)
            self.bottomButton.showLoader(value: false, name: "CHECK AGAIN")
            self.seconds = 5
//            if checkStatusCount == 3{
//                self.replaceImage(with:"statusmessage")
//                self.bottomButton.showLoader(value: false, name: "DONE")
//                self.mobileMoneyConfirmed = true
//                self.descriptionLabel.text = "Transaction Failed"
//            }
        }
    }
    
}

extension CheckTransactionStatusViewController: CheckoutTransactionStatusDelegate{
    func transactionFailed() {
        self.descriptionLabel.text = "Transaction Failed"
        imageString = "statusmessage"
        self.bottomButton.showLoader(value: false, name: "DONE")
        self.mobileMoneyConfirmed = true
        self.transactionStatusCheck = .paymentFailed
        UserSetupRequirements.shared.userTransactionFailed = true
        UserSetupRequirements.shared.userTransactionSucceeded = false
        
    }
    
    func transactionPending() {
        self.descriptionLabel.text = "Your payment is being processed. Tap the \" Check Again\" button to confirm final payment status"
        imageString = "pending_payment"
        self.bottomButton.validate(false)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownToenableButton), userInfo: nil, repeats: true)
    }
    
    func transactionSucceeded() {
        self.descriptionLabel.text = "Your payment was successful. Thank you for choosing us."
        imageString = "complete_checkmark_teal"
        self.mobileMoneyConfirmed = true
//                            self.bottomButton.setButtonTitle(with: "Done")
        self.transactionStatusCheck = .paymentSuccessful
        self.bottomButton.showLoader(value: false, name: "DONE")
        UserSetupRequirements.shared.userTransactionSucceeded = true
        UserSetupRequirements.shared.userTransactionFailed = false
    }
    
    func showErrorMessageToUser(message: String) {
        showAlert(with: "Error", message: message)
        self.bottomButton.showLoader(value: false, name: "Check Again")
    }
    
    func validateAndSetTimer() {
        self.bottomButton.validate(false)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownToenableButton), userInfo: nil, repeats: true)
    }
    
    func changeImageOnScreen() {
        self.replaceImage(with: imageString ?? "")
    }
    
}
