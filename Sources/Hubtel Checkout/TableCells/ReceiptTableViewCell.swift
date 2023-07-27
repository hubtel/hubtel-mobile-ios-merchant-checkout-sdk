//
//  ReceiptTableViewCell.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class ReceiptTableViewCell: UITableViewCell {
    static let identifier = "ReceiptTableViewCell"
    var totalAmount: Double = 0
    var fees: Double = 0
    
    let receiptView: ReceiptHeaderView = {
        let view = ReceiptHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Tags.receiptHeaderViewTag
        return view
    }()
    
    let topZigZag: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.image = UIImage(named: "receipt_zigzag", in: Bundle.module, with: nil)
        }else{
            view.image = UIImage(named: "receipt_zigzag")
        }
        view.heightAnchor.constraint(equalToConstant: 17).isActive = true
        return view
    }()
    
    lazy var bottomZigZag: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.image = UIImage(named: "zigzagBottom", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal).withTintColor((Colors.globalColor ?? tintColor)!.withAlphaComponent(0.2))
        }else{
            view.image = UIImage(named: "zigzagBottom")
        }
        view.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return view
    }()
    
    lazy var parentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topZigZag, receiptView, bottomZigZag])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    func setupUI(with info: PurchaseInfo?, totalAmount: Double){
        receiptView.amountValue.text = "GHS " + String(format: "%.2f", info?.itemPrice?.roundValue() ?? 0.00)
        receiptView.businessName.text = info?.businessName

        let attributedString = NSMutableAttributedString(string: "GHS ", attributes: [NSAttributedString.Key.font : FontManager.getAppFont(size: .m5), .baselineOffset: 10])
        

        attributedString.append(NSAttributedString(string: String(format: "%.2f", totalAmount), attributes: [NSAttributedString.Key.font : FontManager.getAppFont(size: .m9, weight: .bold)]))
                                
        receiptView.totalAmount.attributedText = attributedString

    }
    
    func setupFeesUpdate(with values: [GetFeesUpdateView]?){
        receiptView.setupFees(value: values)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 32, leading: 38, bottom: 32, trailing: 38)
        self.addSubview(parentStack)
       
        setupConstraints()
    }
    
    func setupConstraints(){
        let views = ["parentStack": parentStack]
        let receiptConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(38)-[parentStack]-(38)-|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(32)-[parentStack]-(32)-|", metrics: nil, views: views)].flatMap {$0}
        NSLayoutConstraint.activate(receiptConstraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

