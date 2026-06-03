import Foundation

private let adIframeQueryName = "ad-iframe"
private let adIframeQueryValue = "1"

public enum APIError: Error {
  case invalidURL
  case noData
  case decodingError(Error)
  case networkError(Error)
  case httpError(statusCode: Int, data: Data?)
  case unknown
}

public protocol APIClientProtocol {
  func request<T: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> T
}

public class APIClient: APIClientProtocol {
  private let session: URLSession
  private let decoder: JSONDecoder
  
  public init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
    self.session = session
    self.decoder = decoder
  }
  
  public func request<T: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> T {
    print("🚀 Starting API request to \(endpoint.method.rawValue) \(endpoint.path)")
    
    let request = try await buildRequest(for: endpoint, baseURL: baseURL)
    
    do {
      print("🌐 Sending request to: \(request.url?.absoluteString ?? "unknown URL")")
      let (data, response) = try await session.data(for: request)
      print("📊 Received response data: \(data.count) bytes")
      
      guard let httpResponse = response as? HTTPURLResponse else {
        print("⚠️ Response is not HTTPURLResponse")
        throw APIError.unknown
      }
      
      print("📡 HTTP Status Code: \(httpResponse.statusCode)")
      
      guard (200...299).contains(httpResponse.statusCode) else {
        print("❌ HTTP Error - Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
          print("❌ Error Response Body: \(responseString)")
        }
        throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
      }
      
      do {
        if let jsonString = String(data: data, encoding: .utf8) {
          print("📄 Raw JSON Response: \(jsonString)")
        }
        
        let decoded = try decoder.decode(T.self, from: data)
        print("✅ Successfully decoded response of type: \(T.self)")
        return decoded
      } catch {
        print("⚠️ Decoding Error: \(error)")
        if let jsonString = String(data: data, encoding: .utf8) {
          print("🔍 Failed to decode JSON: \(jsonString)")
        }
        throw APIError.decodingError(error)
      }
    } catch let error as APIError {
      print("🚨 API Error: \(error)")
      throw error
    } catch {
      print("🌐 Network Error: \(error.localizedDescription)")
      print("🔍 Error Details: \(error)")
      throw APIError.networkError(error)
    }
  }
  
  private func buildRequest(for endpoint: APIEndpoint, baseURL: URL) async throws -> URLRequest {
    print("🔨 Building request for endpoint: \(endpoint.path)")
    print("🏠 Base URL: \(baseURL.absoluteString)")
    
    guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
      print("❌ Failed to create URL components")
      throw APIError.invalidURL
    }
    
    var parameters = endpoint.parameters ?? [:]
    if !parameters.isEmpty {
      print("📦 Original parameters: \(parameters)")
    }
    
    if endpoint.encoding == .url {
      parameters = await parameters.withAdParameters()
      print("📦 Parameters with ads: \(parameters)")
      components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
      print("🔗 Query items set: \(components.queryItems?.count ?? 0) items")
    }

    components.appendQueryItemIfNeeded(name: adIframeQueryName, value: adIframeQueryValue)
    
    guard let url = components.url else {
      print("❌ Failed to construct URL from components")
      throw APIError.invalidURL
    }
    
    print("🔗 Final URL: \(url.absoluteString)")
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    print("📋 HTTP Method: \(endpoint.method.rawValue)")
    
    let userAgent = await UserAgentManager.shared.userAgent
    if !userAgent.isEmpty {
      print("👀 USER AGENT: \(userAgent)")
      request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    } else {
      print("👀 USER AGENT EMPTY")
    }
    
    if endpoint.encoding == .json, let parameters = endpoint.parameters {
      let parametersWithAds = await parameters.withAdParameters()
      print("📦 JSON Body parameters: \(parametersWithAds)")
      
      request.httpBody = try JSONSerialization.data(withJSONObject: parametersWithAds)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      
      if let bodyData = request.httpBody,
         let bodyString = String(data: bodyData, encoding: .utf8) {
        print("📝 Request Body: \(bodyString)")
      }
    }
    
    endpoint.headers?.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
      print("📋 Header set: \(key) = \(value)")
    }
    
    if let headers = request.allHTTPHeaderFields {
      print("📋 All request headers: \(headers)")
    }
    
    return request
  }
}

private extension URLComponents {
  mutating func appendQueryItemIfNeeded(name: String, value: String) {
    var items = self.queryItems ?? []
    guard !items.contains(where: { $0.name == name }) else {
      return
    }

    items.append(URLQueryItem(name: name, value: value))
    self.queryItems = items
  }
}
