//
//  Network.swift
//  Network
//
//  Created by zhutianren on 2021/6/1.
//

import Foundation

extension URLSession {
    
    private struct AssociatedKey {
        static var environmentKey: Void?
    }
    
    var environment: EnvironmentProtocol? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.environmentKey) as? EnvironmentProtocol
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.environmentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension URLSession {
    
    /// Fetch data from remote server.
    /// - Parameters:
    ///   - request: Request.
    ///   - environment: Instance of EnvironmentProtocol.
    ///   - encoding: Encoding you are using, default is json.
    ///   - decoding: Decoding you are using, default is json.
    ///   - completion: Callback block.
    func fetch<ResponseType: Decodable>(_ request: Request<ResponseType>, on environment: EnvironmentProtocol? = nil, encoding: Encoding = .json, decoding: Decoding<ResponseType> = .json, completion: @escaping (Result<ResponseType, NetworkError>) -> Void) {
        guard let onUsingEnvironment = environment ?? self.environment else {
            fatalError("must set network environment before use")
        }
        
        guard let urlRequest = request.urlRequest(from: onUsingEnvironment, encoding: encoding) else {
            completion(.failure(.urlRequestCreateError))
            return
        }
        
        let task = dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.httpUrlResponseError))
                return
            }
            if let error = error {
                completion(.failure(.genericError(errorMessage: error.localizedDescription)))
                return
            }
            
            let statusCode = StatusCode(rawValue: response.statusCode)
            if let error = statusCode.testStatus() {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(.httpDataError))
                return
            }
            
            guard let result = decoding.parsing(data) else {
                completion(.failure(.httpDataParsingError))
                return
            }
            
            completion(.success(result))
            return
        }
        
        task.resume()
    }
}
