//
//  ReceiptHeaderView.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class ReceiptHeaderView: UIView {
    
    lazy var buttonTitle =  "View Fees & Taxes"
    var delegate: ReceiptHeaderViewDelegate?
    static var openFees = false
    
    //top information of the receipt
    let businessImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.image = UIImage(named: "darkHeroImage1", in: Bundle.module, with: nil)
        }else{
            view.image = UIImage(named: "darkHeroImage1")
        }
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.tag = 1143
        return view
    }()
    
    let zigzagImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.image = UIImage(named: "receipt_zigzag", in: Bundle.module, with: nil)
        }else{
            view.image = UIImage(named: "receipt_zigzag")
        }
        return view
    }()
    let businessName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        label.tag = 1258
        return label
    }()
    
    let recipientNumber: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = Colors.summarText
        return label
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 150).isActive = true
        view.backgroundColor = Colors.appGreySecondary.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var businessInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [businessName])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.setContentHuggingPriority(.defaultLow, for: .vertical)
        stack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        stack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        stack.spacing = 8
        return stack
    }()
    
    lazy var topHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [businessImage, businessInfoStack])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var centerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topHeaderStack, divider])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins  = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
        return stack
    }()
    
    //middle stack of the receipt
    let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Amount"
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()
    
    let amountValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "GHS 12.00"
        label.textAlignment = .right
        label.textColor = .black
        label.font = FontManager.getAppFont(size: .m4)
        return label
    }()
    
    lazy var amountStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountLabel, amountValue])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    let feesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "fees"
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        return label
    }()

    let feesValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = .black
        label.text = "GHS 0.00"
        label.textAlignment = .right
        return label
    }()
    
    lazy var buttonToViewFeesAndTaxes: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = FontManager.getAppFont(size: .m3, weight: .bold)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(Colors.teal2, for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .primaryActionTriggered)
        return button
        
    }()
    
    lazy var buttontack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buttonToViewFeesAndTaxes])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.isUserInteractionEnabled = true
        return stack
    }()
    
    @objc func buttonAction(_ sender: UIButton){
        ReceiptHeaderView.openFees = !ReceiptHeaderView.openFees
        delegate?.showHideFees(value:ReceiptHeaderView.openFees)
    }
    
    func setBusinessDetails(imageUrl: String, businessName: String){
        self.businessImage.downloadImage(from: imageUrl)
        self.businessName.text = businessName
    }
//
//    let taxLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "tax"
//        label.font = FontManager.getAppFont(size: .m4)
//        label.textColor = .black
//        return label
//    }()
//
//    let taxValue: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "GHS 0.00"
//        label.textAlignment = .right
//        label.font = FontManager.getAppFont(size: .m4)
//        label.textColor = .black
//        return label
//    }()
//
//    lazy var taxStack: UIStackView = {
//        let stack = UIStackView(arrangedSubviews: [taxLabel, taxValue])
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.distribution = .fillEqually
//        stack.axis = .horizontal
//        return stack
//    }()
    
//    let label : UILabel = {
//        let view = UILabel()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.text = "This is my view so dont"
//        return view
//    }()
    
    lazy var middleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountStack,buttontack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        stack.spacing = 8
        return stack
    }()
    
    
    //yellow bottom stack of the receipt
    lazy var chargeInfo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You will be charged"
        label.font = FontManager.getAppFont(size: .m4)
        label.textColor = Colors.globalColor ?? tintColor
        return label
    }()
    
    let totalAmount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m9, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [chargeInfo, totalAmount])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 2
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins  = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
        stack.backgroundColor = (Colors.globalColor ?? tintColor)?.withAlphaComponent(0.2)
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [centerStack, middleStack, bottomStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    func setFees(value: String){
        print(value)
        feesValue.text = "GHS "  + String(format: "%.2f", Double(value) ?? 0.00)
    }
    
//    func updateTotalValue(value: String){
//       
//        let attributedString = NSMutableAttributedString(string: "GHS ", attributes: [NSAttributedString.Key.font : FontManager.getAppFont(size: .m5), .baselineOffset: 10])
//        
////        attributedString.append(NSAttributedString(string: String(info?.itemPrice?.roundValue() ?? 0.00, attributes: [NSAttributedString.Key.font : FontManager.getAppFont(size: .m9, weight: .bold)])))
//        attributedString.append(NSAttributedString(string: String(format: "%.2f", Double(value) ?? 0.00), attributes: [NSAttributedString.Key.font : FontManager.getAppFont(size: .m9, weight: .bold)]))
//                                
//        self.totalAmount.attributedText = attributedString
//    }
    
    func setupFees(value: [GetFeesUpdateView]?){
        if ReceiptHeaderView.openFees{
            self.buttonToViewFeesAndTaxes.setTitle("Less details", for: .normal)
        }else{
            self.buttonToViewFeesAndTaxes.setTitle("View Fees & Taxes", for: .normal)
        }
        middleStack.arrangedSubviews.forEach { view in
            if !(view === amountStack){
                view.isHidden = true
                middleStack.removeArrangedSubview(view)
            }
        }
        if let value = value {
            value.forEach({ response in
                let feesLabel = MyCustomLabel(text: response.name ?? "", font: FontManager.getAppFont(size: .m4))
                let feesValue = MyCustomLabel(text: "GHS " + String(format: "%.2f", response.amount ?? 0.00), textAlignment: .right)
                let stack = UIStackView(arrangedSubviews: [feesLabel, feesValue])
                stack.translatesAutoresizingMaskIntoConstraints = false
                stack.distribution = .fillEqually
                stack.axis = .horizontal
                middleStack.addArrangedSubview(stack)
//                middleStack.insertSubview(stack, aboveSubview: buttontack)
            })
        }
        buttontack.isHidden = false
        middleStack.addArrangedSubview(buttontack)
       
       
//        UIView.animate(withDuration: 0.2) {
//            self.layoutIfNeeded()
//        }completion: { value in
//            UIView.animate(withDuration: 0.2) {
//                self.layoutIfNeeded()
//            }
//        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
//        print(Self.openFees)
        addSubview(mainStack)
        
        setupConstraints()
        backgroundColor = .white
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let views = ["mainStack": mainStack]
        let imageSizeConstraints = [businessImage.heightAnchor.constraint(equalToConstant: 40), businessImage.widthAnchor.constraint(equalToConstant: 40)]
        NSLayoutConstraint.activate(imageSizeConstraints)
        let mainStackConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[mainStack]|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[mainStack]|", metrics: nil, views: views)
        ].flatMap { $0 }
        NSLayoutConstraint.activate(mainStackConstraints)
    }
    
}

protocol ReceiptHeaderViewDelegate{
    func showHideFees(value:Bool)
}
