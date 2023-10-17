//
//  File.swift
//  
//
//  Created by Mark Amoah on 9/19/23.
//

import Foundation

@objc class Wallet: NSObject, Codable{
    let id: Int?
    let clientId: Int?
    let externalId: String?
    let customerId: Int?
    let accountNo: String?
    let accountName: String?
    let providerId: String?
    let provider: String?
   let type: String?
}

