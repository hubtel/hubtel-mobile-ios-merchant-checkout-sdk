//
//  File.swift
//  
//
//  Created by Mark Amoah on 6/25/23.
//

import Foundation
import UIKit

@objc protocol ViewStatesDelegate{
    @objc optional func showErrorMessagetToUser(message: String)
    @objc optional func showLoaderOnBottomButtonIfNeeded(with value: Bool)
    @objc optional func showLoadingStateWhileMakingNetworkRequest(with value: Bool)
    @objc optional func updateFeesValue(value: [GetFeesUpdateView])
    @objc optional func dismissLoaderWhileFetchingData()
    @objc optional func dismissLoaderToPerformAnotherAction()
    @objc optional func dismissLoaderToPerformWebCheckout()
    @objc optional func dismissLoaderToPerformMomoPayment()
    @objc optional func handleBankPaymentForReviewCardCase()
    @objc optional func handleBankPaymentForApproveCardCase()
    @objc optional func handleBankPaymentForRejectCardCase()
    @objc optional func handleBothBankAndMobileMoney()
    @objc optional func handleOnlyBankPayment()
    @objc optional func handleOnlyMobileMoney()
    @objc optional func showErrorToDismiss(message: String, dismiss: Bool)
    @objc optional func activateFeesButton(value: Bool)
    @objc optional func handleWalletsUpdate(value: [Wallet])
    @objc optional func handleBusinessInfoPassed(businessId: String?, businessName: String?, businessImageUrl: String?)
    @objc optional func handleVerificationStatus(value: VerificationResponse?)
    @objc optional func handleOnlyCheckoutHeader()
    @objc optional func handleWalletsForInternalMerchants()
//    @objc optional func handleDirectDebitAction(transaction: MomoResponse?)
}

protocol CheckoutRequirements{
    var salesID: String? {get}
    var merchantApiKey: String? {get}
    var callbackUrl: String? {get}
}

extension CheckoutRequirements{
    var salesID: String?{
        UserSetupRequirements.shared.salesID
    }
    var merchantApiKey: String?{
        UserSetupRequirements.shared.apiKey
    }
    
    var callbackUrl: String?{
        UserSetupRequirements.shared.callBackUrl
    }
}



class CheckOutViewModel: CheckoutRequirements, PaymentProtocol{
    
    var task: URLSessionDataTask?
    
    weak var delegate: ViewStatesDelegate?
    
    var order: PurchaseInfo?
    
    var paymentType: String?
    
    lazy var totalAmount: Double = order?.amount ?? 0.00
    
    var setupResponse: Setup3dsResponse?
    
    var momoResponse: MomoResponse?
    
    var momoNumber: String?
    
    var cardWhitelistCheckResponseObj: CardWhiteListResponse?
    
    var fees: [GetFeesUpdateView]?
    
    var imageUpdater = ImageUpdatShowerUpdate()
    
    var providerChannel: String = ""
    
    var feesToUpdateFrontend: [GetFeesUpdateView]?
    
    static var allowPayment: Bool = false
    
    static var checkoutType: CheckoutType = .receivemoneyprompt
    
    var preApprovalResponse: PreApprovalResponse?
    
    var merchantRequiresKyc: Bool = false
    
    var isHubtelInternalMerchant = false
    
    var bankCardForPayment: BankDetails?
    
    var feeAmount: Double = 0.00
    
    static var isHubtelMerchantEnabled: Bool = false
    
