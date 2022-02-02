//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation

public final class DexItem: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case symbol
    case order
    case tokenMetaKey
    case contractAddress = "contract_address"
    case price
    case volume24h = "volume_24h"
  }
  
  public let symbol: String?
  public let order: Int?
  public let tokenMetaKey: TokenMetaKey?
  public let price: Decimal
  public let volume24h: Decimal
  
  public var meta: TokenMeta? {
    guard let key = tokenMetaKey else { return nil }
    return _meta.getData(key: key, policy: .cacheOrLoad, database: self.database)
  }
  
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  
  public init(
    symbol: String?,
    order: Int,
    tokenMetaKey: TokenMetaKey,
    price: Decimal,
    volume24h: Decimal
  ) {
    self.symbol = symbol
    self.order = order
    self.tokenMetaKey = tokenMetaKey
    self.price = price
    self.volume24h = volume24h
    
    super.init()
  }
  
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
    order = try container.decodeIfPresent(Int.self, forKey: .order)
    let key = try container.decode(String.self, forKey: .contractAddress)
    tokenMetaKey = .init(projectId: .eth, contractAddress: key)
    
    price = try container.decodeWrappedIfPresent(String.self, forKey: .price) ?? .zero
    volume24h = try container.decodeWrappedIfPresent(String.self, forKey: .volume24h) ?? .zero
    
    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(symbol, forKey: .symbol)
    try container.encode(order, forKey: .order)
    try container.encodeIfPresent(tokenMetaKey?.contractAddress, forKey: .contractAddress)
    
    try container.encode(price, forKey: .price, wrapIn: String.self)
    try container.encode(volume24h, forKey: .volume24h, wrapIn: String.self)
  }
}
