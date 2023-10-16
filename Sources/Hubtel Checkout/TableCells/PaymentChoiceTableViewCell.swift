//
//  PaymentChoiceTableViewCell.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class PaymentChoiceTableViewCell: UITableViewCell {
    static let identifier: String = "paymentChoiceTableCell"
    let paymentType: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.getAppFont(size: .m4, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    lazy var selectionCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = (Colors.globalColor ?? tintColor)?.cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        return view
    }()
    
    let image1 = ProviderImageView(imageName: "")
    let image2 = ProviderImageView(imageName: "")
    let image3 = ProviderImageView(imageName: "")
    
    lazy var stack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [image1, image2, image3])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    let carret: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
       
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var parentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(selectionCircle, paymentType, stack)
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return view
    }()
    
    lazy var parentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [parentContainer])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.backgroundColor = .white
        return stackView
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.appGreySecondary.withAlphaComponent(0.5)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentView.addSubviews(parentStack, divider)
        contentView.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255,alpha:1)
        selectionStyle = .none
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        let views = ["sectionCircle": selectionCircle, "paymentType": paymentType, "carret":carret, "parentStack": parentStack]
        
        let sectionCircleConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[sectionCircle(20)]", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[sectionCircle(20)]-|", metrics: nil, views: views)
        ].flatMap {$0}
        NSLayoutConstraint.activate(sectionCircleConstraints)
        
        let paymentTypeLabelConstraints = [paymentType.centerYAnchor.constraint(equalTo: selectionCircle.centerYAnchor), paymentType.leadingAnchor.constraint(equalTo: selectionCircle.trailingAnchor, constant: 16)]
        NSLayoutConstraint.activate(paymentTypeLabelConstraints)
        
//        let carretConstraints = [
//            NSLayoutConstraint.constraints(withVisualFormat: "H:[carret(24)]-|", metrics: nil, views: views),
//            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[carret(24)]-|", metrics: nil, views: views)
//        ].flatMap {$0}
//
//        NSLayoutConstraint.activate(carretConstraints)
        
        let stackViewConstraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[parentStack]-|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentStack]|", metrics: nil, views: views)
        ].flatMap {$0}
        NSLayoutConstraint.activate(stackViewConstraints)
        
        let dividerConstrints = [divider.leadingAnchor.constraint(equalTo: parentStack.leadingAnchor), divider.trailingAnchor.constraint(equalTo: parentStack.trailingAnchor), divider.heightAnchor.constraint(equalToConstant: 1), divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        NSLayoutConstraint.activate(dividerConstrints)
        
        let stackConstraints = [
            stack.trailingAnchor.constraint(equalTo: parentContainer.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: parentContainer.centerYAnchor)
        ]
        NSLayoutConstraint.activate(stackConstraints)
    }
    
    func render(with value: Section, imageUpdater: ImageUpdatShowerUpdate=ImageUpdatShowerUpdate()){
        self.paymentType.text = value.title
        switch value.title{
        case Strings.mobileMoney:
            image1.installImage(imageString: "checkout_mtn_logo", showImage: imageUpdater.showMtn)
            image2.installImage(imageString: "checkout_airtel_tigo_money_logo", showImage: imageUpdater.showAirtel)
            image3.installImage(imageString: "checkout_vodafone_cash_logo", showImage: imageUpdater.showVoda)
        case Strings.bankCard:
            image1.installImage(imageString: "")
            image2.installImage(imageString: "checkout_visa_logo", showImage: imageUpdater.showVisa)
            image3.installImage(imageString: "checkout_mastercard_logo", showImage: imageUpdater.showMasterCard)
        case Strings.others:
            image1.installImage(imageString: "hubtelLogo")
            image2.installImage(imageString: "gmoney")
            image3.installImage(imageString: "zeepay")
        default:
            break
        }
    }
    
    func  turnImage(with value: Bool = true){
        if value{
            UIView.animate(withDuration: 0.1) {
                self.carret.transform = CGAffineTransform(rotationAngle: 90 * .pi/180)
                self.selectionCircle.layer.borderWidth = 6
                self.parentStack.backgroundColor = (Colors.globalColor ?? self.tintColor)?.withAlphaComponent(0.2)
            } completion: { _ in
            }
        }else{
            
        }
       
    }
    
    func revert(){
        UIView.animate(withDuration: 0.1) {
            self.carret.transform = .identity
            self.selectionCircle.layer.borderWidth = 3
            self.parentStack.backgroundColor = UIColor.white
            
        } completion: { _ in
            
        }
    }
    
    func hideDivider(with value: Bool){
        divider.isHidden = value
    }
    
    

}

class ImageUpdatShowerUpdate{
    var showMtn:Bool
    var showAirtel: Bool
    var showVoda: Bool
    var showVisa: Bool
    var showMasterCard: Bool
    init(showMtn: Bool = true, showAirtel: Bool = true, showVoda: Bool = true, showVisa: Bool = true, showMasterCard: Bool=true){
        self.showMtn = showMtn
        self.showAirtel = showAirtel
        self.showVisa = showVisa
        self.showMasterCard = showMasterCard
        self.showVoda = showVoda
    }
}
