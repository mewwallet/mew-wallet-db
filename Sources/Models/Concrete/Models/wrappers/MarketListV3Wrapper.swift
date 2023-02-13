import Foundation

import SwiftProtobuf
 
public struct MarketListV3Wrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _MarketListV3Wrapper
  public weak var database: WalletDB?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _MarketListV3Wrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketListV3Wrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - MarketListV3Wrapper + Properties

extension MarketListV3Wrapper {
  
  // MARK: - Properties
  
  public var items: [MarketItem] {
    self._wrapped.results.map({ MarketItem(database: database, _wrapped: $0) })
  }
  
  public var paginationToken: String? {
    guard self._wrapped.hasPaginationToken else { return nil }
    return self._wrapped.paginationToken
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrappedMessage

extension _MarketListV3Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> MarketListV3Wrapper {
    return MarketListV3Wrapper(self, chain: chain)
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrapper

extension MarketListV3Wrapper: ProtoWrapper {
  init(_ wrapped: _MarketListV3Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