    init(delegate: ViewStatesDelegate, imageUpdater: ImageUpdatShowerUpdate = ImageUpdatShowerUpdate()){
        self.delegate = delegate
    }
    
    
    func getFees(for paymentType: String){
        task?.cancel()
        delegate?.showLoaderOnBottomButtonIfNeeded?(with: true)
        let requestBody = GetFeesBody(amount: order?.amount ?? 0, channel: paymentType)

        task = NetworkManager.getFeesApi(salesId: salesID ?? "", authKey: merchantApiKey ?? "", requestBody: requestBody, completion: { data, error in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                    self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
                }
               
                return
            }
            
            let dataResponse  =  NetworkManager.decode(data: data, decodingType: ApiResponse<[GetFeesResponse]?>.self)
            DispatchQueue.main.async {
                self.handleApiResponseForFees(value: dataResponse)
            }
        })
        
    }
    
    func getPaymentChannels(completion: @escaping (Bool, Bool)->Void ){
        let bankAllowed = UserDefaults.standard.object(forKey: PaymentChannelCachedKeys.isBankAllowed) as? Bool
        let momoAllowed = UserDefaults.standard.object(forKey: PaymentChannelCachedKeys.isMomoAllowed) as? Bool
        let isStoredHubtelInternalMerchant = UserDefaults.standard.object(forKey: PaymentChannelCachedKeys.isHubtelInternalMerchant) as? Bool
        let showErrorMessage = bankAllowed == nil && momoAllowed == nil
//        if let bankAllowed = bankAllowed, let momoAllowed = momoAllowed, let isStoredHubtelInternalMerchant = isStoredHubtelInternalMerchant{
//
//            if let cachedPaymentChannels = UserDefaults.standard.object(forKey: "paymentChannels") as? [String]{
//               let _ = self.handlePaymentChanelResponse(channels: cachedPaymentChannels)
//            }
////            self.isHubtelInternalMerchant = isStoredHubtelInternalMerchant
//
////            completion(momoAllowed, bankAllowed)
//            delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
//
//        }else{
            delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
//        }
        
        NetworkManager.checkPaymentChannels(salesID: salesID ?? "", authKey: merchantApiKey ?? "") { data, error in
            guard error == nil else{
                if showErrorMessage{
                    self.delegate?.showErrorToDismiss?(message: MyError.someThingHappened.message, dismiss: true)
                }
                return
            }
            guard let data = data else{
                if showErrorMessage{
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            let dataResponse = NetworkManager.decode(data: data, decodingType: ApiResponse<ChannelFetchResponse?>.self)
            
            guard let response = dataResponse?.data else {
                if showErrorMessage{
                    self.delegate?.showErrorToDismiss?(message: MyError.someThingHappened.message, dismiss: true)
                }
                return
            }
            
            guard let channels = response.channels else{
                self.delegate?.showErrorToDismiss?(message: MyError.someThingHappened.message, dismiss: true)
                return
            }
            
            let paymentChannelHandler = self.handlePaymentChanelResponse(channels: channels)
            
           
//            UserDefaults.standard.set(paymentChannelHandler.mobileMoneyAllowed, forKey: PaymentChannelCachedKeys.isMomoAllowed)
//
            
            self.cache(value: paymentChannelHandler.bankAllowed, forKey: PaymentChannelCachedKeys.isBankAllowed)
            self.cache(value: paymentChannelHandler.mobileMoneyAllowed, forKey: PaymentChannelCachedKeys.isMomoAllowed)
            
            self.cache(value: response.isHubtelInternalMerchant ?? false, forKey: PaymentChannelCachedKeys.isHubtelInternalMerchant)
            
            self.delegate?.handleBusinessInfoPassed?(businessId: response.businessId, businessName: response.businessName, businessImageUrl: response.businessLogoUrl)
            
            self.merchantRequiresKyc = response.merchantRequiresKyc
            
            
            if response.isHubtelInternalMerchant ?? false{
               self.isHubtelInternalMerchant = true
                Self.isHubtelMerchantEnabled = true
                
                self.delegate?.dismissLoaderToPerformAnotherAction?()
                
                self.makeGetWallets(customerMsisdn: UserSetupRequirements.shared.customerPhoneNumber )
                completion(paymentChannelHandler.mobileMoneyAllowed, paymentChannelHandler.bankAllowed)
                
                
            }else{
                
                completion(paymentChannelHandler.mobileMoneyAllowed, paymentChannelHandler.bankAllowed)
            }
            
        }
    }
    
    
    func cache(value: Bool, forKey key: String){
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    
    func handlePaymentChanelResponse(channels: [String])->(mobileMoneyAllowed: Bool, bankAllowed: Bool){
        imageUpdater = ImageUpdatShowerUpdate(
            showMtn: channels.contains(where: {$0.hasPrefix("mtn")}),
            showAirtel: channels.contains(where: {$0.hasPrefix("tigo")}),
            showVoda: channels.contains(where: {$0.hasPrefix("vodafone")}),
            showVisa: channels.contains(where: {$0.contains("visa")}),
            showMasterCard: channels.contains(where: {$0.contains("mastercard")})
        )
        
//        PaymentOptions.options = PaymentOptions.convertArrayToDict(value:channels)
        self.providerChannel = PaymentChannel.getChannel(string:Array(PaymentOptions.options.keys).count > 0 ? Array(PaymentOptions.options.keys)[0] : "").rawValue
        
//        UserDefaults.standard.set(PaymentOptions.convertArrayToDict(value:channels), forKey: "paymentChannels")
        
        
        return (mobileMoneyAllowed: channels.contains(where: {$0.hasPrefix("mtn") || $0.hasPrefix("vodafone") || $0.hasPrefix("tigo")}), bankAllowed: channels.contains(where: {$0.hasPrefix("cardnotpresent-visa") || $0.hasPrefix("cardnotpresent-mastercard") || $0.contains("cardpresent-mastercard") || $0.hasPrefix("cardpresent-visa")}))
    }
    
    func paymentChannelsAllowed(){
        
        if isHubtelInternalMerchant{
            
        }
        
        getPaymentChannels { mobileMoneyAllowed, bankPaymentAllowed in
            switch (mobileMoneyAllowed, bankPaymentAllowed){
            case (true, true):
                
                if self.isHubtelInternalMerchant{
                    self.delegate?.handleWalletsForInternalMerchants?()
                }else{
                    self.delegate?.handleBothBankAndMobileMoney?()
                }
            case (true, false):
                self.delegate?.handleOnlyMobileMoney?()
            case (false, true):
                self.delegate?.handleOnlyBankPayment?()
            default:
                self.delegate?.handleOnlyCheckoutHeader?()
                break
            }
        }
    }
    
    
    func handleApiResponseForFees(value: ApiResponse<[GetFeesResponse]?>?){
        dump(value)
        guard let responseObject = value else{
            self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
            return
        }
        
        if let feesData = responseObject.data{
            let feesDoubleDat = feesData.compactMap {$0.amount}
            self.totalAmount = self.order?.calculateTotal(value: feesDoubleDat) ?? 0.00
            
            let finalAmountValue = feesData.map {
                GetFeesUpdateView(name: $0.name, amount: $0.amount)
            }
            self.fees = finalAmountValue
            delegate?.updateFeesValue?(value: finalAmountValue)
        }
        
        self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
        
        
    }
    
    
    
    func handleApiResponseForSetupPayerAuthRequest(value: ApiResponse<Setup3dsResponse?>?){
        guard value?.errors == nil else{
            if let validationErrors = value?.errors{
                validationErrors.count > 0 ? delegate?.showErrorMessagetToUser?(message: validationErrors[0].errorMessage ?? "") : delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            }
            return
        }
        
        guard let data = value else{
            delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        guard let responseObject = data.data else{
            delegate?.showErrorMessagetToUser?(message: data.message ?? MyError.someThingHappened.message)
            return
        }
        self.setupResponse = responseObject
        self.delegate?.dismissLoaderToPerformWebCheckout?()
           
    }
    
    func handleApiResponseForMobileMoneyPayment(value: ApiResponse<MomoResponse?>?){
        
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            return
        }
        self.momoResponse = responseObject
        self.delegate?.dismissLoaderToPerformMomoPayment?()
    }
    
    
    
    func generateSetupRequest(with details: BankDetails?, useSavedCard: Bool = false)->SetupPayerAuthRequest?{
        
        let uuid  = UUID()
        
        let uuidString = uuid.uuidString
        
        if let details = details{
            
        return SetupPayerAuthRequest(amount: totalAmount, cardHolderName: details.cardHolderName, cardNumber: details.cardHolderNumber, cvv: details.cvv, expiryMonth: details.expiryMonth, expiryYear: details.expiryYear, customerMsisdn: order?.customerMsisDn ?? "", description: order?.purchaseDescription ?? "", clientReference: order?.clientReference ?? uuidString, callbackUrl: callbackUrl ?? "")
            
        }else{
            
            return nil
            
        }
        
    }
    
    
    func payWithBank(with request: SetupPayerAuthRequest?) {
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        guard let request = request else{
            DispatchQueue.main.async {
                self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            }
               
            return
        }
        
        
        NetworkManager.makeSetupPayerAuthRequest(requestBody: request, salesId: salesID ?? "",  apiKey: merchantApiKey ?? "") { data, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<Setup3dsResponse?>.self)
            
            DispatchQueue.main.async{
                self.handleApiResponseForSetupPayerAuthRequest(value: decodedData)
            }
        }
    }
    
    
    func handleBankPaymentWhitelist(){
        guard let encodedString = CardWhitelistingMockModel.shared.encodedData else{
            delegate?.showErrorMessagetToUser?(message: "Cannot encode data")
            return
        }
        
        guard let responseObj = NetworkManager.decode(data: encodedString, decodingType: ApiResponse<CardWhiteListResponse?>.self) else{
            delegate?.showErrorMessagetToUser?(message: "Cannot encode data")
            return
        }
        
        handleApiResponseForWhiteListApi(value: responseObj)
        
        
        
        
    }
    
//    ----------- Handle Bank Payment Tap Pay new with whiteList and fraudLabs--------------
    func handleApiResponseForWhiteListApi(value: ApiResponse<CardWhiteListResponse?>){
        guard value.errors == nil else{
            delegate?.showErrorMessagetToUser?(message: value.message ?? "")
            return
        }
        
        guard let responseObject = value.data else{
            delegate?.showErrorMessagetToUser?(message: value.message ?? "")
            return
        }
        
        self.cardWhitelistCheckResponseObj = responseObject
        switch responseObject.fraudLabsStatus{
        case .approve:
            delegate?.handleBankPaymentForApproveCardCase?()
        case .reject:
            delegate?.handleBankPaymentForRejectCardCase?()
        case .review:
            delegate?.handleBankPaymentForReviewCardCase?()
        }
        
        
    }
    
    
    
    func paywithMomo(request:MobileMoneyPaymentRequest){
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.makeMobileMoneyPaymentsRequest(salesID: salesID ?? "", authKey: merchantApiKey ?? "", requestBody: request) { data, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
           
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<MomoResponse?>.self)
           
            DispatchQueue.main.async {
                self.handleApiResponseForMobileMoneyPayment(value: decodedData)
            }
            
        }
    }
    
    func makeDirectDebit(request: MakeDirectDebitCallBody){
        
        print(request)
        
        dump(request)
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.makeDirectDebitCall(merchantId: salesID ?? "", authKey: merchantApiKey ?? "", body: request) { data, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<MomoResponse?>.self)
            
            self.handleApiResponseForMobileMoneyPayment(value: decodedData)
        }
    }
    
    func handleApiResponseForPreApprovalConfirm(value: ApiResponse<PreApprovalResponse?>?){
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            return
        }
        self.preApprovalResponse = responseObject
        self.delegate?.dismissLoaderToPerformMomoPayment?()
    }
    
    func handleApiResponseForWallets(value: ApiResponse<[Wallet]?>?){
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            return
        }
