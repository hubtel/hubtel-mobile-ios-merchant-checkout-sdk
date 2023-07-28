//
//  CardDetailsView.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class CardDetailsView: UIView {
    let keyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.tokensColor
        label.font = FontManager.getAppFont(size: .m7)
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.black
        label.font = FontManager.getAppFont(size: .m4)
        return label
    }()
    
    lazy var parentContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    init(key: String, value: String){
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        keyLabel.text = key
        valueLabel.text = value
        addSubview(parentContainer)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let parentContainerConstraints = [
            parentContainer.topAnchor.constraint(equalTo: topAnchor),
            parentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            parentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            parentContainer.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]
        NSLayoutConstraint.activate(parentContainerConstraints)
    }
    
    func updateUI(key: String, value: String){
        self.keyLabel.text = key
        self.valueLabel.text = value
    }
    
    func setupValue(value: String){
        self.valueLabel.text = value
    }
    
}
