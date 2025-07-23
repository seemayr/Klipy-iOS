import Foundation

/// Main entry point for the Klipy SDK
public actor Klipy {
  // MARK: - Properties
  static private var apiKey: String?
  static private var customerId: String?
  
  static private let baseURL: String = "https://api.klipy.co/api/v1/"
  static private let apiClient: APIClient = APIClient()
  
  static var apiURL: URL? {
    guard let apiKey else { return nil }
    return URL(string: "\(baseURL)\(apiKey)")
  }
  
  // MARK: - Initialization
  
  private init() { }
  
  // MARK: - Configuration
  
  /// Setup Klipy with your API key and optional customer ID
  /// - Parameters:
  ///   - apiKey: Your Klipy API key
  ///   - customerId: customer ID for tracking
  public static func setup(apiKey: String, customerId: String? = nil) {
    Klipy.apiKey = apiKey
    Klipy.customerId = customerId
  }
  
  /// Update the customer ID
  /// - Parameter customerId: New customer ID or nil to clear
  public static func updateCustomerId(to customerId: String?) {
    Klipy.customerId = customerId
  }
}

// MARK: - Convenience Extensions

public extension Klipy {
  // MARK: - Static Access to Services
  
  /// Access GIF service methods directly
  static var gifs: GifServiceUseCase {
    get throws {
      guard let apiURL, let customerId else {
        throw KlipyError.notConfigured
      }
      
      return GifServiceUseCase(client: apiClient, baseURL: apiURL, customerId: customerId)
    }
  }
  
  /// Access Clips service methods directly
  static var clips: ClipsServiceUseCase {
    get throws {
      guard let apiURL, let customerId else {
        throw KlipyError.notConfigured
      }
      
      return ClipsServiceUseCase(client: apiClient, baseURL: apiURL, customerId: customerId)
    }
  }
  
  /// Access Stickers service methods directly
  static var stickers: StickersServiceUseCase {
    get throws {
      guard let apiURL, let customerId else {
        throw KlipyError.notConfigured
      }
      
      return StickersServiceUseCase(client: apiClient, baseURL: apiURL, customerId: customerId)
    }
  }
  
  static func createMediaService(for type: MediaType) throws -> MediaService {
    switch type {
    case .gifs: return .gif(try gifs)
    case .clips: return .clip(try clips)
    case .stickers: return .sticker(try stickers)
    case .ad: return .none
    }
  }
}

// MARK: - Errors

public enum KlipyError: Error, LocalizedError {
  case notConfigured
  
  public var errorDescription: String? {
    switch self {
    case .notConfigured:
      return "Klipy not configured. Call Klipy.setup(apiKey:customerId:) first."
    }
  }
}
