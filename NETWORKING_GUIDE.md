# Klipy iOS Networking Guide

This guide explains how the networking layer works in the Klipy iOS package after migrating from Moya to a modern Swift async/await architecture.

## Architecture Overview

The networking layer consists of four main components:

```
┌─────────────────┐
│   Use Cases     │  (Public API)
└────────┬────────┘
         │
┌────────▼────────┐
│   API Client    │  (Network Engine)
└────────┬────────┘
         │
┌────────▼────────┐
│  API Endpoints  │  (Request Definitions)
└─────────────────┘
```

## Core Components

### 1. APIEndpoint Protocol (`Networking/Core/APIEndpoint.swift`)

Defines the structure of any API request:

```swift
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
    var headers: [String: String]? { get }
}
```

### 2. APIClient (`Networking/Core/APIClient.swift`)

The main networking engine that:
- Builds URLRequests from endpoints
- **Automatically adds AdParameters** (async)
- Handles response decoding
- Manages errors

Key method:
```swift
func request<T: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> T
```

### 3. API Definitions (`Networking/API/`)

Concrete endpoint implementations:
- `GifAPI.swift` - GIF-related endpoints
- `ClipsAPI.swift` - Clips endpoints
- `StickersAPI.swift` - Stickers endpoints
- `HealthCheckAPI.swift` - Health check endpoint

### 4. Use Cases (`Infrastructure/UseCases/`)

Public-facing service classes that developers use:
- `GifServiceUseCase`
- `ClipsServiceUseCase`
- `StickersServiceUseCase`
- `HealthCheckServiceUseCase`

## Data Flow Example

Let's trace a request to fetch trending GIFs:

### 1. Client Code
```swift
let gifService = GifServiceUseCase()
let response = try await gifService.fetchTrending(page: 1, perPage: 20)
```

### 2. Use Case Layer
```swift
// GifServiceUseCase.swift
public func fetchTrending(...) async throws -> AnyResponse<GifItem> {
    try await client.request(
        GifAPI.trending(page: page, perPage: perPage, customerId: customerId, locale: locale),
        baseURL: baseURL
    )
}
```

### 3. API Definition
```swift
// GifAPI.swift
enum GifAPI: APIEndpoint {
    case trending(page: Int, perPage: Int, customerId: String, locale: String)
    
    var path: String {
        switch self {
        case .trending: return "gifs/trending"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .trending(let page, let perPage, let customerId, let locale):
            return [
                "page": page,
                "per_page": perPage,
                "customer_id": customerId,
                "locale": locale
            ]
        }
    }
}
```

### 4. API Client Processing
```swift
// APIClient.swift
func request<T: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> T {
    // 1. Build request
    let request = try await buildRequest(for: endpoint, baseURL: baseURL)
    
    // 2. In buildRequest: AdParameters are added automatically
    parameters = await parameters.withAdParameters()
    
    // 3. Execute request
    let (data, response) = try await session.data(for: request)
    
    // 4. Decode response
    return try decoder.decode(T.self, from: data)
}
```

## Key Features

### Automatic AdParameters Injection

The `APIClient` automatically adds device/advertising parameters to requests:

```swift
// This happens automatically in APIClient.buildRequest()
parameters = await parameters.withAdParameters()
```

This solves the MainActor isolation issue because:
- AdParameters access UI properties (UIScreen, UIDevice) on MainActor
- The async call properly switches to MainActor context
- No manual intervention needed

### Default Configuration

All use cases use shared configuration by default:

```swift
// APIConfiguration.swift
public struct APIConfiguration {
    public static let apiKey = "your-api-key"
    public static let baseURL = URL(string: "https://api.klipy.co/api/v1/\(apiKey)")!
    public static let sharedClient = APIClient()
}
```

### Error Handling

The system uses a simple error enum:

```swift
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, data: Data?)
    case unknown
}
```

## Usage Examples

### Fetching Trending Content
```swift
let gifService = GifServiceUseCase()

do {
    let response = try await gifService.fetchTrending(
        page: 1,
        perPage: 20,
        customerId: "user123",
        locale: "en"
    )
    // response.data contains [GifItem]
} catch {
    print("Error: \(error)")
}
```

### Searching
```swift
let clips = try await clipsService.searchClips(
    query: "funny",
    page: 1,
    perPage: 24
)
```

### Tracking Events
```swift
// Fire-and-forget tracking
try await stickerService.trackView(slug: "sticker-123")
try await stickerService.trackShare(slug: "sticker-123")
```

### Custom Client/BaseURL
```swift
// For testing or different environments
let customClient = APIClient()
let customURL = URL(string: "https://staging.api.klipy.co")!

let service = GifServiceUseCase(
    client: customClient,
    baseURL: customURL
)
```

## Benefits Over Moya

1. **No MainActor Issues**: Async/await handles context switching properly
2. **Simpler Code**: No complex protocols or abstractions
3. **Type Safety**: Full Swift type checking
4. **Native Swift**: Uses URLSession directly
5. **Testable**: Easy to mock APIClient or use custom implementations
6. **No Dependencies**: Removed external Moya dependency

## Testing

Mock the APIClient for testing:

```swift
class MockAPIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> T {
        // Return mock data
    }
}

let service = GifServiceUseCase(client: MockAPIClient())
```

## Migration from Old Code

If you have code using the old Moya-based services, the migration is straightforward:

```swift
// Old (Moya)
let service = GifServiceUseCase()
service.fetchTrending(...) { result in
    switch result {
    case .success(let data): // handle
    case .failure(let error): // handle
    }
}

// New (Async/Await)
let service = GifServiceUseCase()
do {
    let data = try await service.fetchTrending(...)
    // handle data
} catch {
    // handle error
}
```

The API surface remains the same, just with async/await instead of callbacks.