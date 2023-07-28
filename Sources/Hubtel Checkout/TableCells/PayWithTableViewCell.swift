//
//  PayWithTableViewCell.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class PayWithTableViewCell: UITableViewCell {
    static let identifier: String = "payWithTableViewCell"
    let payWithLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = Strings.payWith
        label.font = FontManager.getAppFont(size: .m3, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    lazy  var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [payWithLabel])
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.layer.cornerRadius = 16
        stack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentView.addSubview(parentStack)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let views = ["parentStack": parentStack]
        let parentStackConstraints = [NSLayoutConstraint.constraints(withVisualFormat: "H:|-[parentStack]-|", metrics: nil, views: views), NSLayoutConstraint.constraints(withVisualFormat: "V:|-[parentStack]|", metrics: nil, views: views)].flatMap { $0 }
        NSLayoutConstraint.activate(parentStackConstraints)
    }

}

