//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public final class Recipient: MDBXObject {
  enum CodingKeys: String, CodingKey {
    case address
  }
  
  public let address: String
  
  // Create one common table to store all transfers to resolve relationship issues ?
//  private let _fromCompletedTransfers = MDBXRelationship<CompletedTransferKey, CompletedTransfer>(.completedTransfer)
//  public var fromCompletedTransfers: [CompletedTransfer]? {
//    return getTransfers(from: _fromCompletedTransfers)
//  }
//
//  private let _ownedCompletedTransfers = MDBXRelationship<CompletedTransferKey, CompletedTransfer>(.completedTransfer)
//  public var ownedCompletedTransfers: [CompletedTransfer]? {
//    return getTransfers(from: _ownedCompletedTransfers)
//  }
//
//  private let _toCompletedTransfers = MDBXRelationship<CompletedTransferKey, CompletedTransfer>(.completedTransfer)
//  public var toCompletedTransfers: [CompletedTransfer]? {
//    return getTransfers(from: _toCompletedTransfers)
//  }
  
//  private let _toSwap = MDBXPointer<RecipientKey, Recipient>(.recipient)
//  public var toSwap: Recipient? {
//    return _toSwap.getData(
//      key: .init(projectId: .eth, address: address),
//      database: self.database
//    )
//  }
  
  public init(address: String) {
    self.address = address
    
    super.init()
  }
  
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    address = try container.decode(String.self, forKey: .address)    
    super.init()
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(address, forKey: .address)
  }

}

extension Recipient {
  private func getTransfers<T: MDBXObject>(from relationship: MDBXRelationship<CompletedTransferKey, T>) -> [T]? {
    let addressData = Data(hex: address).setLengthLeft(MDBXKeyLength.address)
    guard
      let startKey = CompletedTransferKey(key: addressData.setLengthRight(MDBXKeyLength.transfer)),
      let endKey = CompletedTransferKey(key: addressData.setLengthRight(MDBXKeyLength.transfer, isNegative: true))
    else {
      return nil
    }
    
    return relationship.getRangedRelationship(
      startKey: startKey,
      endKey: endKey,
      policy: .ignoreCache,
      database: self.database
    )
  }
}
