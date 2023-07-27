//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/4/23.
//

import Foundation
import XCTest
@testable import Hubtel_Checkout


class MockViewStateDelegate: ViewStatesDelegate{
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation){
        self.expectation = expectation
    }
    
    
    func showLoaderOnBottomButtonIfNeeded(with value: Bool) {
        if expectation.description == "nil values for response should stop the button from loading"{
            if value == false{
                expectation.fulfill()
            }
        }
        if expectation.description == "reponse with data will update total_value"{
            if value == false{
                expectation.fulfill()
            }
        }
    }
    
    func showErrorMessagetToUser(message: String) {
        if expectation.description == "Show error message to user if value parameter is nil"{
            expectation.fulfill()
        }
        if expectation.description == "Show error message to user when data is nil"{
            expectation.fulfill()
        }
    }
    
    func dismissLoaderToPerformWebCheckout() {
        expectation.fulfill()
    }
    
    func dismissLoaderToPerformMomoPayment() {
        expectation.fulfill()
    }
    
    
    
    
}
