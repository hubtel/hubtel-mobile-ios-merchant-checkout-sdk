//
//  File.swift
//  
//
//  Created by Mark Amoah on 5/31/23.
//

import Foundation


class Strings{
    static let payWith = "Select payment method"
    static let bankCard = "Bank Card"
    static let emptyString = ""
    static let regularSans = "NunitoSans-Regular"
    static let fontExtension = "ttf"
    static let extraBoldSans = "NunitoSans-ExtraBold"
    static let sansSemiBold = "NunitoSans-SemiBold"
    static let alert = "Alert"
    static let wantToCancelTransaction = "Do you want to cancel this transation?"
    static let no = "No"
    static let yes = "Yes"
    static let myCard = "myCard"
    static let useSavedCard = "Use a saved card"
    static let useNewCard = "Use a new card"
    static let bankPaymentCell = "BankPaymentCell"
    static let cardNumberPlaceHolder = "1234 5678 9223 2234"
    static let accountHolderPlaceHolder = "Name on Card"
    static let expiryPlaceHolder = "MM/YY"
    static let cvvPlaceHolder = "cvv"
    static let saveCardForFutureUse = "Save this card for future use"
    static let validationErrors = "Validation Errors"
    static let somethingWentWrong = "Something Went wrong"
    static let ValidationErrors = "Incorrect details on card entered, please check"
    static let mobileMoneyNumberTakerPlaceHolder = "Enter your mobile money number"
    static let mobileMoney = "Mobile Money"
    static func setMomoPrompt(with mobileNumber: String)->String{
        return "A bill prompt has been sent to \(mobileNumber). Please authorise the payment."
    }
    static let success =  "Success"
    static let confirmOrder = "Confirm Order"
    static let checkStatus = "CHECK STATUS"
}
