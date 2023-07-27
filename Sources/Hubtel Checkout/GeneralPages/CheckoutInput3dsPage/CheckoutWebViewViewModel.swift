//
//  File.swift
//  
//
//  Created by Mark Amoah on 6/29/23.
//

import Foundation


@objc protocol CheckOutWebViewDelegate{
   @objc optional func open3dsPage()
   @objc optional func showLoaderWhileMakingNetworkRequest()
    @objc optional func dismissLoaderWhileNetworkResponds()
    @objc optional func showNetworkErrorMessage(message: String)
}

class CheckoutWebViewViewModel: CheckoutRequirements{
    var delegate: CheckOutWebViewDelegate?
    var enrollmentResponse: Enroll3dsResponse?
    
    init(delegate: CheckOutWebViewDelegate){
        self.delegate = delegate
    }
    
    func makeEnrollment(with transactionID: String){
        delegate?.showLoaderWhileMakingNetworkRequest?()
        NetworkManager.makeEnrollmentPayerAuth(salesId: salesID ?? "", transactionId: transactionID, authKey: merchantApiKey ?? "") { data, error in
            
            guard error == nil else{
                self.delegate?.showNetworkErrorMessage?(message: MyError.someThingHappened.message)
                return
            }
            
            guard let data = data else {
                self.delegate?.showNetworkErrorMessage?(message: MyError.someThingHappened.message)
                return
            }
            
            let responseObject = NetworkManager.decode(data: data, decodingType: ApiResponse<Enroll3dsResponse?>.self)
            DispatchQueue.main.async {
                self.handleEnrollmentResponse(value: responseObject)
            }
        }
        
    }
    
    func handleEnrollmentResponse(value: ApiResponse<Enroll3dsResponse?>?){
        
        guard let data = value else{
            self.delegate?.showNetworkErrorMessage?(message: MyError.someThingHappened.message)
            return
        }
        
        guard let responseObject = data.data else{
            self.delegate?.showNetworkErrorMessage?(message: MyError.someThingHappened.message)
            return
        }
        
        self.enrollmentResponse = responseObject
        self.delegate?.open3dsPage?()

        
    }
    
    
    
}
