//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import mew_wallet_ios_extensions

public struct NFTAssetURL: MDBXBackedObject, Equatable {
  public enum DisplayType {
    case preview(URL)
    case image(URL)
    case video(URL)
    case audio(URL)
    case media(URL)
    
    init(type: NFTAssetType, url: URL) {
      switch type {
      case .preview:    self = .preview(url)
      case .image:      self = .image(url)
      case .video:      self = .video(url)
      case .audio:      self = .audio(url)
      case .unknown:    self = .media(url)
      case .media:      self = .media(url)
      }
    }
  }
  
  enum NFTAssetType {
    case unknown
    case preview
    case image
    case video
    case audio
    case media
      
    init(_ rawValue: String) {
      switch rawValue {
      case "PREVIEW":     self = .preview
      case "IMAGE":       self = .image
      case "VIDEO":       self = .video
      case "AUDIO":       self = .audio
      case "MEDIA":       self = .media
      default:            self = .unknown
      }
    }
  }
  public weak var database: (any WalletDB)?
  var _chain: MDBXChain
  var _wrapped: _NFTAssetUrl
  
  // MARK: - Internal Properties
  
  var type: NFTAssetType { NFTAssetType(self._wrapped.type) }
}

// MARK: - NFTAssetURL + Properties

extension NFTAssetURL {
  
  // MARK: - Properties
  
  public var displayType: DisplayType? {
    guard let url = url else { return nil }
    return DisplayType(type: self.type, url: url)
  }
  public var url: URL? {
    if self.type == .preview {
      var components = URLComponents(string: self._wrapped.url)
      if components?.queryItems == nil {
        components?.queryItems = [.init(name: "_mew_preview", value: "true")]
      } else {
        components?.queryItems?.append(.init(name: "_mew_preview", value: "true"))
      }
      return components?.url
    } else {
      return URL(string: self._wrapped.url)
    }
  }
}

// MARK: - NFTAssetURL + Equatable

extension NFTAssetURL {
  public static func == (lhs: NFTAssetURL, rhs: NFTAssetURL) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTAssetURL + ProtoWrappedMessage

extension _NFTAssetUrl: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTAssetURL {
    return NFTAssetURL(self, chain: chain)
  }
}

// MARK: - NFTAssetURL + ProtoWrapper

extension NFTAssetURL: ProtoWrapper {
  init(_ wrapped: _NFTAssetUrl, chain: MDBXChain) {
    _chain = chain
    _wrapped = wrapped
  }
}
