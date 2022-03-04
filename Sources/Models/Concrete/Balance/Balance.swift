////
////  File.swift
////  
////
////  Created by Nail Galiaskarov on 6/21/21.
////
//
//import Foundation
//import MEWextensions
//
//public final class Balance: MDBXObject {
//  enum CodingKeys: String, CodingKey {
//    case amount
//    case timestamp
//    case contractAddress = "contract_address"
//  }
//  
//  public let amount: Decimal
//  public let contractAddress: String
//  public let timestamp: Date?
//  
//  required public init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    
//    amount = try container.decodeWrappedIfPresent(String.self, forKey: .amount, decodeHex: true) ?? .zero
//    contractAddress = try container.decode(String.self, forKey: .contractAddress)
//    timestamp = try? container.decodeIfPresent(Date.self, forKey: .timestamp)
//    
//    super.init()
//  }
//  
//  public override func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    
//    try container.encode(amount, forKey: .amount, wrapIn: String.self, encodeHex: true)
//    try container.encode(contractAddress, forKey: .contractAddress)
//    try container.encode(timestamp, forKey: .timestamp)
//  }
//}
