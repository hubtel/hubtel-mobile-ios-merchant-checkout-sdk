//
//  File.swift
//  
//
//  Created by Mark Amoah on 9/21/23.
//

import Foundation


class GovVerificationViewModel: CheckoutRequirements{
    
    
    var delegate: ViewStatesDelegate?
    
    func makeVerificationConfirmation( customerMsisdn: String, body: CustomerVerificationBody?){
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.ConfirmGhanaCardDetails(salesId: salesID ?? "", authKey: merchantApiKey ?? "", mobileNumber: customerMsisdn, body: body){ data, error in           
            
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
            
            let responseObj = NetworkManager.decode(data: data, decodingType: ApiResponse<ConfirmationResponse?>.self)
            
            self.handleConfirmationResponse(value: responseObj)
            
        }
    }
    
    func handleConfirmationResponse(value: ApiResponse<ConfirmationResponse?>?){
        guard let data = value else {
            self.delegate?.showErrorMessagetToUser?(message: MyError.someThingHappened.message)
            return
        }
        
        
        guard let responseObject  = data.data else {
//            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            self.delegate?.handleOnlyMobileMoney?()
            return
        }
        
        self.delegate?.handleOnlyMobileMoney?()
        
    }
    
    
    
    func inputGhanaCardVerificationDetails(customerMsisdn: String, idNumber: String){
        delegate?.showLoadingStateWhileMakingNetworkRequest?(with: true)
        NetworkManager.inputGhanaCardDetails(salesId: salesID ?? "", authKey: merchantApiKey ?? "", mobileNumber: customerMsisdn, idNumber: idNumber){ data, error in
            
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
            self.delegate?.showErrorMessagetToUser?(message: data.message ?? "")
            return
        }
        
        self.delegate?.handleVerificationStatus?(value: responseObject)
        
    }
    
    
    
    
    
}
