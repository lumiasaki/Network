//
//  EnvironmentProtocol.swift
//  Network
//
//  Created by zhutianren on 2021/5/28.
//

import Foundation

/// Environment for Network.
protocol EnvironmentProtocol {
    
    var scheme: String { get }
    var host: String { get }
    var commonHeaders: [String : String] { get }
    var commonQueries: [URLQueryItem]? { get }
    var timeout: TimeInterval { get }
}

// MARK: - Default Values

extension EnvironmentProtocol {
    
    var scheme: String { "https" }
    var timeout: TimeInterval { 30 }
}
