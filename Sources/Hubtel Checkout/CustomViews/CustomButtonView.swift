//
//  CustomButtonView.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import UIKit

class CustomButtonView: UIView {
    weak var delegate: ButtonActionDelegate?
    
    lazy var button: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.appGreyDisabled
        view.setTitle("PAY", for: .normal)
        view.setTitleColor( Colors.disabledText, for: .normal)
        view.layer.cornerRadius = 8
        view.addTarget(self, action: #selector(buttonAction(_:)), for: .primaryActionTriggered)
        view.titleLabel?.font = FontManager.getAppFont(size: .m3, weight:.bold)
        return view
    }()
    
    let borderLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.fieldColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        backgroundColor = .white
        self.addSubview(button)
        self.addSubview(borderLine)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    @objc func buttonAction(_ sender: UIButton){
        delegate?.performAction()
    }
    
    func setButtonTitle(with title: String){
        button.setTitle(title, for: .normal)
    }
    
    func getButtonTitle()->String?{
        return button.currentTitle
    }
    func setupConstraints(){
        let views = ["button": button]
        NSLayoutConstraint.activate([
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[button(50)]-|", metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[button]-|", metrics: nil, views: views)
        ].flatMap({ $0 }))
        
        let borderLineConstraints = [
            borderLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderLine.topAnchor.constraint(equalTo: topAnchor),
            borderLine.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(borderLineConstraints)
    }
    
    func validate(_ value: Bool){
        button.isEnabled = value && CheckOutViewModel.allowPayment
        button.setTitleColor(value && CheckOutViewModel.allowPayment ? .white : Colors.disabledText, for: .normal)
        button.backgroundColor = value && CheckOutViewModel.allowPayment ? Colors.globalColor ?? tintColor : Colors.appGreyDisabled
    }
    
    func showLoader(value: Bool, name: String = "PAY"){
        self.button.loadingIndicator(value, name: name)
    }

}

extension UIView{
    func addSubviews(_ views: UIView...){
        views.forEach {self.addSubview($0)}
    }
}


protocol ButtonActionDelegate: AnyObject{
    func performAction()
}
