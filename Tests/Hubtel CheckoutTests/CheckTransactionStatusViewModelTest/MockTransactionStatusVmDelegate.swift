//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/4/23.
//

import Foundation
import XCTest
@testable import Hubtel_Checkout

class MockTransactionStatusViewDelegate: CheckoutTransactionStatusDelegate{
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    func showErrorMessageToUser(message: String) {
        expectation.fulfill()
    }
    
    func transactionPending() {
        expectation.fulfill()
    }
    
    func transactionFailed() {
        expectation.fulfill()
    }
    
    func transactionSucceeded() {
        expectation.fulfill()
    }
    
    
    
}
