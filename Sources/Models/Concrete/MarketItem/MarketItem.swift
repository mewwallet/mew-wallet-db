////
////  File.swift
////  
////
////  Created by Nail Galiaskarov on 5/31/21.
////
//
//import Foundation
//
//public final class MarketItem: MDBXObject {
//  enum CodingKeys: String, CodingKey {
//    case circulatingSupply
//    case index
//    case marketCap
//    case volume24h
//    case totalSupply
//  }
//  
//  let circulatingSupply: Decimal
//  let index: Int
//  let marketCap: Decimal
//  let volume24h: Decimal
//  let totalSupply: Decimal
//  
//  init(
//    circulatingSupply: Decimal,
//    index: Int,
//    marketCap: Decimal,
//    volume24h: Decimal,
//    totalSupply: Decimal
//  ) {
//    self.circulatingSupply = circulatingSupply
//    self.index = index
//    self.marketCap = marketCap
//    self.volume24h = volume24h
//    self.totalSupply = totalSupply
//    
//    super.init()
//  }
//  
//  required init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    
//    circulatingSupply = try container.decode(Decimal.self, forKey: .circulatingSupply)
//    index = try container.decode(Int.self, forKey: .index)
//    marketCap = try container.decode(Decimal.self, forKey: .marketCap)
//    volume24h = try container.decode(Decimal.self, forKey: .volume24h)
//    totalSupply = try container.decode(Decimal.self, forKey: .totalSupply)
//    
//    super.init()
//  }
//  
//  public override func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    
//    try container.encode(circulatingSupply, forKey: .circulatingSupply)
//    try container.encode(index, forKey: .index)
//    try container.encode(marketCap, forKey: .marketCap)
//    try container.encode(volume24h, forKey: .volume24h)
//    try container.encode(totalSupply, forKey: .totalSupply)
//  }
//}
