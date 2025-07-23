# Klipy iOS SDK Guide

The Klipy iOS SDK provides a simple, unified interface for integrating Klipy's GIF, Clips, and Stickers functionality into your iOS app.

## Quick Start

### 1. Installation

Add the Klipy package to your project's Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/Klipy-iOS.git", from: "1.0.0")
]
```

### 2. Setup

Initialize Klipy with your API key when your app launches:

```swift
import Klipy

// In your App delegate or SwiftUI App
Klipy.setup(apiKey: "your-api-key-here")

// Optionally provide a custom customer ID
Klipy.setup(apiKey: "your-api-key-here", customerId: "user-123")
```

### 3. Basic Usage

```swift
// Fetch trending GIFs
let gifs = try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)

// Search for clips
let clips = try await Klipy.clips.searchClips(query: "funny", page: 1)

// Get sticker categories
let categories = try await Klipy.stickers.fetchCategories()
```

## Core Features

### Customer ID Management

Klipy automatically manages customer IDs for tracking and personalization:

```swift
// Get current customer ID
let customerId = Klipy.customerId

// Update customer ID (e.g., after login)
Klipy.updateCustomerId(to: "authenticated-user-123")

// Clear customer ID (e.g., after logout)
Klipy.clearCustomerId()
```

If no customer ID is provided, Klipy generates and persists one automatically.

### Service Access

All services are accessed through the main `Klipy` class:

```swift
// GIFs
try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)
try await Klipy.gifs.searchGifs(query: "cats", page: 1, perPage: 20)
try await Klipy.gifs.fetchCategories()
try await Klipy.gifs.trackView(slug: "gif-123")

// Clips
try await Klipy.clips.fetchTrending(page: 1, perPage: 24)
try await Klipy.clips.searchClips(query: "memes", page: 1)
try await Klipy.clips.trackShare(slug: "clip-456")

// Stickers
try await Klipy.stickers.fetchTrending(page: 1, perPage: 24)
try await Klipy.stickers.searchStickers(query: "emoji", page: 1)
try await Klipy.stickers.reportSticker(slug: "sticker-789", reason: "inappropriate")
```

## API Reference

### Setup & Configuration

#### `Klipy.setup(apiKey:customerId:)`
Initialize the SDK with your API credentials.

- `apiKey`: Your Klipy API key (required)
- `customerId`: Optional customer identifier

#### `Klipy.updateCustomerId(to:)`
Update the customer ID for tracking purposes.

#### `Klipy.clearCustomerId()`
Clear the stored customer ID. A new one will be generated on next use.

### GIF Service (`Klipy.gifs`)

#### `fetchTrending(page:perPage:customerId:locale:)`
Get trending GIFs.

#### `searchGifs(query:page:perPage:customerId:locale:)`
Search for GIFs by keyword.

#### `fetchCategories()`
Get available GIF categories.

#### `fetchRecentItems(page:perPage:customerId:)`
Get recently viewed GIFs.

#### `trackView(slug:customerId:)`
Track a GIF view event.

#### `trackShare(slug:customerId:)`
Track a GIF share event.

#### `reportGif(slug:reason:customerId:)`
Report inappropriate content.

#### `hideFromRecent(slug:customerId:)`
Hide a GIF from recent items.

### Clips Service (`Klipy.clips`)

Similar methods available:
- `fetchTrending`
- `searchClips`
- `fetchCategories`
- `fetchRecentItems`
- `trackView`
- `trackShare`
- `reportClip`
- `hideFromRecent`

### Stickers Service (`Klipy.stickers`)

Similar methods available:
- `fetchTrending`
- `searchStickers`
- `fetchCategories`
- `fetchRecentItems`
- `trackView`
- `trackShare`
- `reportSticker`
- `hideFromRecent`

### Health Check Service (`Klipy.healthCheck`)

#### `fetchUpdateInfo()`
Check API health and get update information.

## Error Handling

The SDK throws typed errors that you should handle:

```swift
do {
    let gifs = try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)
    // Use gifs
} catch KlipyError.notConfigured {
    // SDK not initialized - call Klipy.setup() first
} catch APIError.networkError(let error) {
    // Network connection issue
} catch APIError.httpError(let statusCode, let data) {
    // Server returned an error
} catch {
    // Other errors
}
```

## Advanced Usage

### Custom Parameters

Most methods accept optional customer ID and locale overrides:

```swift
// Use specific customer ID for this request
let gifs = try await Klipy.gifs.fetchTrending(
    page: 1,
    perPage: 20,
    customerId: "special-user",
    locale: "es"
)
```

### Pagination

All list endpoints support pagination:

```swift
var allGifs: [GifItem] = []
var currentPage = 1
var hasMore = true

while hasMore {
    let response = try await Klipy.gifs.fetchTrending(
        page: currentPage,
        perPage: 50
    )
    allGifs.append(contentsOf: response.data)
    hasMore = response.data.count == 50
    currentPage += 1
}
```

## SwiftUI Integration

Example view using Klipy:

```swift
struct GifBrowser: View {
    @State private var gifs: [GifItem] = []
    @State private var isLoading = false
    
    var body: some View {
        List(gifs) { gif in
            GifRow(gif: gif)
                .onAppear {
                    // Track view when gif appears
                    Task {
                        try? await Klipy.gifs.trackView(slug: gif.slug)
                    }
                }
        }
        .task {
            isLoading = true
            do {
                let response = try await Klipy.gifs.fetchTrending(
                    page: 1,
                    perPage: 50
                )
                gifs = response.data
            } catch {
                // Handle error
            }
            isLoading = false
        }
    }
}
```

## Best Practices

1. **Initialize Early**: Call `Klipy.setup()` as early as possible in your app lifecycle.

2. **Handle Errors**: Always wrap Klipy calls in do-catch blocks.

3. **Customer ID**: Update the customer ID when users log in/out for better tracking.

4. **Pagination**: Implement proper pagination for large result sets.

5. **Caching**: Consider caching responses to reduce API calls.

## Migration from Direct API Usage

If you were using the services directly before:

```swift
// Old way
let gifService = GifServiceUseCase()
let gifs = try await gifService.fetchTrending(page: 1, perPage: 20)

// New way
Klipy.setup(apiKey: "your-key")
let gifs = try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)
```

## Troubleshooting

### "Klipy not configured" Error

Make sure you call `Klipy.setup()` before using any services:

```swift
// ✅ Correct
Klipy.setup(apiKey: "your-key")
let gifs = try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)

// ❌ Wrong - will throw error
let gifs = try await Klipy.gifs.fetchTrending(page: 1, perPage: 20)
```

### Customer ID Not Persisting

The SDK uses `UserDefaults` to persist customer IDs. Make sure your app has proper permissions and isn't clearing user defaults.

## Support

For issues or questions:
- GitHub Issues: [your-repo-url]
- Documentation: [your-docs-url]
- Email: support@klipy.co