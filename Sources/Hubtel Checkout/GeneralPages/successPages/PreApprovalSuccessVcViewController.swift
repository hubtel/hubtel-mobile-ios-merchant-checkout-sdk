//
//  PreApprovalSuccessVcViewController.swift
//  
//
//  Created by Mark Amoah on 9/15/23.
//

import UIKit

class PreApprovalSuccessVcViewController: UIViewController {
    
    var delegate: PaymentFinishedDelegate?
    
    
    init(walletName: String, amount: Double, delegate: PaymentFinishedDelegate?){
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.orderView.walletNameLabel.text = "Your \(walletName) will be debited with GHS \(String(format: "%.2f", amount)), after your order is confirmed"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let orderView = ConfirmedOrderView(walletName: "mobile Money", amount: 1, preapproved: true, preApprovedString: "Your wallet will be debited with GHS 10")
    
    lazy var  buttonView: CustomButtonView = {
        let button = CustomButtonView()
        button.setButtonTitle(with: Strings.agreeAndContinue)
        button.delegate = self
        button.validate(true)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(orderView, buttonView)
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        setupConstraints()
    }
    

    func setupConstraints(){
        
        let buttonConstraints  = [
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(buttonConstraints)
        
        let orderViewConstraints = [
            orderView.topAnchor.constraint(equalTo: view.topAnchor),
            orderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(orderViewConstraints)
        
        
    }
   

}

extension PreApprovalSuccessVcViewController: ButtonActionDelegate{
    func performAction() {
        self.dismiss(animated: true){
            self.delegate?.checkStatus(value: .paymentSuccessful)
        }
    }
}

