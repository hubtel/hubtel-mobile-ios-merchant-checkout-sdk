//
//  FinalSuccessVerificationViewController.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit

class FinalSuccessVerificationViewController: UIViewController {
    
    var delegate: PaymentFinishedDelegate?

    let topHeader = ConfirmedOrderView(walletName: "Bank Card", amount: 400, hideAmountLabel: true)
      
      lazy var bottomButton: CustomButtonView = {
          let button = CustomButtonView()
          button.translatesAutoresizingMaskIntoConstraints = false
          button.validate(true)
          button.setButtonTitle(with: "DONE")
          button.delegate = self
          return button
      }()

    let successOverLay = SuccessOverLayView(labelString: "Orders and Delivery", imageString: "circle")
    
    
    init(amount: Double, currency: String, orderName: String, finishedDelegate: PaymentFinishedDelegate? = nil){
        super.init(nibName: nil, bundle: nil)
        self.topHeader.setAmountDeductedLabel(amount: amount, currency: currency)
        self.successOverLay.orderPlacedLabel.text = orderName
        self.delegate = finishedDelegate
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
      override func viewDidLoad() {
          super.viewDidLoad()
          self.view.addSubviews(topHeader, bottomButton, successOverLay)
          title = "Checkout"
          setupConstraints()
          view.backgroundColor = .white
          
          // Do any additional setup after loading the view.
      }
      
      func setupConstraints(){
          let topheaderConstraints = [
              topHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              topHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              topHeader.topAnchor.constraint(equalTo: view.topAnchor)
          ]
          NSLayoutConstraint.activate(topheaderConstraints)
          
          let buttonConstraints = [
              bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
          ]
          NSLayoutConstraint.activate(buttonConstraints)
          
          let successOverlayConstraints = [
            successOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successOverLay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successOverLay.topAnchor.constraint(equalTo: topHeader.bottomAnchor, constant: -30)
          ]
          NSLayoutConstraint.activate(successOverlayConstraints)
      }

}

extension FinalSuccessVerificationViewController: ButtonActionDelegate{
    func performAction() {
        self.dismiss(animated: true){
            self.delegate?.checkStatus(value: .paymentSuccessful)
        }
    }
}
