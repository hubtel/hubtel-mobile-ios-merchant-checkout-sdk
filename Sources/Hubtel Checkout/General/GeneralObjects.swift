//
//  File.swift
//  
//
//  Created by Mark Amoah on 5/2/23.
//

import Foundation
import UIKit

enum CellStyles{
    case receiptHeader
    case payWithTitle
    case paymentChoiceHeader
    case momoInputs
    case bankCardInputs
    case bottomCell
}

enum PaymentType{
    case momo
    case bank
}

struct Section: Equatable{
    let title, imageName: String
    var options: [Option] = []
   var cellStyle: CellStyles
    var  isOpened: Bool = false
    var hideDivider: Bool = false
    var paymentType: PaymentType?
    static func ==(lhs: Section, rhs: Section)->Bool{
        lhs.title == rhs.title
    }
    
}

struct Option{
    let title, image: String
    let cellStyle: CellStyles
}

public struct SetupPayerAuthRequest: Codable{
    let amount: Double
    let cardHolderName, cardNumber, cvv: String
    let expiryMonth, expiryYear: String
    let customerMsisdn: String
    let description: String
    let clientReference: String
    let callbackUrl: String
    
}

public enum PaymentStatus{
    case userCancelledPayment
    case paymentFailed
    case paymentSuccessful
    case unknown
}


public struct HubtelCheckoutConfiguration{
    var salesID: String
    var callbackUrl: String
    var merchantApiKey: String
    public init(salesID: String, callbackUrl: String, merchantApiKey: String) {
        self.salesID = salesID
        self.callbackUrl = callbackUrl
        self.merchantApiKey = merchantApiKey
    }
}

///This object encapsulate the prerequisite values for setting up the checkout view controller. This is created and passed as the configuration param.
class UserSetupRequirements{
    var salesID: String
    var apiKey: String
    var callBackUrl: String
    var customerPhoneNumber: String = ""
    var userCheckStatusReached: Bool = false
    var userTransactionFailed: Bool = false
    var userTransactionSucceeded: Bool = false
    private init(salesID: String = "", apiKey: String = "", callBackUrl: String = ""){
        self.salesID = salesID
        self.apiKey = apiKey
        self.callBackUrl = callBackUrl
    }
    
    static let shared = UserSetupRequirements()
    
    func checkToShowCancelledState()->Bool{
        !userTransactionFailed && !userTransactionSucceeded && !userCheckStatusReached
    }
    
    func checkToShowFailedState()->Bool{
            userTransactionFailed
    }
    
    func checkToShowTransactionSuccessState()->Bool{
        userTransactionSucceeded
    }
    
    func resetStates(){
        (userTransactionFailed, userTransactionSucceeded, userCheckStatusReached) = (false, false, false)
    }
    
}


enum PaymentChannel: String{
    case visa = "cardnotpresent-visa"
    case mtn = "mtn-gh"
    case voda = "vodafone-gh"
    case airtelTigo = "tigo-gh"
    case masterCard = "cardnotpresent-mastercard"
    static func getChannel(string: String)->PaymentChannel{
        switch string{
        case "mtn-gh", "Mtn Mobile Money":
            return PaymentChannel.mtn
        case "vodafone-gh-ussd", "Vodafone Ghana":
            return .voda
        case "airtel-tigo-gh", "tigo-gh", "Airtel Tigo":
            return .airtelTigo
        case "masterCard":
            return .masterCard
        case "visaCard":
            return .visa
        default:
            return .visa
        }
    }
}


public struct MobileMoneyPaymentRequest: Codable{
        let customerName: String?
        let customerMsisdn: String?
        let channel: String?
        let amount: Double?
        let primaryCallbackUrl: String?
        let description: String?
        let clientReference: String?
}

struct ApiResponse< T: Codable>: Codable{
    let code: Int?
    let message: String?
    let data: T
    let errors: [ErrorStruct]?
}

struct Setup3dsResponse: Codable {
    let id: String?
    let status: String?
    let accessToken: String?
    let referenceId: String?
    let deviceDataCollectionUrl: String?
    let clientReference: String?
    let transactionId: String?
}

struct DeviceCollectionObj: Codable{
    let Message: String?
    let SessionId: String?
    let Status: Bool?
}


struct ErrorStruct: Codable{
    let field, errorMessage: String?
}

struct GetFeesBody: Codable{
    let amount: Double
    let channel: String
}


struct GetFeesResponse: Codable{
    let name: String?
    let amount: Double?
}

