//
//  GhanaCardView.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class GhanaCardView: UIView {
    
    let coArmsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(named: "coatOfArms", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            imageView.image = UIImage(named: "nil")
        }
        
        return imageView
    }()
    
    
    let title = MyCustomLabel(text: "Ghana Card Details", font: FontManager.getAppFont(size: .m3, weight: .bold))
    
    let fullNameStack = NameAndTitleStack(title: "Full Name", value: "Mark Amoah")
    
    let governmentIdStack = NameAndTitleStack(title: "Personal ID Number", value: "GHA-000338531-5")
    
    let dob = NameAndTitleStack(title: "DOB", value: "10/09/1995")
    
    let gender = NameAndTitleStack(title: "Gender", value: "Male")
    
    lazy var trailingGender: UIStackView = {
        let view = UIStackView(arrangedSubviews: [gender])
        view.alignment = .trailing
        view.axis = .horizontal
        view.alignment = .trailing
        return view
    }()
    
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [title, fullNameStack, governmentIdStack, personalDetailsStack])
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    lazy var personalDetailsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dob, trailingGender])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor(red: 237/255, green: 250/255, blue: 247/255, alpha: 1)
        self.addSubviews( coArmsImage, parentStack)
        setupConstraints()
        
    }
    
    func setItems(fullName: String, idNumber: String, dateOfBirth: String, gender:String){
        fullNameStack.setValue(value: fullName)
        governmentIdStack.setValue(value: idNumber)
        dob.setValue(value: dateOfBirth)
        self.gender.setValue(value: gender)
    }
    
    func setupConstraints(){
        let parentStackConstraints = [
            parentStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            parentStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            parentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            parentStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(parentStackConstraints)
        
        let coArmsConstraints = [
            coArmsImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            coArmsImage.topAnchor.constraint(equalTo: self.topAnchor),
        ]
        NSLayoutConstraint.activate(coArmsConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
