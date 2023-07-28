//
//  Checkout3dsPageTest.swift
//  
//
//  Created by Mark Amoah on 7/5/23.
//

import XCTest
@testable import Hubtel_Checkout

final class Checkout3dsPageTest: XCTestCase {

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

extension Checkout3dsPageTest{
    
    func test_value_parameter_nil_shows_Error_to_user(){
        let expectation = self.expectation(description: "Having value as nil shows error message to user")
        let delegate = Checkout3dsMockDelegate(expectation: expectation)
        let vm = CheckoutWebViewViewModel(delegate: delegate)
        vm.handleEnrollmentResponse(value: nil)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_data_nil_shows_Error_to_user(){
        let expectation = self.expectation(description: "Having data as nil shows error message to user")
        let delegate = Checkout3dsMockDelegate(expectation: expectation)
        let vm = CheckoutWebViewViewModel(delegate: delegate)
        vm.handleEnrollmentResponse(value: CardWhitelistingMockModel.shared.failedEnrollmentResponse)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_data_not_nil_shows_Error_to_user(){
        let expectation = self.expectation(description: "Having data as not results in a success case")
        let delegate = Checkout3dsMockDelegate(expectation: expectation)
        let vm = CheckoutWebViewViewModel(delegate: delegate)
        vm.handleEnrollmentResponse(value: CardWhitelistingMockModel.shared.successEnrollmentResponse)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    
}
