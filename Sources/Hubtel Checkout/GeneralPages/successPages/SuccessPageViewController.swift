//
//  SuccessPageViewController.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit

class SuccessPageViewController: UIViewController {
    
  let topHeader = ConfirmedOrderView(walletName: "Bank Card", amount: 400)
    
    let bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.validate(true)
        button.setButtonTitle(with: "AGREE AND CONTINUE")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(topHeader, bottomButton)
        title = "Checkout"
        setupConstraints()
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
    }
    
    func setupConstraints(){
        let topheaderConstraints = [
            topHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(topheaderConstraints)
        
        let buttonConstraints = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(buttonConstraints)
    }
    

  

}
