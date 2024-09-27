//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/24/22.
//

import Foundation
import SwiftProtobuf
 
public struct HistoryPurchaseWrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _HistoryPurchaseWrapper
  public weak var database: (any WalletDB)?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _HistoryPurchaseWrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = .universal
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _HistoryPurchaseWrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - HistoryPurchaseWrapper + Properties

extension HistoryPurchaseWrapper {
  
  // MARK: - Properties
  
  public var results: [HistoryPurchase] {
    self._wrapped.results.map({ $0.wrapped(.universal) })
  }
}

// MARK: - HistoryPurchaseWrapper + ProtoWrappedMessage

extension _HistoryPurchaseWrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> HistoryPurchaseWrapper {
    return HistoryPurchaseWrapper(self, chain: .universal)
  }
}

// MARK: - HistoryPurchaseWrapper + ProtoWrapper

extension HistoryPurchaseWrapper: ProtoWrapper {
  init(_ wrapped: _HistoryPurchaseWrapper, chain: MDBXChain) {
    self._chain = .universal
    self._wrapped = wrapped
  }
}
