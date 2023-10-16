//
//  FailedTransactionViewController.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit

enum TransactionType{
    case bankTransaction
    case momoTransaction
}

class FailedTransactionViewController: UIViewController {
    
    var finishedDelegate: PaymentFinishedDelegate?
    
    init(finishedDelegate: PaymentFinishedDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.finishedDelegate = finishedDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var transactionType: TransactionType = .bankTransaction

    let topHeader = ConfirmedOrderView(walletName: "Bank Card", amount: 400, backgroundColor: UIColor(red: 1, green: 171/255, blue: 187/255, alpha: 1), hideAmountLabel: true, imageString: "close_circle", message: "Failed", title: "Failed")
      
     lazy var bottomButton: CustomButtonView = {
          let button = CustomButtonView()
          button.translatesAutoresizingMaskIntoConstraints = false
          button.validate(true)
          button.setButtonTitle(with: "CANCEL TRANSACTION")
          button.delegate = self
          return button
      }()

    let successOverLay = SuccessOverLayView(labelString: "Transaction Failed", imageString: "circle")
    
    
    let card: CustomCardView = CustomCardView(frame: .zero)
    
    let momoTransactionFailureCard = SuccessOverLayView(labelString:"Transaction Failed", imageString: "circle")
    
    lazy var tab: CustomTabView = CustomTabView(labelString: "Change Wallet") {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
      override func viewDidLoad() {
          super.viewDidLoad()
          self.view.addSubviews(topHeader, bottomButton, tab)
          if transactionType == .bankTransaction{
              self.view.addSubview(card)
          }else{
              self.view.addSubview(momoTransactionFailureCard)
          }
//          title = "Checkout"
          print(transactionType)
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
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            card.topAnchor.constraint(equalTo: topHeader.bottomAnchor, constant: -30)
          ]
          
          
          let momoFailureOverlayConstraints = [
            momoTransactionFailureCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            momoTransactionFailureCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            momoTransactionFailureCard.topAnchor.constraint(equalTo: topHeader.bottomAnchor, constant: -30)
          ]
          
          if transactionType == .bankTransaction{
              NSLayoutConstraint.activate(successOverlayConstraints)
          }else{
              NSLayoutConstraint.activate(momoFailureOverlayConstraints)
          }
          
          
          
          let tabConstraints = [
              tab.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              tab.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              tab.topAnchor.constraint(equalTo:transactionType == .bankTransaction ? card.bottomAnchor : momoTransactionFailureCard.bottomAnchor, constant: 50)
          ]
          NSLayoutConstraint.activate(tabConstraints)
      }

}

extension FailedTransactionViewController: ButtonActionDelegate{
    func performAction() {
        self.dismiss(animated: true){
            self.finishedDelegate?.checkStatus(value: .paymentFailed)
            
        }
    }
}
