//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation
import MEWextensions

public class RawTransaction: MDBXObjectOld {
  fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
    case blockNumber
    case from
    case gas
    case gasPrice
    case hash
    case input
    case nonce
    case to
    case value
    case maxFeePerGas
    case maxPriorityFeePerGas
  }

  public let blockNumber: Decimal?            // blockNumber: QUANTITY - block number where this transaction was in. null when its pending.
  public let from: Data                       // from: DATA, 20 Bytes - address of the sender.
  public let gas: Decimal                     // gas: QUANTITY - gas provided by the sender.
  public let gasPrice: Decimal                // gasPrice: QUANTITY - gas price provided by the sender in Wei.
  public let hash: Data                       // hash: DATA, 32 Bytes - hash of the transaction.
  public let input: Data                      // input: DATA - the data send along with the transaction.
  public let nonce: Decimal                   // nonce: QUANTITY - the number of transactions made by the sender prior to this one.
  public let to: Data                         // to: DATA, 20 Bytes - address of the receiver. null when its a contract creation transaction.
  public let value: Decimal                   // value: QUANTITY - value transferred in Wei.
  public let maxFeePerGas: Decimal?           // maxFeePerGas: QUANTITY - maxFeePerGas provided by the sender.
  public let maxPriorityFeePerGas: Decimal?   // maxPriorityFeePerGas: QUANTITY - maxPriorityFeePerGas provided by the sender.

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    blockNumber           = try container.decodeWrappedIfPresent(String.self, forKey: .blockNumber, decodeHex: true)
    from                  = try container.decodeWrapped(String.self, forKey: .from, decodeHex: true)
    gas                   = try container.decodeWrapped(String.self, forKey: .gas, decodeHex: true)
    gasPrice              = try container.decodeWrapped(String.self, forKey: .gasPrice, decodeHex: true)
    hash                  = try container.decodeWrapped(String.self, forKey: .hash, decodeHex: true)
    input                 = try container.decodeWrapped(String.self, forKey: .input, decodeHex: true)
    nonce                 = try container.decodeWrapped(String.self, forKey: .nonce, decodeHex: true)
    to                    = try container.decodeWrapped(String.self, forKey: .to, decodeHex: true)
    value                 = try container.decodeWrapped(String.self, forKey: .value, decodeHex: true)
    maxFeePerGas          = try container.decodeWrappedIfPresent(String.self, forKey: .maxFeePerGas, decodeHex: true)
    maxPriorityFeePerGas  = try container.decodeWrappedIfPresent(String.self, forKey: .maxPriorityFeePerGas, decodeHex: true)
    
    try super.init(from: decoder)
  }
  
  public init(blockNumber: Decimal?,
              from: Data,
              gas: Decimal,
              gasPrice: Decimal,
              hash: Data,
              input: Data,
              nonce: Decimal,
              to: Data,
              value: Decimal,
              maxFeePerGas: Decimal?,
              maxPriorityFeePerGas: Decimal?) {
    self.blockNumber = blockNumber
    self.from = from
    self.gas = gas
    self.gasPrice = gasPrice
    self.hash = hash
    self.input = input
    self.nonce = nonce
    self.to = to
    self.value = value
    self.maxFeePerGas = maxFeePerGas
    self.maxPriorityFeePerGas = maxPriorityFeePerGas
    
    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encodeIfPresent(blockNumber,          forKey: .blockNumber, wrapIn: String.self, encodeHex: true)
    try container.encode(from,                          forKey: .from, wrapIn: String.self, encodeHex: true)
    try container.encode(gas,                           forKey: .gas, wrapIn: String.self, encodeHex: true)
    try container.encode(gasPrice,                      forKey: .gasPrice, wrapIn: String.self, encodeHex: true)
    try container.encode(hash,                          forKey: .hash, wrapIn: String.self, encodeHex: true)
    try container.encode(input,                         forKey: .input, wrapIn: String.self, encodeHex: true)
    try container.encode(nonce,                         forKey: .nonce, wrapIn: String.self, encodeHex: true)
    try container.encode(to,                            forKey: .to, wrapIn: String.self, encodeHex: true)
    try container.encode(value,                         forKey: .value, wrapIn: String.self, encodeHex: true)
    try container.encodeIfPresent(maxFeePerGas,         forKey: .maxFeePerGas, wrapIn: String.self, encodeHex: true)
    try container.encodeIfPresent(maxPriorityFeePerGas, forKey: .maxPriorityFeePerGas, wrapIn: String.self, encodeHex: true)
  }
}

extension RawTransaction: CustomDebugStringConvertible {
  public var debugDescription: String {
    return
"""
Raw Transaction:
    BlockNumber:          \(blockNumber?.hexString ?? "")
    From:                 \(from.hexString)
    Gas:                  \(gas.hexString)
    GasPrice:             \(gasPrice.hexString)
    Hash:                 \(hash.hexString)
    Input:                \(input.hexString)
    Nonce:                \(nonce.hexString)
    To:                   \(to.hexString)
    Value:                \(value.hexString)
    MaxFeePerGas:         \(maxFeePerGas?.hexString ?? "")
    MaxPriorityFeePerGas: \(maxPriorityFeePerGas?.hexString ?? "")
"""
  }
}
