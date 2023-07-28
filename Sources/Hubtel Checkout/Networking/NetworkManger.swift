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
            request.httpBody = encodedBody
        }
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    static func decode<T: Codable>(data: Data, decodingType: T.Type)->T?{
        let decoder = JSONDecoder()
        do{
            let responseData = try decoder.decode(decodingType.self, from: data)
            return responseData
        }catch{
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
        
        var stringValue: String{
            
            switch self{
            case let .setupPayerAuth(salesId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/merchantcardnotpresent/setup-payerauth"
            case let .enrollPayerAuth(salesId, transactionId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/merchantcardnotpresent/enroll-payerauth/\(transactionId)"
            case let .mobileMoney(salesId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/receive/mobilemoney"
            case let .checkFees(salesId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/fees"
            case let .checkStatus(salesId, transactionId):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesId)/statuscheck/\(transactionId)"
            case let .paymentChannels(salesID):
                return "\(NetworkManager.baseUrl)/v2/merchantaccount/merchants/\(salesID)/paymentChannels"
            
                
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
        
        guard let endPoint = EndPoints.paymentChannels(salesID: salesID).url else{
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
    
}


