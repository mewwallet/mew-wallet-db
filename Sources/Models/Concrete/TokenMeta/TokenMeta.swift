//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation

public final class TokenMeta: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case name
    case decimals
    case tokenMetaKey
    case iconPng = "icon_png"
    case icon
    case symbol
    case contractAddress = "contract_address"
  }
  
  public let name: String?
  public let decimals: Decimal
  public let tokenMetaKey: TokenMetaKey
  public let icon: URL?
  public let symbol: String?
  
  public var price: Price? {
    let key = PriceKey(tokenMetaKey: tokenMetaKey)
    return _price.getData(key: key, policy: .cacheOrLoad, database: self.database)
  }
  
  public var dexItem: DexItem? {
    let key = DexItemKey(tokenMetaKey: tokenMetaKey)
    return _dexItem.getData(key: key, policy: .cacheOrLoad, database: self.database)
  }
  
  private let _dexItem: MDBXPointer<DexItemKey, DexItem> = .init(.dex)
  private let _price: MDBXPointer<PriceKey, Price> = .init(.price)
  
  let marketItems: MDBXPointer<MarketItemKey, MarketItem> = .init(.marketItem)
  
  public init(
    name: String? = nil,
    decimals: Decimal = .zero,
    tokenMetaKey: TokenMetaKey,
    icon: URL? = nil,
    symbol: String? = nil,
    price: Price? = nil
  ) {
    self.name = name
    self.decimals = decimals
    self.tokenMetaKey = tokenMetaKey
    self.icon = icon
    self.symbol = symbol
    
    super.init()
    
    _price.updateData(price)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    name = try? container.decodeIfPresent(String.self, forKey: .name)
    let decimals = try container.decodeIfPresent(Decimal.self, forKey: .decimals)
    self.decimals = decimals ?? .zero
    let key = try container.decode(String.self, forKey: .contractAddress) // ??
    tokenMetaKey = .init(projectId: .eth, contractAddress: key)
    if let iconPng = try? container.decodeIfPresent(URL.self, forKey: .iconPng) {
      self.icon = iconPng
    } else {
      self.icon = try? container.decodeIfPresent(URL.self, forKey: .icon)
    }
    symbol = try? container.decodeIfPresent(String.self, forKey: .symbol)
    
    let price = try? Price(from: decoder)
    _price.updateData(price)

    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(decimals, forKey: .decimals)
    try container.encode(tokenMetaKey.contractAddress, forKey: .contractAddress)
    try container.encodeIfPresent(icon, forKey: .icon)
    try container.encodeIfPresent(symbol, forKey: .symbol)
  }
}
