//
//  TransactionStatusVMtests.swift
//  
//
//  Created by Mark Amoah on 7/4/23.
//

import XCTest
@testable import Hubtel_Checkout

final class TransactionStatusVMtests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension TransactionStatusVMtests{
    
    func test_value_parameter_nil_shows_Error_to_user(){
        let expectation = self.expectation(description: "Having value as nil shows error message to user")
        let delegate = MockTransactionStatusViewDelegate(expectation: expectation)
        let vm = CheckoutTransactionStatusViewModel(delegate: delegate)
        vm.handleTransactionSummaryCheckApiResponse(value: nil)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_data_is_nil_shows_Error_to_user(){
        let expectation = self.expectation(description: "Nil Data shows error message to user")
        let delegate = MockTransactionStatusViewDelegate(expectation: expectation)
        let vm = CheckoutTransactionStatusViewModel(delegate: delegate)
        vm.handleTransactionSummaryCheckApiResponse(value: CardWhitelistingMockModel.shared.failureTransactionStatusCheck)
        waitForExpectations(timeout: 0.2, handler: nil)
        
    }
    
    
    func test_pending_case_shows_pending_state(){
        let expectation = self.expectation(description: "pending case shows pending state")
        let delegate = MockTransactionStatusViewDelegate(expectation: expectation)
        let vm = CheckoutTransactionStatusViewModel(delegate: delegate)
        vm.handleTransactionSummaryCheckApiResponse(value: CardWhitelistingMockModel.shared.pendingTransactionStatusCheck)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_failed_case_shows_failed_state(){
        let expectation = self.expectation(description: "failed case shows failed state")
        let delegate = MockTransactionStatusViewDelegate(expectation: expectation)
        let vm = CheckoutTransactionStatusViewModel(delegate: delegate)
        vm.handleTransactionSummaryCheckApiResponse(value: CardWhitelistingMockModel.shared.failedtransactionStatusCheck)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_success_case_shows_success_state(){
        let expectation = self.expectation(description: "success case shows success state")
        let delegate = MockTransactionStatusViewDelegate(expectation: expectation)
        let vm = CheckoutTransactionStatusViewModel(delegate: delegate)
        vm.handleTransactionSummaryCheckApiResponse(value: CardWhitelistingMockModel.shared.failedtransactionStatusCheck)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
}
