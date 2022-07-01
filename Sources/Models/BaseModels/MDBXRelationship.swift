//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public final class MDBXRelationship<K: MDBXKey, T: MDBXObject> {
  private var _data: [T]?
  private let _table: MDBXTableName
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  func getRangedRelationship(startKey: K, endKey: K, policy: RelationshipLoadPolicy = .cacheOrLoad, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    if policy == .ignoreCache || _data == nil {
      let data: [T] = try database.fetchRange(startKey: startKey, endKey: endKey, from: _table)
      _data = data
    }
    return _data ?? []
  }
  
  func updateData(_ data: [T]) {
    _data = data
  }
}
