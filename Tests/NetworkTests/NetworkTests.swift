import XCTest
@testable import Network

final class NetworkTests: XCTestCase {
    
    struct ProductionEnvironment: EnvironmentProtocol {
                
        let host: String
        let commonHeaders: [String : String]
        var commonQueries: [URLQueryItem]?
    }
    
    struct StagingEnvironment: EnvironmentProtocol {
        
        let scheme: String
        let host: String
        let commonHeaders: [String : String]
        var commonQueries: [URLQueryItem]?
    }
    
    struct Response: Decodable {
        
        var count: [Int]
    }
    
    // MARK: - Endpoint Test
    
    func testEndpointWithPlainPath() {
        let path = "/path/to/resource"
        let endpoint = Endpoint(path: path)
        
        XCTAssertNotNil(endpoint.path)
        XCTAssertNil(endpoint.params)
        
        XCTAssertTrue(endpoint.path == path)
    }
    
    func testEndpointWithQuery() {
        let path = "/path/to/resource"
        let params = ["name" : "network"]
        let endpoint = Endpoint(path: path, params: params)
        
        XCTAssertNotNil(endpoint.path)
        XCTAssertNotNil(endpoint.params)
        
        XCTAssertTrue(endpoint.params?.count == 1)
        XCTAssertTrue(endpoint.queryItems()?.count == 1)
        
        let queryItem = endpoint.queryItems()?.first
        XCTAssertNotNil(queryItem)
        
        XCTAssertTrue([queryItem?.name : queryItem?.value] == params)
    }
    
    // MARK: - Environment Test
    
    func testEnvironment() {
        let host = "network.com"
        let commonHeaders = ["token" : "1234567"]
        let commonQueries = [URLQueryItem(name: "apiKey", value: "123456")]
        
        let environment = ProductionEnvironment(host: host, commonHeaders: commonHeaders, commonQueries: commonQueries)
        XCTAssertTrue(environment.host == host)
        XCTAssertTrue(environment.commonHeaders == commonHeaders)
        XCTAssertTrue(environment.commonQueries == commonQueries)
        XCTAssertTrue(environment.scheme == "https")
    }
    
    func testHttpEnvironment() {
        let http = "http"
        let host = "network.com"
        let commonHeaders = ["token" : "1234567"]
        
        let environment = StagingEnvironment(scheme: http, host: host, commonHeaders: commonHeaders)
        XCTAssertTrue(environment.host == host)
        XCTAssertTrue(environment.commonHeaders == commonHeaders)
        XCTAssertTrue(environment.scheme == http)
    }
    
    // MARK: - StatusCode Test
    
    func testStatusCode() {
        XCTAssertTrue(StatusCode(rawValue: 100).testStatus() == .informationalResponse)
        XCTAssertTrue(StatusCode(rawValue: 199).testStatus() == .informationalResponse)
        
        XCTAssertNil(StatusCode(rawValue: 200).testStatus())
        XCTAssertNil(StatusCode(rawValue: 299).testStatus())
        
        XCTAssertTrue(StatusCode(rawValue: 300).testStatus() == .redirection)
        XCTAssertTrue(StatusCode(rawValue: 399).testStatus() == .redirection)
        
        XCTAssertTrue(StatusCode(rawValue: 400).testStatus() == .clientError)
        XCTAssertTrue(StatusCode(rawValue: 499).testStatus() == .clientError)
        
        XCTAssertTrue(StatusCode(rawValue: 500).testStatus() == .serverError)
        XCTAssertTrue(StatusCode(rawValue: 599).testStatus() == .serverError)
    }
    
    // MARK: - Request Test
    
    func testRequest() {
        let host = "network.com"
        let commonHeaders = ["token" : "1234567"]
        let commonQueries = [URLQueryItem(name: "apiKey", value: "123456")]
        let environment = ProductionEnvironment(host: host, commonHeaders: commonHeaders, commonQueries: commonQueries)
        
        let path = "/path/to/resource"
        let params = ["name" : "network"]
        let customHeaders = ["additionToken" : "1234567"]
        
        // request with .get method
        do {
            let request: Request<Response>! = .getCountList(params, path: path, customHeaders: customHeaders)
            let urlRequest = request.urlRequest(from: environment, encoding: .json)
            
            XCTAssertNotNil(request)
            XCTAssertNotNil(urlRequest)
            XCTAssertTrue(urlRequest?.httpMethod == "GET")
            XCTAssertTrue(urlRequest?.allHTTPHeaderFields == commonHeaders.merging(customHeaders) { $1 })
            XCTAssertTrue(urlRequest?.url?.host == host)
            XCTAssertTrue(urlRequest?.url?.path == path)
            
            var urlComponent = URLComponents()
            urlComponent.queryItems = [URLQueryItem(name: "name", value: "network")] + (environment.commonQueries ?? [])
            
            XCTAssertTrue(urlRequest?.url?.query == urlComponent.url?.query)
            XCTAssertNil(urlRequest?.httpBody)
        }
        
        // bad request with incorrect path for .get method
        do {
            let request: Request<Response>! = .getCountList(params, path: "path/to/resource")
            let urlRequest = request.urlRequest(from: environment, encoding: .json)
            
            XCTAssertNotNil(request)
            XCTAssertNil(urlRequest)
        }
        
        // bad request with .get but fulfill bodyParams
        do {
            let endpoint = Endpoint(path: path)
            let request: Request<Response>? = Request(endpoint: endpoint, method: .get, bodyParams: params, customHeaders: customHeaders)
            
            XCTAssertNil(request)
        }
        
        // request with .post method
        do {
            struct RequestParams: Codable {
                
                let name: String
            }
            
            let request: Request<Response>? = .postCountList(params, bodyParams: RequestParams(name: "network"), path: path, customHeaders: customHeaders)
            let urlRequest = request?.urlRequest(from: environment, encoding: .json)

            XCTAssertNotNil(request)
            XCTAssertNotNil(urlRequest)
            XCTAssertTrue(urlRequest?.httpMethod == "POST")
            XCTAssertTrue(urlRequest?.allHTTPHeaderFields == (commonHeaders.merging(customHeaders) { $1 }).merging(["Content-Type" : "application/json"]) { $1 })
            XCTAssertTrue(urlRequest?.url?.host == host)
            XCTAssertTrue(urlRequest?.url?.path == path)
            
            var urlComponent = URLComponents()
            urlComponent.queryItems = [URLQueryItem(name: "name", value: "network")] + (environment.commonQueries ?? [])
            
            XCTAssertTrue(urlRequest?.url?.query == urlComponent.url?.query)
            XCTAssertNotNil(urlRequest?.httpBody)
            
            let decoder = JSONDecoder()
            XCTAssertNoThrow(XCTAssertNotNil(try? decoder.decode(RequestParams.self, from: (urlRequest?.httpBody)!)))
        }
    }
}

private extension Request where ResponseType == NetworkTests.Response {
    
    static func getCountList(_ params: [String : String], path: String, customHeaders: [String : String]? = nil) -> Self? {
        let endpoint = Endpoint(path: path, params: params)
        return Request(endpoint: endpoint, method: .get, customHeaders: customHeaders)
    }
    
    static func postCountList<T: Encodable>(_ queryParams: [String : String]?, bodyParams: T, path: String, customHeaders: [String : String]? = nil) -> Self? {
        let endpoint = Endpoint(path: path, params: queryParams)
        return Request(endpoint: endpoint, method: .post, bodyParams: bodyParams, customHeaders: customHeaders)
    }
}
