//
//  File.swift
//  
//
//  Created by Mark Amoah on 7/17/23.
//

import Foundation


final class AnalyticsManager{
    final let url = "https://merchant-analytics-api.hubtel.com/api/v1/events"
    var customerDetails: [String:String] = [:]
    var pageDetails: [String: String] = [:]
    var actionDetatails: [String: String] = [:]
    
    private init(){}
    static let shared = AnalyticsManager()
    func recordAnalytics(body: EventStoreData){
        
        guard let url = URL(string: self.url) else{
            return
        }
        
        var request = URLRequest(url: url)
        //MARK: - Remember to remove token before you push app to the general repository.
        let headers = [
            "accept": "application/json",
            "Referer": "checkout-sdk-ios",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9tb2JpbGVwaG9uZSI6IjIzMzU0NDg0MzExNyIsImp0aSI6IjMxZTJjYmYxLTVjYTUtNGNhMS1iMGZhLTc2YjA4Mzg1NDhhYiIsIm5iZiI6MTY0MzI0NTU5NSwiZXhwIjoxNjc0NzgxNTk1LCJpc3MiOiJodHRwOi8vaHVidGVsLmNvbSIsImF1ZCI6Imh0dHA6Ly9odWJ0ZWwuY29tIn0.dvXMyveQQeEPkz6O498-aflyfHN9z2iwJsFWsQcMf4A",
            "Content-Type": "application/json"
        ]
        request.allHTTPHeaderFields = headers
        let jsonEncoder = JSONEncoder()
        guard let body = try? jsonEncoder.encode(body) else{
            return
        }
        request.httpBody = body
        request.httpMethod = HTTPMethod.POST.rawValue
        URLSession.shared.dataTask(with: request) { data, response, error in
            
        }.resume()
        
        
        
    }
}
