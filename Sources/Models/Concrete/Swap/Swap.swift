//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/21/21.
//

import Foundation

public final class Swap: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case dex
    case fromAmount
    case status
    case timestamp
    case toAmount
    case txHash
  }
  public let dex: String
  public let fromAmount: Decimal
  public let status: Int
  public let timestamp: Date?
  public let toAmount: Decimal
  public let txHash: String
  
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    dex = try container.decode(String.self, forKey: .dex)
    fromAmount = try container.decode(Decimal.self, forKey: .fromAmount)
    status = try container.decode(Int.self, forKey: .status)
    timestamp = try? container.decode(Date.self, forKey: .timestamp)
    toAmount = try container.decode(Decimal.self, forKey: .toAmount)
    txHash = try container.decode(String.self, forKey: .txHash)

    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(dex, forKey: .fromAmount)
    try container.encode(fromAmount, forKey: .fromAmount)
    try container.encode(status, forKey: .status)
    try? container.encodeIfPresent(timestamp, forKey: .timestamp)
    try container.encode(toAmount, forKey: .toAmount)
    try container.encode(txHash, forKey: .txHash)
  }
}
