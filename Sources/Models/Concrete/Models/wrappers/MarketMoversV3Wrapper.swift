import Foundation

import SwiftProtobuf

public struct MarketMoversV3Wrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _MarketMoversV3Wrapper
  public weak var database: WalletDB?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _MarketMoversV3Wrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketMoversV3Wrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - MarketListV3Wrapper + Properties

extension MarketMoversV3Wrapper {
  
  // MARK: - Properties
  
  public var items: [MarketMoversItem] {
    self._wrapped.results.map({ MarketMoversItem(database: database, _wrapped: $0) })
  }
  
  public var currency: String {
    self._wrapped.currency
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrappedMessage

extension _MarketMoversV3Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> MarketMoversV3Wrapper {
    return MarketMoversV3Wrapper(self, chain: chain)
  }
}

// MARK: - PricesListV3Wrapper + ProtoWrapper

extension MarketMoversV3Wrapper: ProtoWrapper {  
  init(_ wrapped: _MarketMoversV3Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
