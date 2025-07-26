//
//  MediaFile.swift
//  KlipyiOS-demo
//
//  Created by Tornike Gomareli on 17.01.25.
//

import Foundation

public struct MediaFile: Equatable, Sendable {
  public let mp4: MediaFileVariant?
  public let gif: MediaFileVariant
  public let webp: MediaFileVariant
  
  static let empty = MediaFile(
    mp4: nil,
    gif: MediaFileVariant(
      url: "",
      width: 0,
      height: 0
    ),
    webp: MediaFileVariant(
      url: "",
      width: 0,
      height: 0
    )
  )
}

public struct MediaFileVariant: Equatable, Sendable {
  public let url: String
  public let width: Int
  public let height: Int
}

public struct AdContentProperties: Sendable {
  public let width: Int
  public let height: Int
  public let content: String
}

public struct MediaDomainModel: Identifiable, Equatable, Sendable {
  public static func == (lhs: MediaDomainModel, rhs: MediaDomainModel) -> Bool {
    return lhs.id == rhs.id
  }
  
  public let id: Int
  public let title: String
  public let slug: String
  public let blurPreview: String?
  public let type: MediaType
  public let adContentProperties: AdContentProperties?
  
  let hd: MediaFile?
  let md: MediaFile?
  let sm: MediaFile?
  let xs: MediaFile?
  
  let singleFile: MediaFile?
  
  public var mediaFile: MediaFile? {
    return singleFile ?? hd ?? md ?? sm ?? xs
  }
  public var previewFile: MediaFile? {
    return singleFile ?? sm ?? xs ?? md ?? hd
  }
  public var compactFile: MediaFile? {
    return singleFile ?? md ?? hd ?? sm ?? xs
  }
  
  public func previewSizingFor(height: CGFloat) -> CGSize {
    var contentHeight: Int?
    var contentWidth: Int?
    
    if type == .ad {
      contentHeight = adContentProperties?.height
      contentWidth = adContentProperties?.width
      
      // dont resize ads:
      return CGSize(width: contentWidth ?? 0, height: contentHeight ?? 0)
    } else {
      contentHeight = previewFile?.gif.height
      contentWidth = previewFile?.gif.width
    }
    
    guard let contentHeight, let contentWidth else { return .zero }
    guard contentHeight > 0, contentWidth > 0, height > 0 else { return .zero }
    
    let aspectRatio = CGFloat(contentWidth) / CGFloat(contentHeight)
    let newWidth = height * aspectRatio
    
    return CGSize(width: newWidth, height: height)
  }

  public func previewSizingFor(maxWidth: CGFloat?, maxHeight: CGFloat?) -> CGSize {
    var contentHeight: Int?
    var contentWidth: Int?
    
    if type == .ad {
      contentHeight = adContentProperties?.height
      contentWidth = adContentProperties?.width
      return CGSize(width: CGFloat(contentWidth ?? 0), height: CGFloat(contentHeight ?? 0))
    } else {
      contentHeight = previewFile?.gif.height
      contentWidth = previewFile?.gif.width
    }
    
    guard let contentHeight, let contentWidth else { return .zero }
    guard contentHeight > 0, contentWidth > 0 else { return .zero }
    
    let originalWidth = CGFloat(contentWidth)
    let originalHeight = CGFloat(contentHeight)
    let aspectRatio = originalWidth / originalHeight
    
    // If neither constraint is set, return .zero
    if maxWidth == nil && maxHeight == nil {
      return .zero
    }
    
    var targetWidth = originalWidth
    var targetHeight = originalHeight
    
    if let maxWidth = maxWidth, let maxHeight = maxHeight {
      // Fit within both constraints
      let widthRatio = maxWidth / originalWidth
      let heightRatio = maxHeight / originalHeight
      let minRatio = min(widthRatio, heightRatio)
      targetWidth = originalWidth * minRatio
      targetHeight = originalHeight * minRatio
    } else if let maxWidth = maxWidth {
      // Only width constraint
      let widthRatio = maxWidth / originalWidth
      targetWidth = originalWidth * widthRatio
      targetHeight = originalHeight * widthRatio
    } else if let maxHeight = maxHeight {
      // Only height constraint
      let heightRatio = maxHeight / originalHeight
      targetWidth = originalWidth * heightRatio
      targetHeight = originalHeight * heightRatio
    }
    
    return CGSize(width: targetWidth, height: targetHeight)
  }
}

public struct MediaDomainModelRow: Identifiable {
  public var id: String {
    row.map({ String($0.id) }).joined(separator: "-")
  }
  
  public var row: [MediaDomainModel]
  public var rowHeight: CGFloat
  public var rowWidth: CGFloat
  
  public func possibleHeight(withWidth: CGFloat) -> CGFloat {
    guard withWidth > 0 else { return 0 }
    guard rowWidth > 0 else { return 0 }
    
    let multiplier = withWidth / rowWidth
    return rowHeight * multiplier
  }
}

extension Array where Array.Element == MediaDomainModel {
  public func asRows(withHeight: CGFloat, maxWidth: CGFloat) -> [MediaDomainModelRow] {
    var allRows: [MediaDomainModelRow] = []
    var currRow: [MediaDomainModel] = []
    
    var currRowHeight: CGFloat = withHeight
    var currRowWidth: CGFloat = 0
    
    for item in self {
      let currSizing = item.previewSizingFor(height: withHeight)
      guard currSizing != .zero else {
        print("👀 SKIPPING SIZE ZERO")
        continue
      }
      
      if !currRow.isEmpty, currRowWidth + currSizing.width > maxWidth {
        allRows.append(MediaDomainModelRow(row: currRow, rowHeight: withHeight, rowWidth: currRowWidth))
        currRow = []
        currRowWidth = 0
        currRowHeight = withHeight
      }
      
      currRowWidth += currSizing.width
      currRowHeight = Swift.max(currRowHeight, currSizing.height)
      currRow.append(item)
    }
    
    return allRows
  }
}

