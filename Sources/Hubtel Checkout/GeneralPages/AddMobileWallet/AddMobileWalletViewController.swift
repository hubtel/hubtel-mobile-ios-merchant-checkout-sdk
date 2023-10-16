//
//  AddMobileWalletViewController.swift
//  
//
//  Created by Mark Amoah on 9/29/23.
//

import UIKit

class AddMobileWalletViewController: UIViewController {
    
    var progress: UIAlertController?
    
    lazy var viewModel: AddMobileWalletViewModel = AddMobileWalletViewModel(delegate: self)
    
    var buttonConstraint: NSLayoutConstraint!

    var mobileNetworks = [
        MobileMoneyWalletOptions(image: "ic_mtn_momo", title: "MTN", subtitle: nil, value: "mtn"),
        MobileMoneyWalletOptions(image: "ic_vodafone_momo", title: "Vodafone", subtitle: nil, value: "vodafone"),
        MobileMoneyWalletOptions(image: "airtelTigoLogo", title: "Airtel-Tigo", subtitle: nil, value: "airteltigo")
    ]
    
    var selected: [Bool] = [false, false, false]
    
    lazy var mobileNumberTextField: IDVerificationTextFieldView = {
        let view = IDVerificationTextFieldView(placeHoleder: "eg. 055 553 3341", HeaderText: "Mobile Number")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.delegate = self
        view.textField.addTarget(self, action: #selector(validateInput), for: .editingChanged)
        view.textField.keyboardType = .numberPad
        return view
    }()
    
    @objc func validateInput(){
        if mobileNumberTextField.textField.getTextCount() >= 9 && viewModel.provider != nil {
            bottomButton.validate(true)
        }else{
            bottomButton.validate(false)
        }
    }
    
    let titleDescription: MyCustomLabel = MyCustomLabel(text: "Select Mobile Network")
    
    let layout : UICollectionViewFlowLayout = {
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        lay.minimumLineSpacing = 8
        lay.minimumInteritemSpacing = 0.5
        return lay
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let parentContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        button.setButtonTitle(with: "CONTINUE")
        button.validate(false)
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = NotificationBarHeader(title: "Add Mobile Wallet")
        view.backgroundColor = Colors.bgColorGray
        view.addSubviews(parentContainer, bottomButton)
        parentContainer.addSubviews(mobileNumberTextField, titleDescription,collectionView)
        subscribeToShowKeyboardNotifications()
        setupConstraints()
        collectionView.register(MobileNetworkCollectionViewCell.self, forCellWithReuseIdentifier: MobileNetworkCollectionViewCell.reuseIdentifier)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bottomButton.becomeFirstResponder()
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
            buttonConstraint.constant = -keyboardHeight + 30
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
    
    func setupConstraints(){
        let parentContainerConstraints = [
            parentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            parentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            parentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ]
        NSLayoutConstraint.activate(parentContainerConstraints)
        
        let buttonContainerConstraints = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(buttonContainerConstraints)
        
       buttonConstraint = bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        buttonConstraint.isActive = true
        
        
        let mobileMoneyDescriptionConstraints = [
            mobileNumberTextField.leadingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.leadingAnchor),
            mobileNumberTextField.trailingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.trailingAnchor),
            mobileNumberTextField.topAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(mobileMoneyDescriptionConstraints)
        
        let titleDescriptionConstraints = [
            titleDescription.topAnchor.constraint(equalTo: mobileNumberTextField.bottomAnchor, constant: 16),
            titleDescription.leadingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.leadingAnchor),
            titleDescription.trailingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.trailingAnchor),
            
        ]
        NSLayoutConstraint.activate(titleDescriptionConstraints)
        
        let collectionViewConstraints = [
            collectionView.topAnchor.constraint(equalTo: titleDescription.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: parentContainer.layoutMarginsGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
        
    }
    

    

}


extension AddMobileWalletViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mobileNetworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MobileNetworkCollectionViewCell.reuseIdentifier, for: indexPath) as! MobileNetworkCollectionViewCell
        cell.option = mobileNetworks[indexPath.item]
        
        cell.setupBorders(value: selected[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelection(index: indexPath.item)
        self.viewModel.provider = mobileNetworks[indexPath.row].value
        if mobileNumberTextField.textField.getTextCount() >= 9{
            bottomButton.validate(true)
        }
        collectionView.reloadData()
    }
    
    
    func handleSelection(index: Int){
        if index == 0{
            selected = [true, false, false]
        }else if index == 1{
            selected = [false, true, false]
        }else if index == 2{
            selected = [false, false, true]
        }
    }
    
    
    
    
    
    
    
}

extension AddMobileWalletViewController: ButtonActionDelegate{
    func performAction() {
        let requestBody = AddMobileWalletBody(
            accountNo: mobileNumberTextField.textField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            provider: viewModel.provider ?? "",
            customerMobileNumber: UserSetupRequirements.shared.customerPhoneNumber
        )

        viewModel.makeAddMoneyWallet(requestBody: requestBody)
    }
    
    
}

extension AddMobileWalletViewController: ViewStatesDelegate{
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
    
    func dismissLoaderToPerformMomoPayment() {
        self.progress?.dismiss(animated: true){
            let name = Notification.Name(rawValue: "doneAddingWallet")
            NotificationCenter.default.post(name: name, object: nil)
            self.showAlert(with: "Success",message: self.viewModel.successMessage ?? ""){_ in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

extension AddMobileWalletViewController: UITextFieldDelegate{
    
}

