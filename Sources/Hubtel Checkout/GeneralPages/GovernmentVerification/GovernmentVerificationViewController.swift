//
//  GovernmentVerificationViewController.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class GovernmentVerificationViewController: UIViewController {
    
    var progress: UIAlertController?
    
    let viewModel = GovVerificationViewModel()
    
    var msisdn: String?
    
    var provider: String?
    
    var verificationDetails: VerificationResponse?
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return view
    }()
    
    let verificationImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let verificationTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Confirm Your Ghana Card Details"
        label.font = FontManager.getAppFont(size: .m3, weight: .bold)
        return label
    }()
    
    lazy var imageAndTextStack = {
        let stack = UIStackView(arrangedSubviews: [verificationImage, verificationTitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    let ghCardView: GhanaCardView = {
        let view = GhanaCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        button.setButtonTitle(with: "CONFIRM")
        button.validate(true)
        return button
    }()
    
    init(verificationDetails: VerificationResponse?, customerMsisdn: String, provider: String? = nil){
        super.init(nibName: nil, bundle: nil)
        ghCardView.setItems(fullName: verificationDetails?.fullname ?? "", idNumber: verificationDetails?.nationalID ?? "", dateOfBirth: verificationDetails?.birthday ?? "", gender: verificationDetails?.gender ?? "")
        self.msisdn = customerMsisdn
        self.provider = provider
        self.verificationDetails = verificationDetails
        print(provider)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
//        [imageAndTextStack, ghCardView].forEach {
//            scrollView.addSubview($0)
//        }
        scrollView.addSubviews(imageAndTextStack, ghCardView)
        view.backgroundColor = .white
        self.view.addSubviews(scrollView, bottomButton)
        let verificationImage: UIImage?
        if #available(iOS 13.0, *) {
            verificationImage = UIImage(named: "ic_verify_id", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            verificationImage = UIImage(named: "nil")
        }
        self.verificationImage.image = verificationImage
        setupConstraints()
        
        // Do any additional setup after loading the view.
    }
    
    func setupConstraints(){
        let svlg = scrollView.contentLayoutGuide
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        let imageConstraints = [
            imageAndTextStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            imageAndTextStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            imageAndTextStack.topAnchor.constraint(equalTo: svlg.topAnchor, constant: 140)
        ]
        
        NSLayoutConstraint.activate(imageConstraints)
        
        let ghanaCardConstraints = [
            ghCardView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            ghCardView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            ghCardView.topAnchor.constraint(equalTo: imageAndTextStack.bottomAnchor, constant: 45),
        ]
        NSLayoutConstraint.activate(ghanaCardConstraints)
        
        let bottomButtonConstraints = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(bottomButtonConstraints)
        
        svlg.bottomAnchor.constraint(equalTo: ghCardView.bottomAnchor).isActive = true
        
    }
    

   

}

extension GovernmentVerificationViewController: ButtonActionDelegate{
    func performAction() {
        
        let verificationBody = self.verificationDetails?.toVerificationBody(customerMsisdn: msisdn ?? "")
        
        viewModel.makeVerificationConfirmation(customerMsisdn: msisdn ?? "", body: verificationBody)
    }
}

extension GovernmentVerificationViewController: ViewStatesDelegate{
    
    func showLoadingStateWhileMakingNetworkRequest(with value: Bool) {
        self.progress = showNetworkCallProgress(isCancellable: true)
    }
    
    func handleOnlyMobileMoney() {
        progress?.dismiss(animated: true){
            self.dismiss(animated: true){
                print(self.provider)
                let name = Notification.Name("doneWithVerification")
                NotificationCenter.default.post(name: name, object: self.provider)
            }
           
            
        }
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
