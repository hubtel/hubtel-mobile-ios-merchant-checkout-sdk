//
//  CardTableViewCell.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    static let identifier = "cardingTableViewCell"
    let mainCard: CustomCardView = CustomCardView(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainCard)
        selectionStyle = .none
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let mainCardConstraints = [
            mainCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:32),
            mainCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            mainCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(mainCardConstraints)
    }
    
    func setupUI(with value: CardNumberHolderObj){
        mainCard.setupUI(with: value)
    }
}
