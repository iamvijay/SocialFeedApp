//
//  RequestManager.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation


class RequestManager {
    static let send = RequestManager()
    
    func startRequest <T: Response>(request : URLRequest, type : T.Type, completion: @escaping APIManager.CompletionHandler<T>) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network-related error
            if let error = error {
                print("API request",error)
                completion(.failure(error))
                return
            }
            
            // Validate HTTP response and status code
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let httpError = NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
                print("API request",httpError)
                completion(.failure(httpError))
                return
            }
            
            // Proceed to decode the response
             let decoder = JSONDecoder()
             do {
                 let apiResponseObject = try decoder.decode(T.self, from: data ?? Data())
                 completion(.success(apiResponseObject))
             } catch {
                 print("Error decoding JSON: \(error)")
                 completion(.failure(error))
             }
        }
        task.resume()
    }
}
