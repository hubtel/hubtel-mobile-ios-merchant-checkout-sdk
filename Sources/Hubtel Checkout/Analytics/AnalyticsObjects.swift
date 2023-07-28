//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/17/23.
//

import Foundation

enum AppSection : String{
    case checkout = "Checkout"
}

protocol AnalyticsAppEventProtocol {
        
    var descriptor : AppEventDescriptor { get }
}

enum CheckoutAppEvent : String,AnalyticsAppEventProtocol {
    case checkoutPayViewPagePay = "checkout__pay__view__page_pay"
    case checkoutPayTapMobileMoney = "checkout__pay__tap__mobile_money"
    case checkoutPayTapBankCard = "checkout__pay__tap__bank_card"
    case checkoutPayTapUseNewCard = "checkout__pay__tap__use_new_card"
    case checkoutPayTapUseSavedCard = "checkout__pay__tap__use_saved_card"
    case checkoutPayTapHubtelBalance = "checkout__pay__tap__hubtel_balance"
    case checkoutPayTapButtonPay = "checkout__pay__tap__button_pay"
    case checkoutPayTapClose = "checkout__pay__tap__close"
    case checkout3DsBrowserViewPage3DsBrowser = "checkout__3ds_browser__view__page_3ds_browser"
    case checkout3DsBrowserViewDialog3DsError = "checkout__3ds_browser__view__dialog_3ds_error"
    case checkoutPayViewDialogOrderCreatedSuccessfully = "checkout__pay__view__dialog_order_created_successfully"
    case checkoutPayViewDialogOrderFailed = "checkout__pay__view__dialog_order_failed"
    case checkoutCheckStatusViewPageCheckStatus = "checkout__check_status__view__page_check_status"
    case checkoutCheckStatusTapIHavePaid = "checkout__check_status__tap__i_have_paid"
    case checkoutCheckStatusTapCancel = "checkout__check_status__tap__cancel"
    case checkoutCheckStatusViewPageCheckAgain = "checkout__check_status__view__page_check_again"
    case checkoutCheckStatusTapCheckAgain = "checkout__check_status__tap__check_again"
    case checkoutCheckStatusTapChangeWallet = "checkout__check_status__tap__change_wallet"
    case checkoutPaymentFailedViewPagePaymentFailed = "checkout__payment_failed__view__page_payment_failed"
    case checkoutPaymentSuccessfulViewPagePaymentSuccessful = "checkout__payment_successful__view__page_payment_successful"
    case checkoutPaymentSuccessfulTapButtonDone = "checkout__payment_successful__tap__button_done"
    
    var descriptor : AppEventDescriptor {
        return AppEventDescriptor(name: self.rawValue, section: .checkout, type: self.rawValue.getEventType())
    }
}

enum AnalyticsParams {
    
    //section params
    enum General : String {
        case sectionName = "Section Name"
        case pageName = "Page Name"
        case uiType = "UI Type"
    }
    
    enum View : String {
        case viewId = "View Id"
        case viewName = "View Name"
        case viewShortName = "View ShortName"
    }
    
    enum Tap : String {
        case tapId = "Tap Id"
        case tapName = "Tap Name"
        case tapShortName = "Tap ShortName"
    }
    
    enum Purchase : String {
        case purchaseId = "Purchase Id"
        case purchaseAmount = "Purchase Amount"
        case purchaseErrorMessage = "Purchase Error Message"
        case purchasePaymentChannel = "Purchase Payment Channel"
        case purchasePaymentType = "Purchase Payment Type"
        case purchaseOrderItems = "Purchase Order Items"
        case purchaseOrderItemNames = "Purchase Order Item Names"
        case purchaseOrderItemProviders = "Purchase Order Item Providers"
        
    }
}

enum AppEventType: String{
    case view = "View"
    case apiRequest = "API Request"
    case tap = "Tap"
    case other = "Other"
    case beginPurchase = "Begin Purchase"
}
struct AppEventDescriptor {
    var name: String
    var section: AppSection
    var type: AppEventType

    var pageName : String {
        return "Checkout"
    }

    var shortName : String {
        return (name.components(separatedBy: "__").getSafely(index: 3) ?? "").wordCased()
    }

    var  friendlyName : String {
        return name.wordCased()
    }

}

struct AnalyticsHelper{
    static func logAppEvent(event:AppEventDataProtocol){
        AnalyticsManager.shared.recordAnalytics(body: event.hubtelData())
    }
    static func recordCheckoutEvent(event: CheckoutAppEvent){
        recordAppEvent(event:event)
    }
    
    static func  recordBeginPurchase(beginPurchase: BeginPurchaseAppEvent){
        logAppEvent(event: beginPurchase)
    }
    
    
    
    static private func recordAppEvent(event: AnalyticsAppEventProtocol, data: AnalyticsItem = [:]) {
        switch event.descriptor.type {
        case .view:
            recordViewPage(viewPage: event)
        case .tap:
            recordTap(tap: event)
        default:
                break
        }
    }
    
