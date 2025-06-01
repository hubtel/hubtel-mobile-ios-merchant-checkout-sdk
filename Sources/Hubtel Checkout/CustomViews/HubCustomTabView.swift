//
//  CustomTabView.swift
//  
//
//  Created by Mark Amoah on 9/7/23.
//

import UIKit

class HubCustomTabView: UIView {
    
    var action: ()->Void = {}
    
    let bottomLineView: UIView = {
        let bview = UIView()
        bview.translatesAutoresizingMaskIntoConstraints = false
        bview.backgroundColor = Colors.appGreyDark
        return bview
    }()
    
    let topLine: UIView = {
        let tview = UIView()
        tview.translatesAutoresizingMaskIntoConstraints = false
        tview.backgroundColor = Colors.appGreyDark
        return tview
    }()
    
    let tabLabel = MyCustomLabel(text: "Change Wallet")
    
    let caretImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(named: "caretforward", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        }else{
            imageView.image = UIImage(named: "caretforward")
        }
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(labelString: String, action: @escaping ()->Void) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.action = action
        self.isUserInteractionEnabled = true
        self.addSubviews(tabLabel, topLine, bottomLineView, caretImage)
        let userInteraction = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        self.addGestureRecognizer(userInteraction)
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        setupConstraints()
        
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        self.action()
    }
    
    func setupConstraints(){
        let topLineConstraints = [
            topLine.topAnchor.constraint(equalTo: self.topAnchor),
            topLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            topLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            topLine.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(topLineConstraints)
//        
        let bottomLineConstraints = [
            bottomLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            bottomLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            bottomLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: 1)
            
        ]
        NSLayoutConstraint.activate(bottomLineConstraints)
        
        let titleLabelConstraints = [
            tabLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            tabLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            tabLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tabLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        
        let caretConstraints = [
            caretImage.centerYAnchor.constraint(equalTo: tabLabel.centerYAnchor),
            caretImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(caretConstraints)
        
        
    }
    

}
