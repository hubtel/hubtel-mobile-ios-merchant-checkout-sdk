//
//  BottomCornersTableViewCell.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class BottomCornersTableViewCell: UITableViewCell {
    static let identifier: String = "bottomCorners"
    let customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    lazy var parentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [customView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 16
        stack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return stack
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(parentStack)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        setupConstraints()
    }
    
    func setupConstraints(){
        let views = ["parentStack": parentStack]
        customView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        let stackConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[parentStack]-|", metrics: nil, views: views),NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentStack]|", metrics: nil, views: views)
        ].flatMap {$0}
        NSLayoutConstraint.activate(stackConstraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

