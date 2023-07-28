//
//  NetworkManagerTest.swift
//  
//
//  Created by Mark Amoah on 7/5/23.
//

import XCTest
@testable import Hubtel_Checkout

final class NetworkManagerTest: XCTestCase {

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

extension NetworkManagerTest{
    func test_make_post_Request_method_does_not_produce_nil(){
        let url = URL(string: "https://www.myurl.com")
        let request = NetworkManager.makeRequest(endpoint: url!, apiKey: "111666", body:GetFeesBody(amount: 1, channel: "togo"))
        XCTAssertNotNil(request, "request must not be nil")
    }
    
    func test_make_get_request_does_not_produce_nil(){
        let url = URL(string: "https://www.myurl.com")
        let request = NetworkManager.makeRequest(endpoint: url!, apiKey: "111666")
        XCTAssertNotNil(request, "request must not be nil")
        
    }
    
    func test_decoding_failure_produces_nil(){
        let decodedData  = NetworkManager.decode(data: CardWhitelistingMockModel.shared.encodedData!, decodingType: MockFailureStructure.self)
        XCTAssertNil(decodedData, "Should produce nil because decoding type is different from data structure")
    }
    
    func test_decoding_success_produces_non_nil_value(){
        let decodedData = NetworkManager.decode(data: CardWhitelistingMockModel.shared.encodedElevyString!, decodingType: ApiResponse<[GetFeesResponse]?>.self)
        XCTAssertNotNil(decodedData, "Should not be nil because decoding type matches data structure")
    }
}
