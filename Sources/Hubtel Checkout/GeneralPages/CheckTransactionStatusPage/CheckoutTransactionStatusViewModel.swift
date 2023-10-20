//
//  File.swift
//  
//
//  Created by Mark Amoah on 6/25/23.
//

import Foundation

@objc protocol CheckoutTransactionStatusDelegate{
    @objc optional func validateButton(buttonString: String)
    @objc optional func invalidateButton()
    @objc optional func transactionSucceeded()
    @objc optional func transactionPending()
    @objc optional func transactionFailed()
    @objc optional func showErrorMessageToUser(message: String)
    @objc optional func validateAndSetTimer()
    @objc optional func changeImageOnScreen()
}

class CheckoutTransactionStatusViewModel: CheckoutRequirements{
    
    var delegate: CheckoutTransactionStatusDelegate
    
    init(delegate: CheckoutTransactionStatusDelegate){
        self.delegate = delegate
    }
    
    func getTransactionStatus(transactionID: String){
        NetworkManager.checkPaymentsStatus(salesID: salesID ?? "", authKey: merchantApiKey ?? "", transactionID: transactionID) { data, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
           
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<TransactionStatusResponse?>.self)
            
            DispatchQueue.main.async {
                self.handleTransactionSummaryCheckApiResponse(value: decodedData)
            }
        }
    }
    
    func checkTransactionStatus(clientReference: String){
        NetworkManager.checkStatusOfTransaction(salesID: salesID ?? "", authKey: merchantApiKey ?? "", clientRefrence: clientReference){ data, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
           
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<CheckStatusRespsonse?>.self)
            
            DispatchQueue.main.async {
                self.handleNewTransactionSummaryCheckApiResponse(value: decodedData)
            }
        }
    }
    
    func checkTransactionStatusPreApprovalConfirm(clientReference: String){
        NetworkManager.checkStatusofTransactionPreApproval(salesID: salesID ?? "", authKey: merchantApiKey ?? "", clientRefrence: clientReference){ data, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    self.delegate.showErrorMessageToUser?(message: MyError.someThingHappened.message)
                }
                return
            }
           
            
            let decodedData = NetworkManager.decode(data: data, decodingType: ApiResponse<CheckStatusRespsonse?>.self)
            
            DispatchQueue.main.async {
                self.handleNewTransactionSummaryCheckApiResponse(value: decodedData)
            }
        }
    }
    
    func handleNewTransactionSummaryCheckApiResponse(value: ApiResponse<CheckStatusRespsonse?>? ){
        guard value?.errors == nil else{
            delegate.showErrorMessageToUser?(message: value?.message ?? "")
            return
        }
        
        guard let data = value else{
            delegate.showErrorMessageToUser?(message: value?.message ?? "")
            return
        }
        
        if let status = data.data?.getStatus{
            switch status{
            case .unpaid:
                delegate.transactionPending?()
            case .failed:
                delegate.transactionFailed?()
            case .paid:
                delegate.transactionSucceeded?()
            case .expired:
                delegate.transactionFailed?()
            case .pending:
                delegate.transactionPending?()
            }
            delegate.changeImageOnScreen?()
            
        }else{
            delegate.validateAndSetTimer?()
        }
    }
    
    func handleTransactionSummaryCheckApiResponse(value: ApiResponse<TransactionStatusResponse?>? ){
        guard value?.errors == nil else{
            delegate.showErrorMessageToUser?(message: value?.message ?? "")
            return
        }
        
        guard let data = value else{
            delegate.showErrorMessageToUser?(message: value?.message ?? "")
            return
        }
        
        if let status = data.data?.transactionStatus?.lowercased(){
            switch status{
            case TransactionStatus.pending.rawValue:
                delegate.transactionPending?()
            case TransactionStatus.failed.rawValue:
                delegate.transactionFailed?()
            case TransactionStatus.success.rawValue:
                delegate.transactionSucceeded?()
            default:
                delegate.transactionPending?()
            }
            delegate.changeImageOnScreen?()
            
        }else{
            delegate.validateAndSetTimer?()
        }
    }
}
