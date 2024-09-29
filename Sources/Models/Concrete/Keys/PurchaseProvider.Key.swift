//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import mew_wallet_ios_extensions

extension PurchaseProvider {
  public final class Key: MDBXKey {

    // MARK: - Public

    public let key: Data
    public let chain: MDBXChain
    public let order: UInt16
    public let name: String

    // MARK: - Lifecycle

    public init(chain: MDBXChain, order: UInt16, name: String) {
      var nameData = name.data(using: .utf8) ?? Data()
      if nameData.count > MDBXKeyLength.name {
        nameData = nameData[0..<MDBXKeyLength.name]
      }
      let chainPart = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let orderPart = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
      let namePart = nameData.setLengthRight(MDBXKeyLength.name)

      let key = chainPart + orderPart + namePart
      self.key = key

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound + MDBXKeyLength.order
      let _nameRange: Range<Int> = _orderRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()

      self.order = {
        let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
        return UInt16(bigEndian: value)
      }()

      self.name = {
        return String(data: key[_nameRange], encoding: .utf8) ?? ""
      }()
    }

    public init?(data: Data) {
      guard data.count == MDBXKeyLength.purchaseProvider else { return nil }
      self.key = data

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound + MDBXKeyLength.order
      let _nameRange: Range<Int> = _orderRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: data[_chainRange])
      }()

      self.order = {
        let value = data.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
        return UInt16(bigEndian: value)
      }()

      self.name = {
        return String(data: data[_nameRange], encoding: .utf8) ?? ""
      }()
    }

    public init(chain: MDBXChain, lowerRange: Bool) {
      let chainPart = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)

      let orderPart: Data
      let namePart: Data

      if lowerRange {
        orderPart = Data().setLengthLeft(MDBXKeyLength.order)
        namePart = Data().setLengthLeft(MDBXKeyLength.name)
      } else {
        orderPart = Data(repeating: 0xFF, count: MDBXKeyLength.order)
        namePart = Data(repeating: 0xFF, count: MDBXKeyLength.name)
      }

      let key = chainPart + orderPart + namePart
      self.key = key

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound + MDBXKeyLength.order
      let _nameRange: Range<Int> = _orderRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()

      self.order = {
        let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
        return UInt16(bigEndian: value)
      }()

      self.name = {
        return String(data: key[_nameRange], encoding: .utf8) ?? ""
      }()
    }
  }
}

// MARK: - PurchaseProvider.Key + Range

extension PurchaseProvider.Key {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = PurchaseProvider.Key(chain: chain, lowerRange: true)
    let end = PurchaseProvider.Key(chain: chain, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
