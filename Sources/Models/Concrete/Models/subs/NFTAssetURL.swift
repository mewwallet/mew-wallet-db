//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import mew_wallet_ios_extensions

public struct NFTAssetURL: MDBXBackedObject, Equatable {
  public enum NFTAssetType {
    case unknown
    case image
    case media
      
    init(_ rawValue: String) {
      switch rawValue {
      case "IMAGE":       self = .image
      case "MEDIA":       self = .media
      default:            self = .unknown
      }
    }
  }
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _NFTAssetUrl
}

// MARK: - NFTAssetURL + Properties

extension NFTAssetURL {
  
  // MARK: - Properties
  
  public var type: NFTAssetType { NFTAssetType(self._wrapped.type) }
  public var url: URL? { URL(string: self._wrapped.url) }
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
