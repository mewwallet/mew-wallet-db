//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

// TODO:
// chain + timestamp + index
public final class MarketMoversItemKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain           { MDBXChain(rawValue: self._chain) }
  public var currency: String { _currency }
  public var sort: Data { _sort }
  public var index: UInt64 { return _index }

  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _currencyRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.currency }()
  private lazy var _currency: String = {
    return String(data: key[_currencyRange], encoding: .utf8) ?? ""
  }()
  
  private lazy var _sortRange: Range<Int> = { _currencyRange.endIndex..<_currencyRange.upperBound+MDBXKeyLength.hash }()
  private lazy var _sort: Data = {
    return key[_sortRange]
  }()
  
  private lazy var _indexRange: Range<Int> = { _sortRange.endIndex..<_sortRange.upperBound+MDBXKeyLength.index }()
  private lazy var _index: UInt64 = {
    return key[_indexRange].withUnsafeBytes { $0.load(as: UInt64.self) }
  }()

  // MARK: - Lifecycle
  
  public init(
    chain: MDBXChain,
    currency: String,
    sort: String,
    index: UInt64
  ) {
    var currencyData = currency.data(using: .utf8) ?? Data()
    if currencyData.count > MDBXKeyLength.currency {
      currencyData = currencyData[0..<MDBXKeyLength.currency]
    }
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let currencyPart         = currencyData.setLengthLeft(MDBXKeyLength.currency)
    let sortData            = sort.data(using: .utf8) ?? ""
    let sortPart            = sortData.sha256.setLengthLeft(MDBXKeyLength.hash)
    let indexPart           = withUnsafeBytes(of: index.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.index)

    
    self.key = chainPart + currencyPart + sortPart + indexPart
  }
  
  public init(chain: MDBXChain, currency: String, sort: String, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let currencyPart        = (currency.data(using: .utf8) ?? Data()).setLengthLeft(MDBXKeyLength.currency)
    let sortData            = sort.data(using: .utf8) ?? ""
    let sortPart            = sortData.sha256.setLengthLeft(MDBXKeyLength.hash)
    let indexPart            = Data(repeating: rangeValue, count: MDBXKeyLength.index)
    
    self.key = chainPart + currencyPart + sortPart + indexPart
  }

  public init?(data: Data) {
    guard data.count == MDBXKeyLength.marketMoversItem else { return nil }
    self.key = data
  }
}
