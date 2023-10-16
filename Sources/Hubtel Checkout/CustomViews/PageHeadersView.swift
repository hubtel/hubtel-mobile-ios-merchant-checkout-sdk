//
//  PagesHeaderView.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class PageHeadersView: UIView {

    let headerImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m3, weight: .bold)
        return label
    }()
    
    let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = FontManager.getAppFont(size: .m4, weight: .regular)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = Colors.appGreySecondary
        return label
    }()
    lazy var contentHolderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerImage, headerTitleLabel, headerSubtitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(imageName:String, headerTitle: String, headerSubtitle: String, frame: CGRect){
        super.init(frame: frame)
        let verificationImage: UIImage?
        if #available(iOS 13.0, *) {
            verificationImage = UIImage(named: imageName, in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
        } else {
            verificationImage = UIImage(named: "nil")
        }
        headerImage.image = verificationImage
        headerTitleLabel.text  = headerTitle
        headerSubtitleLabel.text = headerSubtitle
        headerImage.heightAnchor.constraint(equalToConstant: 78).isActive = true
        headerImage.widthAnchor.constraint(equalToConstant: 78).isActive = true
        addSubview(contentHolderStack)
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupConstraints(){
        let stackConstraints = [contentHolderStack.topAnchor.constraint(equalTo: topAnchor), contentHolderStack.trailingAnchor.constraint(equalTo: trailingAnchor), contentHolderStack.leadingAnchor.constraint(equalTo: leadingAnchor), contentHolderStack.bottomAnchor.constraint(equalTo: bottomAnchor)]
        NSLayoutConstraint.activate(stackConstraints)
    }

}
