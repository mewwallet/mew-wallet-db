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
  private let _queue = DispatchQueue(label: "db.relationship.queue")
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  @available(*, deprecated, message: "Use getRelationship(_:policy:database)")
  func getRangedRelationship(startKey: K, endKey: K, policy: RelationshipLoadPolicy = .cacheOrLoad, order: MDBXReadOrder, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    if policy == .ignoreCache || _data == nil {
      let data: [T] = try database.fetch(range: .with(start: startKey, end: endKey), from: _table, order: order)
      _queue.sync {
        _data = data
      }
    }
    return _data ?? []
  }
  
  // MARK: - Load
  
  func getRelationship(_ range: MDBXKeyRange, policy: RelationshipLoadPolicy = .cacheOrLoad, order: MDBXReadOrder, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    if policy == .ignoreCache || _data == nil {
      let data: [T] = try database.fetch(range: range, from: _table, order: order)
      _queue.sync {
        _data = data
      }
    }
    return _data ?? []
  }
  
  func getRelationship(_ keys: [MDBXKey], policy: RelationshipLoadPolicy = .cacheOrLoad, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    if policy == .ignoreCache || _data == nil {
      let data: [T] = try database.fetch(keys: keys, from: _table)
      _queue.sync {
        _data = data
      }
    }
    return _data ?? []
  }
  
  func updateData(_ data: [T]) {
    _queue.sync {
      _data = data
    }
  }
}

extension MDBXRelationship: @unchecked Sendable { }
