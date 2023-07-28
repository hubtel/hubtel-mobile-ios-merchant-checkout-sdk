//
//  CustomErrorImageTextView.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class CustomErrorImageTextView: UIView {
    
    let imageContainer : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setImage(with: "errorx")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textHolderBold: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = FontManager.getAppFont(size: .m4, weight: .bold)
        view.textColor = .black
        return view
    }()
    
    let lightText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()
    
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageContainer, textHolderBold, lightText])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    init(imageText: String, title: String, subtitle: String, frame: CGRect = .zero){
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textHolderBold.text = title
        self.lightText.text = subtitle
        addSubviews(parentStack)
        setupConstraints()
    }
    
    func setupConstraints(){
        let parentStackConstraints = [parentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8), parentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8), parentStack.topAnchor.constraint(equalTo: topAnchor, constant: 60), parentStack.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(parentStackConstraints)
        let imageContainerConstraints = [imageContainer.heightAnchor.constraint(equalToConstant: 63), imageContainer.widthAnchor.constraint(equalToConstant: 63)]
        NSLayoutConstraint.activate(imageContainerConstraints)
        }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(with imageString: String = "errorx", titleString: String, subtitleStirng: String){
        self.textHolderBold.text = titleString
        self.lightText.text = subtitleStirng
        self.imageContainer.setImage(with: imageString)
    }
    

}