@objc class GetFeesUpdateView: NSObject{
    let name: String?
    let amount: Double?
    init(name: String?, amount: Double?) {
        self.name = name
        self.amount = amount
    }
}

struct EventStoreData: Codable{
    var customer: [String: String]
    var page: [String: String]
    var action: [String: String]
}


struct Enroll3dsResponse: Codable{
    let transactionId: String?
    let description: String?
    let clientReference: String?
    let amount: Double?
    let charges: Double?
    let customData: String?
    let jwt: String?
    var customCardData: [String: Any]?{
        guard let jsonString = customData?.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: jsonString, options: []), let jsonDictionary = jsonObject as? [String: Any] else{
            return nil
        }
        return  jsonDictionary
    }
    
}

struct CardWhiteListResponse: Codable{
    let id, status : String?
    let cardNumber: String?
    let expiryMonth: Int?
    let expiryYear: Int?
    let fraudCheckResponse: FraudLabsCheck?
    var fraudLabsStatus: FraudLabsStatus {
        switch status?.lowercased(){
        case FraudLabsStatus.approve.rawValue:
            return .approve
        case FraudLabsStatus.reject.rawValue:
            return .reject
        case FraudLabsStatus.review.rawValue:
            return .review
        default:
            return .reject
        }
    }
    var getExpiry: String{
        return "\(String(expiryMonth ?? 0))/\(String(expiryYear ?? 0))"
    }
}

struct FraudLabsCheck:Codable{
    let cardType, cardSubtype, cardIssuingBank : String?
    let fraudlabsproStatus: String?
}

struct MomoResponse: Codable{
      let transactionId: String?
      let charges: Double?
      let amount: Double?
        let amountAfterCharges: Double?
        let amountCharged: Double?
        let deliveryFee: Double?
        let description: String? 
        let clientReference: String?
}

struct MockFailureStructure: Codable{
    let failure: String
}
struct TransactionStatusResponse:Codable{
    var invoiceStatus: String?
    var transactionStatus: String?
    var mobileNumber: String?
}

class BankDetails: NSObject, NSSecureCoding{
    static var supportsSecureCoding: Bool {return true}
    
    func encode(with coder: NSCoder) {
        coder.encode(cardHolderName, forKey: "cardHolderName")
        coder.encode(cardHolderNumber, forKey: "cardHolderNumber")
        coder.encode(cvv, forKey: "cvv")
        coder.encode(expiryYear, forKey: "expiryYear")
        coder.encode(expiryMonth, forKey: "expiryMonth")
    }
    
    required init?(coder: NSCoder) {
        cardHolderName = coder.decodeObject(of: NSString.self, forKey: "cardHolderName")! as String
        cardHolderNumber = coder.decodeObject(of: NSString.self, forKey:  "cardHolderNumber")! as String
        cvv = coder.decodeObject(of: NSString.self, forKey: "cvv")! as String
        expiryYear = coder.decodeObject(of: NSString.self, forKey: "expiryYear")! as String
        expiryMonth = coder.decodeObject(of: NSString.self, forKey: "expiryMonth")! as String
        super.init()
        
    }
    
    let cardHolderName: String
    let cardHolderNumber: String
    let cvv: String
    let expiryMonth: String
    let expiryYear: String
    init(cardHolderName: String, cardHolderNumber: String, cvv: String, expiryMonth: String, expiryYear: String){
        self.cardHolderName = cardHolderName
        self.cardHolderNumber = cardHolderNumber
        self.cvv = cvv
        self.expiryYear = expiryYear
        self.expiryMonth = expiryMonth
        super.init()
    }
    
    func save(){
        let dataToSave = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
        UserDefaults.standard.set(dataToSave, forKey: Strings.myCard)
    }
    
    func saveToDb(){
        if let data = UserDefaults.standard.data(forKey: "thisKey"){
            var myBankDetails = NSKeyedUnarchiver.unarchiveObject(with: data) as? [BankDetails] ?? []
            myBankDetails.append(self)
            let datataToSave = try? NSKeyedArchiver.archivedData(withRootObject: myBankDetails, requiringSecureCoding: true)
            UserDefaults.standard.set(datataToSave, forKey: "thisKey")
        }else{
            let datataToSave = try? NSKeyedArchiver.archivedData(withRootObject: [self], requiringSecureCoding: true)
            UserDefaults.standard.set(datataToSave, forKey: "thisKey")
        }
        
    }
    
}

struct General{
    static var usePresentation: Bool = false
}

