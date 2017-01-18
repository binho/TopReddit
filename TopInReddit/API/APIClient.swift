//
//  APIClient.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import Foundation

// Global typealias
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

class APIClient: NSObject {

    typealias APICallback = ((AnyObject?, NSError?) -> ())
    
    func callEndpoint(_ endpoint: String, callback: @escaping APICallback) {
        guard let url = URL(string: endpoint) else {
            print("[APIClient] Error: Cannot create URL from provided endpoint")
            callback(nil, nil)
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let urlRequest = URLRequest(url: url)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            // Make sure we don't have an error in the request
            guard error == nil else {
                print(error!)
                callback(nil, error as NSError?)
                return
            }
            
            // Make sure we received something in response
            guard let responseData = data else {
                print("[APIClient] Error: Did not receive data")
                callback(nil, error as NSError?)
                return
            }
            
            do {
                // Try to parse the received JSON data
                guard let jsonReponse = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as Any? else {
                    print("[APIClient] Error trying to convert data to JSON")
                    return
                }
                
                callback(jsonReponse as AnyObject?, nil)
            } catch  {
                print("[APIClient] Failed to serialize data to JSON")
                
                callback(nil, error as NSError?)
                return
            }
        }
        
        task.resume()
    }
    
}
