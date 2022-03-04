////
////  File.swift
////  
////
////  Created by Nail Galiaskarov on 6/23/21.
////
//
//import Foundation
//import MEWextensions
//
//public class Transfer: MDBXObject {
//  enum CodingKeys: String, CodingKey {
//    case objectId
//    case blockNumber = "block_number"
//    case delta
//    case local
//    case nonce
//    case status
//    case timestamp
//    case txHash = "hash"
//    case contractAddress = "contract_address"
//    case address
//    case to
//    case from
//  }
//  
//  public let objectId: String
//  public let blockNumber: Int64
//  public let amount: Decimal
//  public let nonce: Int64
//  public let status: Int16
//  public let timestamp: Date?
//  public let txHash: Data
//  public let tokenMetaKey: TokenMetaKey
//  public let ownerKey: RecipientKey
//  public let fromKey: RecipientKey
//  public let toKey: RecipientKey?
//  
//  private let _meta = MDBXPointer<TokenMetaKey, TokenMeta>(.tokenMeta)
//  public var meta: TokenMeta? {
//    return _meta.getData(key: tokenMetaKey, database: self.database)
//  }
//  
//  private let _owner = MDBXPointer<RecipientKey, Recipient>(.recipient)
//  public var owner: Recipient? {
//    return _owner.getData(key: ownerKey, database: self.database)
//  }
//  
//  private let _from = MDBXPointer<RecipientKey, Recipient>(.recipient)
//  public var from: Recipient? {
//    return _from.getData(key: fromKey, database: self.database)
//  }
//  
//  public let _to = MDBXPointer<RecipientKey, Recipient>(.recipient)
//  public var to: Recipient? {
//    guard let toKey = toKey else {
//      return nil
//    }
//    return _to.getData(key: toKey, database: self.database)
//  }
//  
//  public var isPending: Bool {
//    return blockNumber == 99999999
//  }
//  
//  public var direction: TransferDirection {
//    guard let to = self.toKey?.address else {
//      return .outgoing
//    }
//        
//    switch (fromKey.address == ownerKey.address, to == ownerKey.address) {
//    case (true, true):
//      return .`self`
//    case (true, false):
//      return .outgoing
//    case (false, true):
//      return .incoming
//    default:
//      return .`self`
//    }
//  }
//    
//  public init(
//    objectId: String = UUID().uuidString,
//    blockNumber: Int64,
//    amount: Decimal,
//    nonce: Int64,
//    status: Int16,
//    timestamp: Date?,
//    txHash: Data,
//    tokenMetaKey: TokenMetaKey,
//    ownerKey: RecipientKey,
//    fromKey: RecipientKey,
//    toKey: RecipientKey?
//  ) {
//    self.objectId = objectId
//    self.blockNumber = blockNumber
//    self.amount = amount
//    self.nonce = nonce
//    self.status = status
//    self.timestamp = timestamp
//    self.txHash = txHash
//    self.tokenMetaKey = tokenMetaKey
//    self.ownerKey = ownerKey
//    self.fromKey = fromKey
//    self.toKey = toKey
//    
//    super.init()
//  }
//  
//  public required init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//    
//    objectId = try values.decodeIfPresent(String.self, forKey: .objectId) ?? UUID().uuidString
//    // Block number
//    blockNumber = try values.decodeIfPresent(Int64.self, forKey: .blockNumber) ?? 99999999
//    
//    // Amount
//    let amountString = try values.decode(String.self, forKey: .delta)
//    amount = Decimal(hex: amountString)
//        
//    // Amount
//    nonce = try values.decodeIfPresent(Int64.self, forKey: .nonce) ?? 0
//    
//    // Status
//    let statusString = try values.decode(String.self, forKey: .status).lowercased()
//    if let statusRaw = TransferStatusRaw(rawValue: statusString) {
//      self.status = statusRaw.status().rawValue
//    } else {
//      self.status = TransferStatus.unknown.rawValue
//    }
//
//    // timestamp
//    timestamp = try? values.decodeIfPresent(Date.self, forKey: .timestamp)
//
//    // txHash
//    let hashString = try values.decode(String.self, forKey: .txHash)
//    txHash = Data(hex: hashString)
//    
//    // tokenMetaKey
//    let contractAddress = try values.decode(String.self, forKey: .contractAddress)
//    tokenMetaKey = .init(projectId: .eth, contractAddress: contractAddress)
//    
//    // Owner
//    let ownerAddress = try values.decode(String.self, forKey: .address)
//    ownerKey = .init(projectId: .eth, address: ownerAddress)
//    
//    // To
//    let toAddress = try values.decodeIfPresent(String.self, forKey: .to)
//    toKey = toAddress.map { .init(projectId: .eth, address: $0) }
//    
//    // From
//    let fromAddress = try values.decode(String.self, forKey: .from)
//    fromKey = .init(projectId: .eth, address: fromAddress)
//    
//    try super.init(from: decoder)
//  }
//  
//  
//  public override func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    
//    try container.encode(objectId, forKey: .objectId)
//    try container.encode(blockNumber, forKey: .blockNumber)
//    try container.encode(amount.hexString, forKey: .delta)
//    try container.encode(nonce, forKey: .nonce)
//    
//    let transferStatus = TransferStatus(rawValue: status)
//    try container.encode(transferStatus?.stringValue ?? "unknown", forKey: .status)
//    
//    try? container.encodeIfPresent(timestamp, forKey: .timestamp)
//    try container.encode(txHash.hexString, forKey: .txHash)
//    try container.encode(tokenMetaKey.contractAddress, forKey: .contractAddress)
//    try container.encodeIfPresent(ownerKey.address, forKey: .address)
//    try container.encodeIfPresent(toKey?.address, forKey: .to)
//    try container.encodeIfPresent(fromKey.address, forKey: .from)
//  }
//}
