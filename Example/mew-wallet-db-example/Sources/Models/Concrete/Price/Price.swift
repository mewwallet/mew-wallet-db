//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation

public final class Price: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case price
    case currency
    case timestamp
    case contractAddress = "contract_address"
  }
  
  public let price: Decimal
  public let currency: String
  public let timestamp: Date
  public let tokenMetaKey: TokenMetaKey
  
  init(price: Decimal, currency: String, timestamp: Date, tokenMetaKey: TokenMetaKey) {
    self.price = price
    self.currency = currency
    self.timestamp = timestamp
    self.tokenMetaKey = tokenMetaKey
    
    super.init()
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    price = try container.decodeWrappedIfPresent(String.self, forKey: .price) ?? .zero
    currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "USD"
    timestamp = try container.decode(Date.self, forKey: .timestamp)
    let key = try container.decode(String.self, forKey: .contractAddress)
    tokenMetaKey = .init(projectId: .eth, contractAddress: key)
    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(price, forKey: .price, wrapIn: String.self)
    try container.encode(currency, forKey: .currency)
    try container.encodeIfPresent(tokenMetaKey.contractAddress, forKey: .contractAddress)
    try container.encode(timestamp, forKey: .timestamp)
  }
}
