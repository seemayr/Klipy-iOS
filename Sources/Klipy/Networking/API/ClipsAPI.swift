import Foundation

public enum ClipsAPI: APIEndpoint {
    case trending(page: Int, perPage: Int, customerId: String, locale: String)
    case search(query: String, page: Int, perPage: Int, customerId: String, locale: String)
    case categories
    case recent(customerId: String, page: Int, perPage: Int)
    case hideFromRecent(customerId: String, slug: String)
    case view(slug: String, customerId: String)
    case share(slug: String, customerId: String)
    case report(slug: String, customerId: String, reason: String)
    
    public var path: String {
        switch self {
        case .trending:
            return "clips/trending"
        case .search:
            return "clips/search"
        case .categories:
            return "clips/categories"
        case .recent(let customerId, _, _):
            return "clips/recent/\(customerId)"
        case .hideFromRecent(let customerId, _):
            return "clips/recent/\(customerId)"
        case .view(let slug, _):
            return "clips/view/\(slug)"
        case .share(let slug, _):
            return "clips/share/\(slug)"
        case .report(let slug, _, _):
            return "clips/report/\(slug)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .hideFromRecent:
            return .delete
        case .view, .share, .report:
            return .post
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .trending(let page, let perPage, let customerId, let locale):
            return [
                "page": page,
                "per_page": perPage,
                "customer_id": customerId,
                "locale": locale
            ]
            
        case .search(let query, let page, let perPage, let customerId, let locale):
            return [
                "q": query,
                "page": page,
                "per_page": perPage,
                "customer_id": customerId,
                "locale": locale
            ]
            
        case .categories:
            return nil
            
        case .recent(_, let page, let perPage):
            return [
                "page": page,
                "per_page": perPage
            ]
            
        case .hideFromRecent(_, let slug):
            return ["slug": slug]
            
        case .view(_, let customerId),
             .share(_, let customerId):
            return ["customer_id": customerId]
            
        case .report(_, let customerId, let reason):
            return [
                "customer_id": customerId,
                "reason": reason
            ]
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .view, .share, .report:
            return .json
        default:
            return .url
        }
    }
}