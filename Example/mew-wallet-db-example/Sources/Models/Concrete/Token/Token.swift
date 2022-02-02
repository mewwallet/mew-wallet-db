//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/21/21.
//

import Foundation

public final class Token: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case contractAddress = "contract_address"
    case address
  }
  
  public let address: Data
  public let tokenMetaKey: TokenMetaKey
  
  private let _balance = MDBXPointer<BalanceKey, Balance>(.balance)
  public var balance: Balance? {
    let key = BalanceKey(address: address, tokenMetaKey: tokenMetaKey)
    return _balance.getData(key: key, policy: .ignoreCache, database: self.database)
  }
  
  private let _tokenMeta = MDBXPointer<TokenMetaKey, TokenMeta>(.tokenMeta)
  public var tokenMeta: TokenMeta? {
    return _tokenMeta.getData(key: tokenMetaKey, database: self.database)
  }
  
  public var isPrimary: Bool {
    return "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" == tokenMetaKey.contractAddress
  }
  
  public init(address: Data, tokenMetaKey: TokenMetaKey) {
    self.address = address
    self.tokenMetaKey = tokenMetaKey
    
    super.init()
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let contractAddress = try container.decode(String.self, forKey: .contractAddress)
    tokenMetaKey = .init(projectId: .eth, contractAddress: contractAddress)
    address = try container.decodeIfPresent(Data.self, forKey: .address) ?? Data()
    
    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(tokenMetaKey.contractAddress, forKey: .contractAddress)
    try container.encode(address, forKey: .address)
  }
}
