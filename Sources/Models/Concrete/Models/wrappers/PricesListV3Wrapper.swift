//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/9/22.
//

import Foundation
import SwiftProtobuf
 
public struct PricesListV3Wrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _PricesListV3Wrapper
  public weak var database: WalletDB?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PricesListV3Wrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _PricesListV3Wrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - PricesListV3Wrapper + Properties

extension PricesListV3Wrapper {
  
  // MARK: - Properties
  
  public var tokens: [TokenMeta] {
    self._wrapped.results.map({ $0.wrapped(_chain) })
  }
  
  public var paginationToken: String? {
    guard self._wrapped.hasPaginationToken else { return nil }
    return self._wrapped.paginationToken
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrappedMessage

extension _PricesListV3Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PricesListV3Wrapper {
    return PricesListV3Wrapper(self, chain: chain)
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrapper

extension PricesListV3Wrapper: ProtoWrapper {
  init(_ wrapped: _PricesListV3Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
