//
//  CardVerificationViewController.swift
//  
//
//  Created by Mark Amoah on 6/30/23.
//

import UIKit



protocol TableRenderingData{
   var tableSection: TableSectionType {get}
}

enum TableSectionType{
    case declinedSection
    case declinedStatementSection
    case cardDetailsSection
}

struct CardDeclinedStatusObj: TableRenderingData{
    let tableSection: TableSectionType = .declinedSection
    let failureImage: String
    let failureMessage: String
}

struct CardDeclinedStatementObj: TableRenderingData{
    let tableSection: TableSectionType = .declinedStatementSection
    let cardType: String
    let issuingBank: String
    let fraudLabsSttus: FraudLabsStatus
}

struct CardNumberHolderObj: TableRenderingData{
    let tableSection: TableSectionType = .cardDetailsSection
    let cardNumber: String
    let expiryNumber: String
}
class CardVerificationViewController: UIViewController {
    var data: [TableRenderingData]
//    = [CardDeclinedStatusObj(failureImage: "errorx", failureMessage: "Your bank card has been declined"), CardDeclinedStatementObj(cardType: "Visa Card", issuingBank: "Cal bank", fraudLabsSttus: .review), CardNumberHolderObj(cardNumber: "**** **** **** 1256", expiryNumber: "05/12") ]
    
    init(data: [TableRenderingData]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        
    }
    
    static func makeCardVerificationViewController(with data: [TableRenderingData], parentController: UIViewController?){
        let controller = CardVerificationViewController(data: data)
        controller.modalTransitionStyle = .crossDissolve
        parentController?.present(controller, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var bottomButton: CustomButtonView = {
        let button = CustomButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        button.setButtonTitle(with: "End Transaction")
        button.validate(true)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubviews(bottomButton, tableView)
        navigationItem.titleView = NotificationBarHeader(title: "Card Verification", withFont: FontManager.getAppFont(size: .m2))
        setupConstraints()
        tableView.register(HeaderErrorTableViewCell.self, forCellReuseIdentifier: HeaderErrorTableViewCell.identifier)
        tableView.register(FraudFailureDescTableViewCell.self, forCellReuseIdentifier: FraudFailureDescTableViewCell.identifier)
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)

        
    }
    
    func setupConstraints(){
        let bottomButtonConstrains = [
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(bottomButtonConstrains)
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
    }
    

   

}

extension CardVerificationViewController: ButtonActionDelegate{
    func performAction() {
      
    }
}


extension CardVerificationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSection = data[indexPath.row]
        
        switch dataSection.tableSection{
             case .declinedSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderErrorTableViewCell.identifier, for: indexPath)  as! HeaderErrorTableViewCell
            cell.setupUI(with: nil, title: (dataSection as! CardDeclinedStatusObj).failureMessage, subtitle: "")
            return cell
        case .declinedStatementSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: FraudFailureDescTableViewCell.identifier, for: indexPath) as! FraudFailureDescTableViewCell
            cell.setupUI(with: (dataSection as! CardDeclinedStatementObj))
            return cell
        case .cardDetailsSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as! CardTableViewCell
            cell.setupUI(with: (dataSection as! CardNumberHolderObj))
            return cell
        }
       
    }

}
