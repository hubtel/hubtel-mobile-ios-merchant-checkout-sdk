//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/5/23.
//

import Foundation
import XCTest
@testable import Hubtel_Checkout

class Checkout3dsMockDelegate: CheckOutWebViewDelegate{
   let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    func showNetworkErrorMessage(message: String) {
        expectation.fulfill()
    }
    
    func open3dsPage() {
        expectation.fulfill()
    }
    
    

    

}