//        self.delegate?.dismissLoaderToPerformMomoPayment?()
//        self.delegate?.dismissLoaderToPerformAnotherAction?()
        delegate?.handleWalletsUpdate?(value: responseObject)
    }
    
    
    
    func handleNewGetFees(value: ApiResponse<NewGetFeesResponse?>?){
        
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
            return
        }
        
        
        Self.checkoutType = responseObject.getCheckoutType
        
        let getfeesResponse = GetFeesUpdateView(name: "Fees", amount: responseObject.fees)
        
        self.totalAmount = responseObject.amountPayable
        
        self.feeAmount = responseObject.fees
        
        delegate?.updateFeesValue?(value: [getfeesResponse])
        
        self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
    }
    
    
    func makeGetFeesNewEndPoint(channel: String, amount: Double){
        task?.cancel()
        delegate?.showLoaderOnBottomButtonIfNeeded?(with: true)
        NetworkManager.getFeesNew(salesId: salesID ?? "", authKey: merchantApiKey ?? "", amount: amount, channel: channel) { data, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                    self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<NewGetFeesResponse?>.self)
            
            self.handleNewGetFees(value: decodedData)
            
            
            
            
        }
    }
    
    
    
    func makePreapprovalConfirm(channel: String, customerMsisdn: String, clientReference: String){
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.preApprovalConfirm(merchantId: salesID ?? "", authKey: merchantApiKey ?? "", amount: totalAmount, clientReference: clientReference, customerMsisdn: customerMsisdn, channel: channel, callbackUrl: UserSetupRequirements.shared.callBackUrl) { data, error in
            
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                    self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<PreApprovalResponse?>.self)
            
            self.handleApiResponseForPreApprovalConfirm(value: decodedData)
            
        }
    }
    
    func makeGetWallets( customerMsisdn: String){
//        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.getWallets(salesId: salesID ?? "", authKey: merchantApiKey ?? "", mobileNumber: customerMsisdn ) { data, error in
            print(error)
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                    self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<[Wallet]?>.self)
            
            self.handleApiResponseForWallets(value: decodedData)
            
        }
    }
    
    
    func checkUserVerificationStatus(mobileNumber: String){
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.getVerificationDetails(salesId: salesID ?? "", authKey: merchantApiKey ?? "", mobileNumber: mobileNumber){ data, error in
            print(error)
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            
            guard let data = data  else {
                DispatchQueue.main.async {
                    self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
                    self.delegate?.showLoaderOnBottomButtonIfNeeded?(with: false)
                }
                return
            }
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<VerificationResponse?>.self)
            
            self.handleVerificationResponse(value: decodedData)
            
        }
    }
    
    func handleVerificationResponse(value: ApiResponse<VerificationResponse?>?){
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
//            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            self.delegate?.handleVerificationStatus?(value: nil)
            return
        }
        
        self.delegate?.handleVerificationStatus?(value: responseObject)
    }
    
    
    
    
    
}
