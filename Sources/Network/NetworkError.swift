//
//  NetworkError.swift
//  Network
//
//  Created by zhutianren on 2021/5/28.
//

import Foundation

/// Errors in Network.
enum NetworkError: Error, Equatable {
    
    case urlRequestCreateError
    case genericError(errorMessage: String)
    case httpUrlResponseError
    case httpDataError
    case httpDataParsingError
    
    case informationalResponse
    case redirection
    case clientError
    case serverError
    case unexpectedError(statusCode: Int)
}