enum TransactionStatus: String{
    case pending
    case failed
    case success
}



///This Object represents information about the item being purchased
public struct PurchaseInfo{
    public var businessName: String?
    public var itemPrice: Double?
    public var customersPhoneNumber: String?
    public var purchaseDescription: String?
    public var clientReference: String?
    public var customerMsisDn: String{
        return customersPhoneNumber?.generateFormattedPhoneNumber() ?? ""
    }
    ///This initializer is the initializer for creating a purchase info object.
    ///- parameter businessName: A string representing the name of business or vendor providing the service.
    ///- parameter itemPrice: A double representing the price of the item the user is purchasing.
    ///- parameter customersPhoneNumber: A string representing the phone number of the customer purchasing the item.
    ///- parameter purchaseDescription: An optional string representing a description about the item being purchased.
    public init(businessName: String, itemPrice: Double, customersPhoneNumber: String, purchaseDescription: String? = nil, clientReference: String) {
        self.businessName = businessName
        self.itemPrice = itemPrice
        self.customersPhoneNumber = customersPhoneNumber
        self.purchaseDescription = purchaseDescription
        self.clientReference = clientReference
    }
     func updateItemPrice(value: Double) -> Double{
       return (itemPrice ?? 0.00) + value
    }
    
    func calculateTotal(value: [Double])->Double{
        (itemPrice ?? 0.00) + value.reduce(0, +)
    }
}

struct PaymentOptions{
    static var options = ["Mtn Mobile Money": "mtn-gh", "Airtel Tigo": "tigo-gh", "Vodafone Ghana": "vodafone-gh-ussd"]
    static let providerOptions = [(providerName: "Mtn Mobile Money", providerId:"mtn-gh"), (providerName: "Airtel Tigo", providerId:"tigo-gh"),(providerName: "Vodafone Ghana", providerId:"vodafone-gh-ussd")]
    static var providerOptionsArray:[(String, String)] = []
    
    static func convertArrayToDict(value: [String])->[String: String]{
        let mobilePayments = [ "tigo-gh","vodafone-gh", "mtn-gh"]
        let mappedMobilePayments = mobilePayments.map {
            if $0 == "tigo-gh"{
                return "tigo-gh"
            }
            if $0 == "vodafone-gh"{
                return "vodafone-gh-ussd"
            }
            return $0
        }

        let extractedArray = value.filter{mobilePayments.contains($0)}
        let converted = extractedArray.map{
            if $0 == "tigo-gh"{
                return "tigo-gh"
            }
            if $0 == "vodafone-gh"{
                return "vodafone-gh-ussd"
            }
            return $0
        }
        let finalDict = options.keys.reduce(into: [:]) { partialResult, string in
        //    print(string)
        //    print(dict[string])
            if let value = options[string]{
                print("\(value):   ", extractedArray.contains(value) )
                partialResult[string] = converted.contains(value) ? options[string] : nil
            }
          
            
        }
        var convertedDictionary: [String: String] = [:]
            
            for (key, value) in finalDict {
                if let stringKey = key as? String, let stringValue = value as? String {
                    convertedDictionary[stringKey] = stringValue
                    
                }
            }
            
        return convertedDictionary
    }
    
}


protocol PaymentProtocol{
    func payWithBank(with request: SetupPayerAuthRequest?)
    func paywithMomo(request:MobileMoneyPaymentRequest)
}

public protocol HubtelCheckoutDelegate{
    var salesID: String {get set}
    var apiKey: String {get set}
    var hubtelCheckoutCallbackUrl: String {get set}
}

enum FraudLabsStatus: String{
    case review
    case approve
    case reject
}

struct FraudLabsResponse{
    let fraudlabspro_status: String
    let card_type: String
    let card_subtype: String
    let card_card_issuing_bank: String
    var fraudLabsStatus: FraudLabsStatus{
        switch fraudlabspro_status.lowercased(){
        case FraudLabsStatus.review.rawValue:
            return .review
        case FraudLabsStatus.approve.rawValue:
            return .approve
        case FraudLabsStatus.reject.rawValue:
            return .reject
        default:
            return .reject
        }
    }
}

enum HubtelEventStoreProperties : String {
    case actionName = "Action Name"
    case appName = "App Name"
    case time = "Time"
    case os =  "OS"
    case customerPhoneNumber = "Customer Phone Number"
    case sessionId = "Session Id"
}

struct PaymentChannelCachedKeys{
    static let isBankAllowed = "bankAllowed"
    static let isMomoAllowed = "momoAllowed"
}





