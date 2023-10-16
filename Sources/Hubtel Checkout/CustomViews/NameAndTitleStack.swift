//
//  NameAndTitleStack.swift
//  
//
//  Created by Mark Amoah on 9/6/23.
//

import UIKit

class NameAndTitleStack: UIStackView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m5, weight: .regular)
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m3, weight: .bold)
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.spacing = 8
        self.alignment = .leading
        self.axis = .vertical
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    convenience init(title: String, value: String){
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.valueLabel.text = value
        [titleLabel, valueLabel].forEach {
            self.addArrangedSubview($0)
        }
    }
    
    func setValue(value: String){
        self.valueLabel.text = value
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
