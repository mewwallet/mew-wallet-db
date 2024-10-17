//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import mew_wallet_ios_extensions

extension PurchaseToken {
  public final class Key: MDBXKey {

    // MARK: - Public

    public let key: Data
    public let chain: MDBXChain
    public let contractAddress: Address

    // MARK: - Lifecycle

    public init(chain: MDBXChain, contractAddress: Address) {
      let chainPart = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)

      let key = chainPart + contractAddressPart
      self.key = key

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()

      self.contractAddress = {
        return Address(rawValue: key[_contractAddressRange].hexString)
      }()
    }

    public init?(data: Data) {
      guard data.count == MDBXKeyLength.purchaseToken else { return nil }
      self.key = data

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: data[_chainRange])
      }()

      self.contractAddress = {
        return Address(rawValue: data[_contractAddressRange].hexString)
      }()
    }

    public init(chain: MDBXChain, lowerRange: Bool) {
      let chainPart = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)

      let contractAddressPart: Data

      if lowerRange {
        contractAddressPart = Data().setLengthLeft(MDBXKeyLength.address)
      } else {
        contractAddressPart = Data(repeating: 0xFF, count: MDBXKeyLength.address)
      }

      let key = chainPart + contractAddressPart
      self.key = key

      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count

      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()

      self.contractAddress = {
        return Address(rawValue: key[_contractAddressRange].hexString)
      }()
    }
  }
}

// MARK: - PurchaseToken.Key + Range

extension PurchaseToken.Key {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = PurchaseToken.Key(chain: chain, lowerRange: true)
    let end = PurchaseToken.Key(chain: chain, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
