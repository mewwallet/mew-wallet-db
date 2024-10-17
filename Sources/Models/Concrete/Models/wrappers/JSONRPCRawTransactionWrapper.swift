//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 12/20/22.
//

import Foundation
import SwiftProtobuf
 
public struct JSONRPCRawTransactionWrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _JSONRPCRawTransactionWrapper
  public weak var database: (any WalletDB)?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _JSONRPCRawTransactionWrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _JSONRPCRawTransactionWrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - JSONRPCRawTransactionWrapper + Properties

extension JSONRPCRawTransactionWrapper {
  
  // MARK: - Properties
  
  public var transaction: RawTransaction {
    self._wrapped.result.wrapped(_chain)
  }
}

// MARK: - _JSONRPCRawTransactionWrapper + ProtoWrappedMessage

extension _JSONRPCRawTransactionWrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> JSONRPCRawTransactionWrapper {
    return JSONRPCRawTransactionWrapper(self, chain: chain)
  }
}

// MARK: - JSONRPCRawTransactionWrapper + ProtoWrapper

extension JSONRPCRawTransactionWrapper: ProtoWrapper {
  init(_ wrapped: _JSONRPCRawTransactionWrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
