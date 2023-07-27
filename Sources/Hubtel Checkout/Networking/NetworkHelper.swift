//
//  File.swift
//  
//
//  Created by Mark Amoah on 6/25/23.
//

import Foundation



enum HTTPMethod: String{
    case POST
    case GET
    case PATCH
    case PUT
}

protocol Networking{
    var headers: [String: String] {get}
}

extension Networking{
    var headers: [String: String]{
        return ["Content-type": "application/json",
                "Authorization": "Basic apiKey",
                "Cache-Control":"no-cache"]
    }
}


protocol Request{
    associatedtype Model
    var url: URL { get }
    var method: HTTPMethod { get }
    func decode(data: Data)
}

extension Request{
    func decode(data: Data){
     
    }
}

class Networker{
    func fetch(request: any Request, completion: @escaping(Result<Data, Error>)->())->URLSessionDataTask{
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        return URLSession.shared.dataTask(with: urlRequest)
    }
    
    
}



