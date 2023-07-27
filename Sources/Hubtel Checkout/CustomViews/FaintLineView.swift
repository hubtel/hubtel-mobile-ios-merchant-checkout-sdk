//
//  FaintLineView.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class FaintLineView: UIView {

    let customView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(customView)
        setupConstraints()
        customView.backgroundColor = Colors.appGreySecondary.withAlphaComponent(0.5)
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let customViewConstraints = [
            customView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            customView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            customView.bottomAnchor.constraint(equalTo: bottomAnchor),
            customView.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(customViewConstraints)
    }
    
}
