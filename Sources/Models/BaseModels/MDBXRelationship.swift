//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public class MDBXRelationship<K: MDBXKey, T: MDBXObject> {
  private var _data: [T]?
  private let _table: MDBXTable
  
  init(_ table: MDBXTable) {
    _table = table
  }
  
  func getRangedRelationship(
    startKey: K,
    endKey: K,
    policy: RelationshipLoadPolicy = .cacheOrLoad,
    database: WalletDB?
  ) -> [T]? {
    guard let database = database else {
      return _data
    }
    
    if policy == .ignoreCache || _data == nil {
      do {
        let data: [T] = try database.fetchRange(startKey: startKey, endKey: endKey, table: _table)
        _data = data
      } catch {
      }
    }
    return _data
  }
  
  func updateData(_ data: [T]?) {
    _data = data
  }
}
