//
//  PaginatedData.swift
//  KlipyiOS-demo
//
//  Created by Tornike Gomareli on 13.01.25.
//

import Foundation

public struct PaginatedDomain: Sendable {
  public let items: [MediaDomainModel]
  public let currentPage: Int
  public let perPage: Int
  public let hasNext: Bool
  public let gridMeta: GridMeta
}

struct PaginatedData<T: Codable & Sendable>: Codable, Sendable {
  public let data: [T]
  public let currentPage: Int
  public let perPage: Int
  public let hasNext: Bool
  public let gridMeta: GridMeta
  
  enum CodingKeys: String, CodingKey {
    case data
    case currentPage = "current_page"
    case perPage = "per_page"
    case hasNext = "has_next"
    case gridMeta = "meta"
  }
}

public struct GridMeta: Codable, Sendable {
  var itemMinWidth: Int
  var adMaxResizePercent: Int
  
  enum CodingKeys: String, CodingKey {
    case itemMinWidth = "item_min_width"
    case adMaxResizePercent = "ad_max_resize_percent"
  }
}
