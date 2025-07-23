//
//  KlipyWebViewRepresentable.swift
//  KlipyiOS-demo
//
//  Created by Tornike Gomareli on 07.02.25.
//

import SwiftUI

public struct KlipyWebViewRepresentable: UIViewRepresentable {
  public let url: URL?
  public let htmlString: String?
  
  init(url: URL? = nil, htmlString: String? = nil) {
    self.url = url
    self.htmlString = htmlString
  }
  
  public func makeUIView(context: Context) -> KlipyWebView {
    KlipyWebView()
  }
  
  public func updateUIView(_ webView: KlipyWebView, context: Context) {
    if let url = url {
      webView.loadURL(url: url)
    } else if let htmlString = htmlString {
      webView.loadHTMLString(htmlString: htmlString)
    }
  }
}
