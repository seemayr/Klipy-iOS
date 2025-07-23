//
//  MediaCategory.swift
//  KlipyiOS-demo
//
//  Created by Tornike Gomareli on 02.02.25.
//


import Foundation

struct MediaCategory: Identifiable, Equatable {
  enum ContentType {
    case trending
    case recents
    case none
  }
  
  let id = UUID()
  let name: String
  let type: ContentType
  
  init(name: String, type: ContentType = .none) {
    self.name = name
    self.type = type
  }
}
