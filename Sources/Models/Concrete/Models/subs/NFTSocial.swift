//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation

public struct NFTSocial: MDBXBackedObject, Equatable {
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _NFTSocial
}

// MARK: - NFTSocial + Properties

extension NFTSocial {
  
  // MARK: - Properties
  
  public var website: URL? {
    guard self._wrapped.hasWebsite else { return nil }
    return URL(string: self._wrapped.website)
  }
  public var discord: URL? {
    guard self._wrapped.hasDiscord else { return nil }
    return URL(string: self._wrapped.discord)
  }
  public var telegram: URL? {
    guard self._wrapped.hasTelegram else { return nil }
    return URL(string: self._wrapped.telegram)
  }
}

// MARK: - NFTSocial + Equatable

extension NFTSocial {
  public static func == (lhs: NFTSocial, rhs: NFTSocial) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTSocial + ProtoWrappedMessage

extension _NFTSocial: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTSocial {
    return NFTSocial(self, chain: chain)
  }
}

// MARK: - NFTSocial + ProtoWrapper

extension NFTSocial: ProtoWrapper {
  init(_ wrapped: _NFTSocial, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
