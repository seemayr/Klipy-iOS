import Foundation

public struct StickersServiceUseCase {
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
    perPage: Int = 24,
    locale: String = "ka"
  ) async throws -> AnyResponse<StickerItem> {
    try await client.request(
      StickersAPI.trending(
        page: page,
        perPage: perPage,
        customerId: customerId,
        locale: locale
      ),
      baseURL: baseURL
    )
  }
  
  func searchStickers(
    query: String,
    page: Int,
    perPage: Int = 24,
    locale: String = "ka"
  ) async throws -> AnyResponse<StickerItem> {
    try await client.request(
      StickersAPI.search(
        query: query,
        page: page,
        perPage: perPage,
        customerId: customerId,
        locale: locale
      ),
      baseURL: baseURL
    )
  }
  
  func fetchCategories() async throws -> Categories {
    try await client.request(
      StickersAPI.categories,
      baseURL: baseURL
    )
  }
  
  func fetchRecentItems(
    page: Int,
    perPage: Int = 24
  ) async throws -> AnyResponse<StickerItem> {
    try await client.request(
      StickersAPI.recent(
        customerId: customerId,
        page: page,
        perPage: perPage
      ),
      baseURL: baseURL
    )
  }
  
  func hideFromRecent(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      StickersAPI.hideFromRecent(
        customerId: customerId,
        slug: slug
      ),
      baseURL: baseURL
    )
  }
  
  func trackView(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      StickersAPI.view(
        slug: slug,
        customerId: customerId
      ),
      baseURL: baseURL
    )
  }
  
  func trackShare(
    slug: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      StickersAPI.share(
        slug: slug,
        customerId: customerId
      ),
      baseURL: baseURL
    )
  }
  
  func reportSticker(
    slug: String,
    reason: String
  ) async throws -> FireAndForgetResponse {
    try await client.request(
      StickersAPI.report(
        slug: slug,
        customerId: customerId,
        reason: reason
      ),
      baseURL: baseURL
    )
  }
}
