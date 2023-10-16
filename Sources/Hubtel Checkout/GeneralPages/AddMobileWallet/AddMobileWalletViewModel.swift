//
//  File.swift
//  
//
//  Created by Mark Amoah on 10/3/23.
//

import Foundation


class AddMobileWalletViewModel: CheckoutRequirements{
    
    var delegate: ViewStatesDelegate?
    
    var provider: String?
    
    var selectedMobileNetwork: MobileMoneyWalletOptions?
    
    var successMessage: String?
    
   
    
    init(delegate: ViewStatesDelegate?){
        self.delegate = delegate
    }
    
    
    func makeAddMoneyWallet(requestBody: AddMobileWalletBody){
            delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.addMobileWalletToAccount(salesId: salesID ?? "", authKey: merchantApiKey ?? "", requestBody: requestBody) { data, error in
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
               
                let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<Wallet?>.self)
               
                DispatchQueue.main.async {
                    self.handleApiResponseForMobileMoneyPayment(value: decodedData)
                }
                
            }
    }
    
    func handleApiResponseForMobileMoneyPayment(value: ApiResponse<Wallet?>?){
        
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        dump(data, name: "Data is showing here")
        guard let responseObject  = data.data else {
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            return
        }
        self.successMessage = value?.message ?? ""
//        self.momoResponse = responseObject
        self.delegate?.dismissLoaderToPerformMomoPayment?()
    }
    
    
    
}
