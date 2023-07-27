//
//  HeaderErrorTableViewCell.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class HeaderErrorTableViewCell: UITableViewCell {
    static let identifier = "errorShowingCell" 
    
    let errorMessageAndImageHolder = CustomErrorImageTextView(imageText: "errorx", title: "", subtitle: "")
    let faintLineView = FaintLineView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubviews(errorMessageAndImageHolder, faintLineView)
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let errorMessageAndImageHolderConstraints = [
            errorMessageAndImageHolder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorMessageAndImageHolder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorMessageAndImageHolder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            errorMessageAndImageHolder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(errorMessageAndImageHolderConstraints)
        
        let faintLineConstraints = [
            faintLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            faintLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            faintLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(faintLineConstraints)
    }
    
    func setupUI(with imageString: String?, title: String, subtitle: String){
        errorMessageAndImageHolder.updateUI(titleString: title, subtitleStirng: subtitle)
    }
    
}
