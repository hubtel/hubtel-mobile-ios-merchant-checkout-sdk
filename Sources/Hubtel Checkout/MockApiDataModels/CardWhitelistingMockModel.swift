//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/1/23.
//

import Foundation


class CardWhitelistingMockModel{
    static let shared = CardWhitelistingMockModel()
    private init(){}
    let jsonString = """
 {
   "message": "Success",
   "code": 200,
   "data": {
     "id": "5eec94d5f6c54a1585c66669ebdaa551",
     "mobileNumber": "233554021947",
     "cardName": "Kweku Ayepah",
     "cardNumber": "463484XXXXXX7997",
     "createdAt": "2023-07-01T05:09:26.195281Z",
     "status": "REVIEW",
     "gatewayChannel": "3DS",
     "providerChannel": "Cybersource",
     "expiryMonth": 4,
     "expiryYear": 24,
     "fraudLabId": "20230701-KRNGPC",
     "fraudCheckResponse": {
       "cardType": "Credit",
       "cardSubtype": "Platinum",
       "cardIssuingBank": "Barclays Bank Of Ghana, Ltd.",
       "cardIssuingCountry": "GH",
       "fraudlabsproScore": 96,
       "fraudlabsproDistribution": "100",
       "fraudlabsproStatus": "REVIEW",
       "fraudlabsproId": "20230701-KRNGPC",
       "fraudlabsproRules": "Fraud Score GREATER THAN 80"
     }
   },
   "subCode": "0",
   "errors": null
 }
"""
let jsonStringApprove = """
{
  "message": "Success",
  "code": 200,
  "data": {
    "id": "5eec94d5f6c54a1585c66669ebdaa551",
    "mobileNumber": "233554021947",
    "cardName": "Kweku Ayepah",
    "cardNumber": "463484XXXXXX7997",
    "createdAt": "2023-07-01T05:09:26.195281",
    "status": "APPROVE",
    "gatewayChannel": "3DS",
    "providerChannel": "Cybersource",
    "expiryMonth": 4,
    "expiryYear": 24,
    "fraudLabId": "20230701-KRNGPC",
    "fraudCheckResponse": null
  },
  "subCode": "0",
  "errors": null
}
"""

let jsonFailureJson = """
{
  "message": "Success",
  "code": 200,
  "data": {
    "id": "5eec94d5f6c54a1585c66669ebdaa551",
    "mobileNumber": "233554021947",
    "cardName": "Kweku Ayepah",
    "cardNumber": "463484XXXXXX7997",
    "createdAt": "2023-07-01T05:09:26.195281Z",
    "status": "REJECT",
    "gatewayChannel": "3DS",
    "providerChannel": "Cybersource",
    "expiryMonth": 4,
    "expiryYear": 24,
    "fraudLabId": "20230701-KRNGPC",
    "fraudCheckResponse": {
      "cardType": "Credit",
      "cardSubtype": "Platinum",
      "cardIssuingBank": "Barclays Bank Of Ghana, Ltd.",
      "cardIssuingCountry": "GH",
      "fraudlabsproScore": 96,
      "fraudlabsproDistribution": "100",
      "fraudlabsproStatus": "REVIEW",
      "fraudlabsproId": "20230701-KRNGPC",
      "fraudlabsproRules": "Fraud Score GREATER THAN 80"
    }
  },
  "subCode": "0",
  "errors": null
}
"""

    let feesEndPointMock: String = """
    {
        "message": "Successfully retrieved fees",
        "code": 200,
        "data": [
            {
                "name": "Fee",
                "amount": 0.10
            },
            {
                "name": "Elevy",
                "amount": 0.10
            }

        ],
        "subCode": 1,
        "errors": null
    }
"""
    
    let mockSetupPayerAuthErrorResponse: ApiResponse<Setup3dsResponse?> = ApiResponse(code: 400, message: "failed to setup", data: nil, errors: [ErrorStruct(field: "nil", errorMessage: "nil")])
    
    let successFulSetupPayerAuthComplet: ApiResponse<Setup3dsResponse?> = ApiResponse(code: 200, message: "setup complete successfully", data: Setup3dsResponse(id:" 1122", status: "passed", accessToken: "1133", referenceId: "123qaa", deviceDataCollectionUrl: "www.google.com", clientReference: "11324", transactionId: "110"), errors: [])
    
    let mockmomoErrorResponse: ApiResponse<MomoResponse?> = ApiResponse(code: 400, message: "failed to setup", data: nil, errors: [ErrorStruct(field: "nil", errorMessage: "nil")])
    
    let successMomoMock: ApiResponse<MomoResponse?> = ApiResponse(code: 200, message: "setup complete successfully", data: MomoResponse(transactionId: "00907", charges: 0.1, amount: 1, amountAfterCharges: 1.2, amountCharged: 1.1, deliveryFee: 0.1, description: "implies", clientReference: "111666"), errors: [])
    
    let failureTransactionStatusCheck: ApiResponse<TransactionStatusResponse?> = ApiResponse(code: 400, message: "cannot find transaction status", data: nil, errors: [])
    
    let successfulTransactionStatusCheck: ApiResponse<TransactionStatusResponse?> = ApiResponse(code: 200, message: "This is a success response", data: TransactionStatusResponse(invoiceStatus: "", transactionStatus: "success"), errors: [])
    
    let pendingTransactionStatusCheck: ApiResponse<TransactionStatusResponse?> = ApiResponse(code: 200, message: "This is a success response", data: TransactionStatusResponse(invoiceStatus: "", transactionStatus: "pending"), errors: [])
    
    let failedtransactionStatusCheck: ApiResponse<TransactionStatusResponse?> = ApiResponse(code: 200, message: "This is a success response", data: TransactionStatusResponse(invoiceStatus: "", transactionStatus: "failed"), errors: [])
    
    let failedEnrollmentResponse: ApiResponse<Enroll3dsResponse?> = ApiResponse(code: 400, message: "failed", data: nil, errors: [])
    
    let successEnrollmentResponse: ApiResponse<Enroll3dsResponse?> = ApiResponse(code: 200, message: "success", data: Enroll3dsResponse(transactionId: "", description: "", clientReference: "", amount: 1.2, charges: 0.1, customData: "", jwt: ""), errors: [])
    
   lazy var encodedData: Data? =  jsonString.data(using: .utf8)
   lazy var encodedApproveData: Data? = jsonStringApprove.data(using: .utf8)
   lazy var encodedFailureData: Data? = jsonFailureJson.data(using: .utf8)
   lazy var encodedElevyString: Data? = feesEndPointMock.data(using: .utf8)
    
}
