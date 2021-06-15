//
//  Coding.swift
//  Network
//
//  Created by zhutianren on 2021/6/1.
//

import Foundation

/// Encoding types you can use.
enum Encoding {
    
    case json
}

extension Encodable {
    
    /// Get json data if it possible.
    /// - Returns: Data.
    func jsonData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

/// Decoding types you can use.
enum Decoding<T: Decodable> {
    
    case json
}

extension Decoding {
    
    /// Parsing data to object type you inferred.
    /// - Parameter data: Data.
    /// - Returns: Object if not any failure.
    func parsing(_ data: Data) -> T? {
        switch self {
        case .json:
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }
}