    static func recordViewPage(viewPage:AnalyticsAppEventProtocol){
        logAppEvent(event: ViewAppEvent(event: viewPage))
        
    }
    
    static func recordTap(tap:AnalyticsAppEventProtocol){
        logAppEvent(event: TapAppEvent(event: tap))

    }
}

enum AnalyticsStrings: String{
    case customerMobileNumber
    case businessName
    case businessId
    case cardDetail
    case projectName
    case pageName
    case Name
    case EventSource
    case traceId
    case isSuccessful
    case paymentChannel
    case time
    case appName
    case OS
    case sdkPlatform = "SDK Platform"
}


class DateHelper{
    static func getCurrentDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
        //return getDate(date: result)
    }
}

extension AppEventDataProtocol {
   
    
    func hubtelData() -> EventStoreData {
        var data = mixpanelData()
        data.data[AnalyticsStrings.time.rawValue] = DateHelper.getCurrentDate()
        data.data[AnalyticsStrings.appName.rawValue] = "Hubtel Mobile Checkout SDK"
        data.data[AnalyticsStrings.OS.rawValue] = "iOS"
        data.data[AnalyticsStrings.sdkPlatform.rawValue] = "SDK Platform"
       
        
        let customer : AnalyticsItem = [
            AnalyticsStrings.customerMobileNumber.rawValue : UserSetupRequirements.shared.customerPhoneNumber
            
        ]
        
        let action : AnalyticsItem = [HubtelEventStoreProperties.actionName.rawValue : data.name ]
        
        let eventStoreData = EventStoreData(
            customer: customer.pascalKeys(),
            page: data.data.pascalKeys(),
            action: action.pascalKeys()
        )
   
        return eventStoreData
    }
}



struct ViewAppEvent: AppEventDataProtocol {
    var event: AnalyticsAppEventProtocol

    func mixpanelData() -> AppEvent {
        return AppEvent(name: AppEventType.view.rawValue, data: [
            AnalyticsParams.General.sectionName.rawValue: event.descriptor.section.rawValue,
            AnalyticsParams.General.pageName.rawValue: event.descriptor.pageName,
            AnalyticsParams.View.viewId.rawValue: event.descriptor.name,
            AnalyticsParams.View.viewName.rawValue: event.descriptor.friendlyName,
            AnalyticsParams.View.viewShortName.rawValue: event.descriptor.shortName
        ])
    }
       
    }

struct TapAppEvent: AppEventDataProtocol {
    var event: AnalyticsAppEventProtocol

    func mixpanelData() -> AppEvent {
        return AppEvent(name: AppEventType.tap.rawValue, data: [
            AnalyticsParams.General.sectionName.rawValue: event.descriptor.section.rawValue,
            AnalyticsParams.General.pageName.rawValue: event.descriptor.pageName,
            AnalyticsParams.Tap.tapId.rawValue: event.descriptor.name,
            AnalyticsParams.Tap.tapName.rawValue: event.descriptor.friendlyName,
            AnalyticsParams.Tap.tapShortName
                .rawValue: event.descriptor.shortName
        ])
    }

   
}


protocol AppEventDataProtocol {

    func mixpanelData() -> AppEvent
}

struct AppEvent {
    var name: String
    var data: AnalyticsItem = [:]
    var dataClone: [String:Any] = [:]

    func isEmpty() -> Bool {
        return name.isEmpty
    }

    static func empty() -> AppEvent {
        return AppEvent(name: "", data: [:])
    }
}

struct BeginPurchaseAppEvent: AppEventDataProtocol {
    var section: AppSection
    var amount: Double
    var purchaseOrderItems : [PurchaseOrderItem]?
    

    func mixpanelData() -> AppEvent {
        let data: AnalyticsItemClone = [
            AnalyticsParams.General.sectionName.rawValue: section.rawValue,
            AnalyticsParams.Purchase.purchaseAmount.rawValue: String(amount),
            AnalyticsParams.Purchase.purchaseOrderItems.rawValue: purchaseOrderItems?.map {$0.toMap()},
            AnalyticsParams.Purchase.purchaseOrderItemNames.rawValue: purchaseOrderItems?.map {$0.name},
            AnalyticsParams.Purchase.purchaseOrderItemProviders.rawValue: purchaseOrderItems?.map {$0.provider}
        ]
        return AppEvent(name: AppEventType.beginPurchase.rawValue, dataClone: data)
    }
}

struct PurchaseOrderItem: RequestProtocol{
    let id : String?
    let name : String?
    let quantity : Int?
    let amount : Double?
    let section : String?
    let provider : String?
}

typealias RequestBody = [String:Any]
typealias HeaderBody = [String:String]


protocol RequestProtocol : Codable {
    
    func toMap() -> RequestBody
    
    func toData() -> Data?
}

extension RequestProtocol {
    
    func toMap() -> RequestBody {
        return self.dictionary
    }
    
    func toData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

extension Encodable {
    
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
