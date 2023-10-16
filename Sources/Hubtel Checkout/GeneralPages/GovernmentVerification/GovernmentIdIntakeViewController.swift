//
//  GovernmentIdIntakeViewController.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class GovernmentIdIntakeViewController: UIViewController {
    
    let viewModel = GovVerificationViewModel()
    
    var progress : UIAlertController?
    
    var buttonConstraint: NSLayoutConstraint!
    var pageHeaderConstraint: NSLayoutConstraint!
    var inputterConstraint: NSLayoutConstraint!
    
    var msisdn: String?
    
    
    let pageHeader: PageHeadersView = {
        
        let view = PageHeadersView(imageName: "ic_verify_id", headerTitle: "Verify your Government ID", headerSubtitle: "Your government-issued ID is required to raise your transaction limit and verify your legal identity/status", frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var idInputter: IDVerificationTextFieldView = {
        let view = IDVerificationTextFieldView(placeHoleder: "ABC - XXXXXXXXXX - X", HeaderText: "Ghana Card")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.addTarget(self, action: #selector(validateField(_:)), for: .editingChanged)
        return view
        
    }()
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.setButtonTitle(with: "Submit")
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.actionFired = {
//            self.performApiRequest()
//        }
        button.delegate = self
        return button
    }()
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        print(UIScreen.main.bounds.height)
        switch UIScreen.main.bounds.height{
        case 600...813:
            buttonConstraint.constant = -keyboardHeight+8
//            inputterConstraint.constant = 10
            pageHeaderConstraint.constant = 10
        default:
            buttonConstraint.constant = -keyboardHeight+8
        }
            
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        switch UIScreen.main.bounds.height{
        case 600...813:
            buttonConstraint.constant = -10
//            inputterConstraint.constant = 50
            pageHeaderConstraint.constant = 30
        default:
            buttonConstraint.constant = 0
        }
            
        
    }
    
    @objc func validateField(_ sender: UITextField){
        if sender.text!.contains("-") && sender.text!.count>3{
            bottomButton.validate(true)
        }else{
            bottomButton.validate(false)
        }
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Verification"
        view.addSubview(pageHeader)
        view.addSubview(idInputter)
        view.addSubview(bottomButton)
        setupConstraints()
        subscribeToShowKeyboardNotifications()
        idInputter.textField.becomeFirstResponder()
        idInputter.textField.delegate = self
        viewModel.delegate = self
    }
    
    
    func openIDVerificationSuccess() {

        
    }
    
    func openGovIDDetailVerification() {

    }
   
    
    func performApiRequest()  {
        
    }
    
    
    func setupConstraints(){
        let pageHeaderConstraints = [ pageHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30), pageHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32), pageHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)]
        pageHeaderConstraint = pageHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        pageHeaderConstraint.isActive = true
        
        NSLayoutConstraint.activate(pageHeaderConstraints)
        
       
        
        let bottomButtonConstraints = [bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor), bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
            buttonConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            buttonConstraint.isActive = true
        NSLayoutConstraint.activate(bottomButtonConstraints)
        
        let idInputterConstraints = [idInputter.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), idInputter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), idInputter.bottomAnchor.constraint(equalTo: bottomButton.topAnchor,constant: -8)]
////        inputterConstraint = idInputter.bottomAnchor.constraint(equalTo: bottomButton.topAnchor)
//        inputterConstraint.isActive = true
        NSLayoutConstraint.activate(idInputterConstraints)
    }
}

extension GovernmentIdIntakeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension GovernmentIdIntakeViewController: ButtonActionDelegate{
    
    func performAction() {
        viewModel.inputGhanaCardVerificationDetails(customerMsisdn: msisdn ?? "", idNumber: idInputter.textField.text ?? "")
        
    }
    
}

extension GovernmentIdIntakeViewController: ViewStatesDelegate{
   
    func handleVerificationStatus(value: VerificationResponse?) {
        
        self.progress?.dismiss(animated: true){
            let controller = GovernmentVerificationViewController(verificationDetails: value, customerMsisdn: self.msisdn ?? "")
            self.navigationController?.pushViewController(controller, animated: true)
        }
       
    }
    
    func showLoadingStateWhileMakingNetworkRequest(with value: Bool) {
        self.progress = showNetworkCallProgress(isCancellable: true)
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
    
    
    
}
