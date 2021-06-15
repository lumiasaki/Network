# Network

A really simple and straightforward network framework to fetch resources from remote in a safe way. Purpose on showing my approach of fetching resources from remote.

## How to use

With the help of  `Generic Type` in Swift, we can reduce many typos to avoid some stupid bugs, so the first target of this framework focus on supporting `Generic Type`.

Network uses `Phantom` type to let developer to create network request declaration easier.

```swift

private extension Request where ResponseType == NetworkTests.Response {
    
    static func list() -> Self {
        return Request(endpoint: Endpoint(path: "/live"), method: .get)
    }        
}

```
Then the request with a specific endpoint has been declared, you can use it as blow:

```swift

URLSession.shared.fetch(Request.list()) { result in
    // handle the result of request
    // ... 
}

```

## How to describe a network request with `Endpoint`, `Environment`, etc

### Endpoint

Endpoint is a structure to describe `path` and  `params` in url.

```swift

struct Endpoint {
        
    let path: String
    let params: [String : String?]?
    
    init(path: String, params: [String : String?]? = nil) {
        self.path = path
        self.params = params
    }
}

```

We can define some requests with corresponding `Endpoint`s.

### EnvironmentProtocol

Environment has a higher level of view on networking, it's a protocol so that let developer to define their own network environment.

```swift

protocol EnvironmentProtocol {
    
    var scheme: String { get }
    var host: String { get }
    var commonHeaders: [String : String] { get }
    var commonQueries: [URLQueryItem]? { get }
    var timeout: TimeInterval { get }
}

```

As above, you can create an environment for your remote requests.

```swift

struct MyEnvironment: EnvironmentProtocol {

    var scheme: String = "https"
    var host: String = "mynetwork.com"
    var commonHeaders: [String : String] = Dictionary()
    var commonQueries: [URLQueryItem]? = nil
    var timeout: TimeInterval = 30
}

```

Notice that, `scheme` has default value `https`, `timeout` has default value `30`.

You can assign an instance which conforms to `EnvironmentProtocol` to `URLSession.environment`, once you configure the `URLSession` like this, the network requests will use this environment as default. If you would like to use different environments for every single request, you can pass the `environment` as the second argument when calling `URLSession.shared.fetch(_:,on:)`.

## Encoding and Decoding

Currently this framework supports `json`, you can specify it when creating `Request`.
