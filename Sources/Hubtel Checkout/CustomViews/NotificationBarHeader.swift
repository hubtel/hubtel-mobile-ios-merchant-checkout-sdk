//
//  NotificationBarHeader.swift
//  
//
//  Created by Mark Amoah on 6/23/23.
//

import UIKit

class NotificationBarHeader: UIView {
    let titleTextField: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()

    init(title: String, withFont font: UIFont = FontManager.getAppFont(size: .m2, weight: .bold)){
        super.init(frame: .zero)
        self.titleTextField.text = title
        self.titleTextField.font = font
        addSubview(titleTextField)
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setupConstraints() {
        let titleConstraints = [
            titleTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(titleConstraints)
    }
    
}
