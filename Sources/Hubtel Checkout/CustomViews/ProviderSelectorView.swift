//
//  ProviderSelctorView.swift
//  
//
//  Created by Mark Amoah on 6/15/23.
//

import UIKit

class ProviderSelectorView: UIView {

    let providerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let carretImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(named: "caret_down", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        }else{
            imageView.image = UIImage(named: "caret_down")
        }
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var componentsHolder: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [providerLabel, carretImage])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
//        stack.distribution = .fillProportionally
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return stack
    }()
    
    init(provider: String, frame: CGRect){
        super.init(frame: frame)
        providerLabel.text = provider
        addSubview(componentsHolder)
        setupConstraints()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Colors.fieldColor
        layer.cornerRadius = 8
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupConstraints(){
        let componentsHolderConstraints = [componentsHolder.leadingAnchor.constraint(equalTo: leadingAnchor), componentsHolder.trailingAnchor.constraint(equalTo: trailingAnchor), componentsHolder.topAnchor.constraint(equalTo: topAnchor), componentsHolder.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(componentsHolderConstraints)
        let caretConstraints = [carretImage.heightAnchor.constraint(equalToConstant: 15), carretImage.widthAnchor.constraint(equalToConstant: 15)]
        NSLayoutConstraint.activate(caretConstraints)
    }
    
    func changeProvider(with providerName: String){
        self.providerLabel.text = providerName
    }
    
    func setupString(value: String){
        self.providerLabel.text = value
    }
    
    func getProviderString()->String{
        print(providerLabel.text)
        return providerLabel.text?.lowercased() ?? ""
    }
    
    func getPaymentType()->PaymentType {
        if getProviderString() == "hubtel"{
            return .hubtel
        }
        
        if getProviderString() == "zeepay"{
            return .zeepay
        }
        
        if getProviderString() == "g-money"{
            return .gmoney
        }
        return .hubtel
    }
}
