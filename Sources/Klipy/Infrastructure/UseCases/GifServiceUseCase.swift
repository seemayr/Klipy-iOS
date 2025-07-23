import Foundation

public struct GifServiceUseCase {
  private let client: APIClient
  private let baseURL: URL
  private let customerId: String
  
  public init(client: APIClient, baseURL: URL, customerId: String) {
    self.client = client
    self.baseURL = baseURL
    self.customerId = customerId
  }
  
  func fetchTrending(
    page: Int,
    perPage: Int,
    locale: String = "ka"
  ) async throws -> AnyResponse<GifItem> {
    try await client.request(
      GifAPI.trending(page: page, perPage: perPage, customerId: customerId, locale: locale),
      baseURL: baseURL
    )
  }
  
  func searchGifs(
    query: String,
    page: Int,
    perPage: Int,
    locale: String = "ka"
  ) async throws -> AnyResponse<GifItem> {
    try await client.request(
      GifAPI.search(query: query, page: page, perPage: perPage, customerId: customerId, locale: locale),
      baseURL: baseURL
    )
  }
  
  func fetchCategories() async throws -> Categories {
    try await client.request(
      GifAPI.categories,
      baseURL: baseURL
    )
  }
  
  func fetchRecentItems(
    page: Int,
    perPage: Int
  ) async throws -> AnyResponse<GifItem> {
    try await client.request(
      GifAPI.recent(customerId: customerId, page: page, perPage: perPage),
      baseURL: baseURL
    )
  }
  
  func trackView(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      GifAPI.view(slug: slug, customerId: customerId),
      baseURL: baseURL
    )
  }
  
  func trackShare(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      GifAPI.share(slug: slug, customerId: customerId),
      baseURL: baseURL
    )
  }
  
  func reportGif(
    slug: String,
    reason: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      GifAPI.report(slug: slug, customerId: customerId, reason: reason),
      baseURL: baseURL
    )
  }
  
  func hideFromRecent(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      GifAPI.hideFromRecent(customerId: customerId, slug: slug),
      baseURL: baseURL
    )
  }
}
