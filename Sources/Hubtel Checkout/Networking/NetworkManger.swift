//
//  File.swift
//  
//
//  Created by Mark Amoah on 5/3/23.
//



import UIKit

enum MyError: Error{
    case someThingHappened
    case validationErrors
    var message: String{
        switch self{
        case .someThingHappened:
            return Strings.somethingWentWrong
        case .validationErrors:
            return Strings.ValidationErrors
        }
    }
}

class NetworkManager{
    
    static let baseUrl = "https://merchantcard-proxy.hubtel.com"
    static let analyticsBaseUrl = "https://merchant-analytics-api"
    static let promptBase = "https://checkout.hubtel.com"
    
    static func makeRequest<T: Codable>(endpoint: URL, httpMethod: HTTPMethod = .POST, apiKey: String, body: T?) -> URLRequest?{
        
        let httpHeaders = ["Content-type": "application/json",
                           "Authorization": "Basic \(apiKey)",
                           "Accept":"application/json",
                           "Cache-Control":"no-cache"]
        var request = URLRequest(url: endpoint)
        request.allHTTPHeaderFields = httpHeaders
        if let body = body{
            let encoder = JSONEncoder()
            let encodedBody =  try? encoder.encode(body)
           

            print(String(data: encodedBody!, encoding: .utf8))
            request.httpBody = encodedBody
        }
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    static func decode<T: Codable>(data: Data, decodingType: T.Type)->T?{
        let decoder = JSONDecoder()
        do{
            print(String(data: data, encoding: .utf8))
            let responseData = try decoder.decode(decodingType.self, from: data)
            return responseData
        }catch(let error){
            print(error)
            return nil
        }
    }
    
    static func makeRequest(endpoint: URL, httpMethod: HTTPMethod = .GET, apiKey: String) -> URLRequest?{
        
        let httpHeaders = ["Content-type": "application/json",
                           "Authorization": "Basic \(apiKey)",
                           "Accept":"application/json",
                           "Cache-Control":"no-cache"]
        var request = URLRequest(url: endpoint)
        request.allHTTPHeaderFields = httpHeaders
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    
    
    enum EndPoints{
        case setupPayerAuth(id: String)
        case enrollPayerAuth(salesId: String, transactionId: String)
        case mobileMoney(salesId: String)
        case checkFees(salesId: String)
        case checkStatus(salesID: String, transactionId: String)
        case paymentChannels(salesID: String)
        case directDebit(merchantId: String)
        case feeCalculate(merchantId: String, channelPassed: String, amount:Double)
        case checkStatusNew(merchantId: String, clientReference: String)
        case getFeesNew(merchantId: String, channel: String, amount: Double)
        case preapprovalConfirm(merchantId: String)
        case otpVerify(merchantId:String)
        case getCustomerWallets(merchantId: String, phoneNumber: String)
        case newPaymentChannelsEndPoint(merchantId: String)
        case checkUserVerified(salesId: String, mobileNumber: String)
        case confirmGhanaCard(salesId: String)
        case takeGhanaCardDetails(salesId: String, mobileNumber: String, idNumber: String)
        case addMobileMoneyWallet(salesId: String)
        case checkStatusPreApproval(salesID: String, transactionId: String)

        
        var stringValue: String{
            
            switch self{
            case let .setupPayerAuth(salesId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/cardnotpresent/setup-payerauth"
            case let .enrollPayerAuth(salesId, transactionId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/cardnotpresent/enroll-payerauth/\(transactionId)"
            case let .mobileMoney(salesId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/unifiedcheckout/receive/mobilemoney/prompt"
            case let .checkFees(salesId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/fees"
            case let .checkStatus(salesId, transactionId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/statuscheck/\(transactionId)"
            case let .paymentChannels(salesID):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesID)/paymentChannels"
                
            case let .directDebit(merchantId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedcheckout/receive/mobilemoney/directdebit"
            case let .feeCalculate(merchantId, channelPassed, amount):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedCheckout/feecalculation?ChannelPassed=\(channelPassed)&Amount=\(amount)"
            case let .checkStatusNew(merchantId, clientReference):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedcheckout/statuscheck/?clientReference=\(clientReference)"
            case let .getFeesNew(merchantId, channel, amount):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedcheckout/feecalculation?channel=\(channel)&Amount=\(amount)"
            case let .preapprovalConfirm(merchantId):
                return "https://checkout.hubtel.com/api/v1/merchant/\(merchantId)/unifiedcheckout/preapprovalconfirm"
            case let .otpVerify(merchantId):
                return "https://checkout.hubtel.com/api/v1/merchant/\(merchantId)/unifiedcheckout/verifyotp"
            case let .getCustomerWallets(merchantId, phoneNumber):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedcheckout/wallets/\(phoneNumber)"
            case let .newPaymentChannelsEndPoint(merchantId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(merchantId)/unifiedcheckout/checkoutchannels"
            case let .checkUserVerified(salesId, mobileNumber):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/ghanacardkyc/ghanacard-details/\(mobileNumber)"
            case let .confirmGhanaCard(salesId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/ghanacardkyc/confirm-ghana-card"
            case let .takeGhanaCardDetails(salesId, mobileNumber, idNumber):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/ghanacardkyc/addghanacard?PhoneNumber=\(mobileNumber)&CardID=\(idNumber)"
            case let .addMobileMoneyWallet(salesId):
                return "\(NetworkManager.promptBase)/api/v1/merchant/\(salesId)/unifiedcheckout/addwallet"
            case let .checkStatusPreApproval(salesID, transactionId):
                return "https://checkout.hubtel.com/api/v1/merchant/\(salesID)/unifiedcheckout/preapprovalconfirm/statuscheck/\(transactionId)"
            }
        }
        
        var url: URL?{
            URL(string: stringValue)
        }
        
    }
    
    
    
    //refactored method to make payerAuthRequest
    static func makeSetupPayerAuthRequest(requestBody: SetupPayerAuthRequest, salesId: String, apiKey: String,  completion: @escaping(Data?, MyError?)->()){
        
        
        guard let endpoint = EndPoints.setupPayerAuth(id: salesId).url else {
            completion(nil, .someThingHappened)
            return
        }
        
        print(endpoint)
        guard let request = makeRequest(endpoint: endpoint, httpMethod: .POST, apiKey: apiKey, body: requestBody) else {
            completion(nil, .someThingHappened)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                completion(nil, .someThingHappened)
                return
            }
            
            DispatchQueue.main.async {
                completion(data, nil)
            }
            
        }.resume()
    }
    
    
    
    //--------------Endpoint to make Get Enrollment Request----------------------------------------------------------------------------------------
    //refactored endpoint to make enrollment request
    static func makeEnrollmentPayerAuth(salesId: String, transactionId: String, authKey: String, completion: @escaping(Data?, MyError?)->()){
        guard let endpoint = EndPoints.enrollPayerAuth(salesId: salesId, transactionId: transactionId).url else {
            completion(nil, .someThingHappened)
            return
        }
        
        print(endpoint)
        
        guard let request = makeRequest(endpoint: endpoint, httpMethod: .GET, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                completion(nil, .someThingHappened)
                return
            }
            guard let data = data else {
                completion(nil, .someThingHappened)
                return
            }
            completion(data, nil)
        }.resume()
        
    }
    
    
    //---------------------EndPoint to make mobile money request---------------------------------------------------------------------------------
    
    //refactored endpoint to make mobile money request
    static func makeMobileMoneyPaymentsRequest(salesID: String, authKey: String, requestBody: MobileMoneyPaymentRequest, completion: @escaping(Data?, MyError?)->()){
        
        
        guard let endPoint  = EndPoints.mobileMoney(salesId: salesID).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey, body: requestBody) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                completion(nil, .someThingHappened)
                return
            }
            guard let data = data else{
                completion(nil, .someThingHappened)
                return
            }
            completion(data, nil)
        }.resume()
        
        
        
    }
    
    
    // ------------------------------ endpoint to get fees -----------------------------------------------------------------------------------------------------------------------------
    
    static func getFeesApi(salesId: String, authKey: String, requestBody: GetFeesBody, completion: @escaping (Data?, MyError?)->())->URLSessionDataTask?{
        guard let endpoint = EndPoints.checkFees(salesId: salesId).url else{
            return nil
        }
        guard let request = makeRequest(endpoint: endpoint, apiKey: authKey, body: requestBody) else{
            completion(nil, .someThingHappened)
            return nil
        }
        
        let task =  URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                completion(nil, .someThingHappened)
                return
            }
            
            guard let data = data else{
                completion(nil, .someThingHappened)
                return
            }
            completion(data, nil)
        }
        task.resume()
        return task
    }
    
    //------------------------------------------------ Refactored Endpoint to Check Payment Status ---------------------------------------------------------------------------------
    static func checkPaymentsStatus(salesID: String, authKey: String, transactionID:String, completion: @escaping (Data?, MyError?)->()){
        guard let endPoint = EndPoints.checkStatus(salesID: salesID, transactionId: transactionID).url else{
            completion(nil, .someThingHappened)
            return
            
        }
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            dump(response, name: "Response from status check api")
            
            print(String(data: data!, encoding: .utf8))
            
            guard error == nil else{
                completion(nil, .someThingHappened)
                return
            }
            guard let data = data else{
                completion(nil, .someThingHappened)
                return
            }
            
            completion(data, nil)
        }.resume()
        
    }
    
    static  func checkPaymentChannels(salesID: String,authKey: String, completion: @escaping (Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.newPaymentChannelsEndPoint(merchantId: salesID).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
        
    }
    
    //----------EndPoint to make Direct Debit----------------------------------------------------------
    static func makeDirectDebitCall(merchantId: String, authKey:String, body: MakeDirectDebitCallBody, completion: @escaping (Data?, MyError?)->()){
        
        guard let endpoint = EndPoints.directDebit(merchantId: merchantId).url else { return }
        
        print(endpoint)
        
        guard let request = makeRequest(endpoint: endpoint, httpMethod: .POST, apiKey: authKey, body: body) else { return }
        
        dump(request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data else {
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
                
            }
        }.resume()
        
    }
    
    //----------EndPoint to make Otp Request Call ----------------------------------------------------------
    static func makeVerifyOtpRequest(merchantId: String, authKey:String, body: OtpBodyRequest, completion: @escaping (Data?, MyError?)->()){
        
        guard let endpoint = EndPoints.otpVerify(merchantId: merchantId).url else { return }
        
        guard let request = makeRequest(endpoint: endpoint, httpMethod: .POST, apiKey: authKey, body: body) else { return }
        
        dump(request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data else {
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
                
            }
        }.resume()
        
    }
    
    
    
    //----------EndPoint to calculate fees-------------------------------------------------------------
    static func makeCallToFeesEndPoint(merchantId: String, authKey: String, channelPassed: String, amount: Double, completion: @escaping(Data?, MyError?)->()){
        
        guard let endpoint = EndPoints.feeCalculate(merchantId: merchantId, channelPassed: channelPassed, amount: amount).url else {return}
        
        guard let request = makeRequest(endpoint: endpoint, apiKey: authKey) else {return}
        
        URLSession.shared.dataTask(with: request){data, response, error in
            guard error == nil else {
                completion(nil, .someThingHappened)
                return
            }
            
            guard let data = data else {
                completion(nil, .someThingHappened)
                return
            }
            
            completion(data, nil)
            
        }.resume()
                
    
        
    }
    
    
    //---------endpoint to get transactionStatus----------------------------------------
    static  func checkStatusOfTransaction(salesID: String,authKey: String, clientRefrence: String, completion: @escaping (Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.checkStatusNew(merchantId: salesID, clientReference: clientRefrence).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print(response)
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
        
    }
    
    //------------------endPoint to get transactionStatus----------------------------------
    
    static  func checkStatusofTransactionPreApproval(salesID: String,authKey: String, clientRefrence: String, completion: @escaping (Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.checkStatusPreApproval(salesID: salesID, transactionId: clientRefrence).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print(response)
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
        
    }
    
    //------------endpoint to get Fees------------------------------------------------------------
    static func getFeesNew(salesId: String, authKey: String, amount: Double, channel: String, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.getFeesNew(merchantId: salesId, channel: channel, amount: amount).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    //------------endPoint for preapproval---------------------------------------------------------------------
  
    static func preApprovalConfirm(merchantId: String, authKey: String, body: MobileMoneyPaymentRequest, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.preapprovalConfirm(merchantId: merchantId).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        dump(endPoint)
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey, body: body) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    //-------Endpoint to get all wallets------------------------------------
    
    
    static func getWallets(salesId: String, authKey: String,mobileNumber: String, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.getCustomerWallets(merchantId: salesId, phoneNumber: mobileNumber).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        print(endPoint)
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print(response)
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    //-------Endpoint to get check if user is verified------------------------------------
    
    
    static func getVerificationDetails(salesId: String, authKey: String,mobileNumber: String, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.checkUserVerified(salesId: salesId, mobileNumber: mobileNumber).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        print(endPoint)
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print(response)
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    //-----------endpoint to confirm UserDetails------------------------------
    static func ConfirmGhanaCardDetails(salesId: String, authKey: String,mobileNumber: String, body:CustomerVerificationBody?, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.confirmGhanaCard(salesId: salesId).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey, body: body) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("response here: \(response)")
            
            print(error)
            
            DispatchQueue.main.async {
               
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    
    //-----------Endpoint to update Ghana Card details------------------------------------------------
    static func inputGhanaCardDetails(salesId: String, authKey: String,mobileNumber: String,idNumber: String, completion: @escaping(Data?, MyError?)->()){
        
        guard let endPoint = EndPoints.takeGhanaCardDetails(salesId: salesId, mobileNumber: mobileNumber, idNumber: idNumber).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        dump(endPoint)
        
        
        
        guard let request = makeRequest(endpoint: endPoint, apiKey: authKey) else{
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
               
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                completion(data, nil)
            }
            
        }.resume()
        
    }
    
    //------------EndPoint to add wallets to account ---------------------------------
    
    static func addMobileWalletToAccount(salesId: String, authKey: String, requestBody: AddMobileWalletBody?, completion: @escaping(Data?, MyError?)->()){
        guard let endpoint = EndPoints.addMobileMoneyWallet(salesId: salesId).url else{
            completion(nil, .someThingHappened)
            return
        }
        
        dump(endpoint)
        
        guard let request = makeRequest(endpoint: endpoint, httpMethod: .POST, apiKey: authKey, body: requestBody) else {
            completion(nil, .someThingHappened)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
               
                guard error == nil else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                guard let data = data  else{
                    completion(nil, .someThingHappened)
                    return
                }
                
                dump(String(data: data, encoding: .utf8))
                completion(data, nil)
            }
            
        }.resume()
        
    }
}
    
    



