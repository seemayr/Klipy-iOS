//
//  AdParameters.swift
//  KlipyiOS-demo
//
//  Created by Tornike Gomareli on 07.02.25.
//

import CoreTelephony
import AdSupport
import UIKit

@MainActor
struct AdParameters {
  static let shared = AdParameters()
  
  var parameters: [String: Sendable] {
    var params: [String: Sendable] = [:]
    
    // Device Info
    params["ad-os"] = "ios"
    params["ad-osv"] = Int(UIDevice.current.systemVersion)
    params["ad-make"] = "apple"
    params["ad-model"] = "iphone"
    params["ad-device-w"] = Int(UIScreen.main.bounds.width)
    params["ad-device-h"] = Int(UIScreen.main.bounds.height)
    params["ad-pxratio"] = Int(UIScreen.main.scale)
    
    // Ad dimensions
    params["ad-min-width"] = Int(50)
    params["ad-max-width"] = Int(UIScreen.main.bounds.width) - 20
    params["ad-min-height"] = Int(50)
    params["ad-max-height"] = Int(200)
    
    let identifierForAdvertising = ASIdentifierManager.shared().advertisingIdentifier
    params["ad-ifa"] = identifierForAdvertising.uuidString
    params["ad-language"] = "EN"
    
    return params
  }
}

extension Dictionary where Key == String, Value == Any {
  func withAdParameters() async -> [String: Any] {
    let deviceParams: [String: Sendable] = await MainActor.run {
      return AdParameters.shared.parameters
    }
    
    return self.merging(deviceParams) { current, _ in current }
  }
}
