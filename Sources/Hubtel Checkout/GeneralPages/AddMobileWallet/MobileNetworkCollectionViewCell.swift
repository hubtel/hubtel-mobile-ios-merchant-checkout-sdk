//
//  MobileNetworkCollectionViewCell.swift
//  
//
//  Created by Mark Amoah on 9/29/23.
//

import UIKit

class MobileNetworkCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier = "MobileNetworkTableViewCell"
    
    

    var option: MobileMoneyWalletOptions? {
        didSet {
            guard let unwrappedOption = option else {
                return
            }
            
            let verificationImage: UIImage?
            if #available(iOS 13.0, *) {
                verificationImage = UIImage(named: unwrappedOption.image ?? "", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysOriginal)
            } else {
                verificationImage = UIImage(named: "nil")
            }
            networkImageView.image = verificationImage
            networkNameLabel.text = unwrappedOption.title ?? ""
        }
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.appGrey.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var networkImageView: UIImageView = {
        let image   = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0.5
        image.layer.borderColor = Colors.appGrey.cgColor
        image.layer.masksToBounds = true
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = false
        return image
    }()
    
    lazy var networkNameLabel: UILabel = {
        let label  = UILabel()
        label.numberOfLines = 1
        label.textColor     = Colors.black
        label.text = "Airtel-Tigo"
        label.font = FontManager.getAppFont(size: .m4, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func configure(with option: [MobileMoneyWalletOptions]) {
       
    }
    
    func setupBorders(value: Bool){
        if value{
            containerView.layer.borderColor = Colors.teal2.cgColor
        }else{
            containerView.layer.borderColor = Colors.appGrey.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    func layoutViews() {
        contentView.addSubview(networkImageView)
        contentView.addSubview(networkNameLabel)
        contentView.addSubview(containerView)
        contentView.backgroundColor = .white
        
        networkImageView.layer.cornerRadius = 21
        containerView.layer.cornerRadius = 25
  
        NSLayoutConstraint.activate([
            networkNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            networkNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            networkNameLabel.topAnchor.constraint(equalTo: networkImageView.bottomAnchor, constant: 4),
            networkNameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            networkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            networkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            networkImageView.heightAnchor.constraint(equalToConstant: 42),
            networkImageView.widthAnchor.constraint(equalToConstant: 42),
                        
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            containerView.widthAnchor.constraint(equalToConstant: 50),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)

        ])
    }
    
}
