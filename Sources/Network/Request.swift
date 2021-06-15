//
//  Request.swift
//  Network
//
//  Created by zhutianren on 2021/5/28.
//

import Foundation

/// Request type you are using to request from remote.
struct Request<ResponseType> {
    
    let endpoint: Endpoint
    let method: HTTPMethod
    let bodyParams: Encodable?
    let customHeaders: [String : String]?
    
    init?(endpoint: Endpoint, method: HTTPMethod, bodyParams: Encodable? = nil, customHeaders: [String : String]? = nil) {
        if method == .get, let _ = bodyParams {
            return nil
        }
        
        self.endpoint = endpoint
        self.method = method
        self.bodyParams = bodyParams
        self.customHeaders = customHeaders
    }
}

extension Request {
    
    /// Generate URLRequest instance.
    /// - Parameters:
    ///   - environment: Instance of EnvironmentProtocol.
    ///   - encoding: Encoding you want to use.
    /// - Returns: URLRequest, nil if some errors occurred.
    func urlRequest(from environment: EnvironmentProtocol, encoding: Encoding) -> URLRequest? {
        var component: URLComponents = URLComponents()
        component.scheme = environment.scheme
        component.host = environment.host
        component.path = endpoint.path
        component.queryItems = [(endpoint.queryItems() ?? []), environment.commonQueries ?? []].flatMap { $0 }
                
        guard let url = component.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = environment.commonHeaders.merging(customHeaders ?? [:]) { $1 }
        
        if encoding == .json, (method == .post || method == .put) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyParams?.jsonData()
        }
        
        request.httpMethod = method.rawValue
        request.timeoutInterval = environment.timeout
        
        return request
    }
}
