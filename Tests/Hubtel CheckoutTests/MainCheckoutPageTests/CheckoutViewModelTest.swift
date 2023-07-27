//
//  CheckoutViewModelTest.swift
//  
//
//  Created by Mark Amoah on 7/4/23.
//

import XCTest
@testable import Hubtel_Checkout

final class CheckoutViewModelTest: XCTestCase {
    let mockOrder = PurchaseInfo(itemPrice: 1.00)
    let dataForFees = NetworkManager.decode(data: CardWhitelistingMockModel.shared.encodedElevyString!, decodingType:  ApiResponse<[GetFeesResponse]?>.self)

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
    
    }

    func testExample() throws {
      
    }

    func testPerformanceExample() throws {
        
        self.measure {
         
        }
    }

}

extension  CheckoutViewModelTest{
    
    func test_handle_Api_Response_for_get_fees_nil_response(){
        let expectation = self.expectation(description: "nil values for response should stop the button from loading")
        let viewModelDelegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: viewModelDelegate)
        vm.handleApiResponseForFees(value: nil)
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func test_handle_Api_Response_data_response_update_total(){
        let expectation = self.expectation(description: "reponse with data will update total_value")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.order = mockOrder
        vm.handleApiResponseForFees(value: dataForFees)
        XCTAssert(vm.totalAmount == 1.20)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_handle_api_Response_for_fees_updates_fees_variable(){
        let expectation = self.expectation(description: "fees variable should not be nil once handleResponse for Fees is called")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.handleApiResponseForFees(value: dataForFees)
        XCTAssert(vm.fees != nil, "Fees must not be nil after operation")
        expectation.fulfill()
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_handle_api_Response_for_setup_payer_auth_request_nil(){
        let expectation = self.expectation(description: "Show error message to user if value parameter is nil")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.handleApiResponseForSetupPayerAuthRequest(value: nil)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_handle_Api_Response_for_setup_Payer_Auth_with_request_Data_nil(){
        let expectation = self.expectation(description: "Show error message to user when data is nil")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.handleApiResponseForSetupPayerAuthRequest(value: CardWhitelistingMockModel.shared.mockSetupPayerAuthErrorResponse)
        waitForExpectations(timeout: 0.2, handler: nil)
        
    }
    
    
    func test_handle_Api_Response_for_setup_payer_Auth_successful(){
        let epectation = self.expectation(description: "Successful payer Auth Request")
        let delegate = MockViewStateDelegate(expectation: epectation)
        let vm = CheckOutViewModel(delegate:delegate)
        vm.handleApiResponseForSetupPayerAuthRequest(value: CardWhitelistingMockModel.shared.successFulSetupPayerAuthComplet)
        XCTAssert(vm.setupResponse != nil)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func test_handle_Api_Response_for_mobile_money_payment(){
        let expectation = self.expectation(description: "Show error message to user if value parameter is nil")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.handleApiResponseForMobileMoneyPayment(value: nil)
        waitForExpectations(timeout: 0.2, handler: nil)
        
    }
    
    func test_handle_Api_Response_for_momo_request_Data_nil(){
        let expectation = self.expectation(description: "Show error message to user when data is nil")
        let delegate = MockViewStateDelegate(expectation: expectation)
        let vm = CheckOutViewModel(delegate: delegate)
        vm.handleApiResponseForMobileMoneyPayment(value: CardWhitelistingMockModel.shared.mockmomoErrorResponse)
        waitForExpectations(timeout: 0.2, handler: nil)
        
    }
    
    func test_handle_Api_Response_for_momoPay_successful(){
        let epectation = self.expectation(description: "Successful momo request")
        let delegate = MockViewStateDelegate(expectation: epectation)
        let vm = CheckOutViewModel(delegate:delegate)
        vm.handleApiResponseForSetupPayerAuthRequest(value: CardWhitelistingMockModel.shared.successFulSetupPayerAuthComplet)
        XCTAssert(vm.setupResponse != nil)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    
    
    
    
    
    
}
