import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum ParameterEncoding {
    case url
    case json
}

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
    var headers: [String: String]? { get }
}

public extension APIEndpoint {
    var encoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return .url
        default:
            return .json
        }
    }
    
    var headers: [String: String]? {
        nil
    }
}
