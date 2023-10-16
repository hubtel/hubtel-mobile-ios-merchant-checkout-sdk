//
//  MandateIdIntakeViewController.swift
//  
//
//  Created by Mark Amoah on 10/4/23.
//

import UIKit

class MandateIdIntakeViewController: UIViewController {
    
    var progress: UIAlertController?
    
    lazy var viewModel = CheckOutViewModel(delegate: self)
    
    var buttonConstraint: NSLayoutConstraint!
    
    var momoRequest: MobileMoneyPaymentRequest?
    
    weak var delegate: PaymentFinishedDelegate?
    
    lazy var idInputter: IDVerificationTextFieldView = {
        let view = IDVerificationTextFieldView(placeHoleder: "Enter Mandate ID", HeaderText: Strings.mandateIdTitle)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.addTarget(self, action: #selector(validateField(_:)), for: .editingChanged)
        return view
        
    }()
    
    
    let gmoneyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = Strings.generateMandateIdDescriptionText(); label.numberOfLines = 0
        return label
    }()
    
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonTitle(with: "CONTINUE")
        button.validate(false)
        button.delegate = self
        return button
    }()
    
    //Perform Validation
    
    init(mobileMoneyRequest: MobileMoneyPaymentRequest, delegate: PaymentFinishedDelegate?){
        super.init(nibName: nil, bundle: nil)
        self.momoRequest = mobileMoneyRequest
        self.viewModel.momoNumber = mobileMoneyRequest.customerMsisdn
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = Strings.mandateIdTitle
        subscribeToShowKeyboardNotifications()
        setupViews()
    }
    
    @objc func validateField(_ sender: UITextField){
        if sender.text!.count < 1{
            bottomButton.validate(false)
        }else{
            bottomButton.validate(true)
        }
    }
    
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        print(UIScreen.main.bounds.height)
        switch UIScreen.main.bounds.height{
        case 600...813:
            buttonConstraint.constant = -keyboardHeight  + 30
        default:
            buttonConstraint.constant = -keyboardHeight + 30
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
    
    
    private func setupViews(){
        
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 23, leading: 16, bottom: 0, trailing: 16)
        
        view.addSubviews(idInputter,  gmoneyDescriptionLabel, bottomButton)
        
        setupConstraints()
    }
    

    func setupConstraints(){
        let idInputterConstraints = [
            idInputter.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            idInputter.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            idInputter.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(idInputterConstraints)
        
        
        let bottomButtonConstraints = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           
        ]
        buttonConstraint =  bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        buttonConstraint.isActive = true
        NSLayoutConstraint.activate(bottomButtonConstraints)
        
        let gmoneyDescritionConstraints  = [
            gmoneyDescriptionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            gmoneyDescriptionLabel.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            gmoneyDescriptionLabel.topAnchor.constraint(equalTo: idInputter.bottomAnchor, constant: 16)
            
        ]
        NSLayoutConstraint.activate(gmoneyDescritionConstraints)
    }

}


extension MandateIdIntakeViewController: ButtonActionDelegate{
    
    func performAction() {
        momoRequest?.mandateId = idInputter.textField.text?.trimmingCharacters(in: .whitespaces)
        print(momoRequest)
        if let momoRequest = momoRequest{
            viewModel.paywithMomo(request: momoRequest)
        }
       
    }
    
}

extension MandateIdIntakeViewController: ViewStatesDelegate{
    
    func showLoadingStateWhileMakingNetworkRequest(with value: Bool) {
        self.progress = showNetworkCallProgress(isCancellable: true)
    }
    
    func showErrorMessagetToUser(message: String) {
        self.progress?.dismiss(animated: true){
            self.showAlert(with: "Error", message: message)
        }
    }
    
    func dismissLoaderToPerformMomoPayment() {
        progress?.dismiss(animated: true){
            MandateIdManager.shared.mandateId = self.idInputter.textField.text?.trimmingCharacters(in: .whitespaces)
            CheckTransactionStatusViewController.openTransactionHistory(navController: self.navigationController, transactionId: self.viewModel.momoResponse?.clientReference ?? "", text: Strings.directDebitText,provider: "g-money", delegate: self.delegate, transactionDetails: self.viewModel.momoResponse, clientReference: self.viewModel.order?.clientReference, amountPaid: self.viewModel.totalAmount)
        }
    }
    
}
