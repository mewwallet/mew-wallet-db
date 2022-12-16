//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public final class MDBXRelationship<K: MDBXKey, T: MDBXObject> {
  private var _data: [T]?
  private var _chain: MDBXChain = .invalid
  private let _table: MDBXTableName
  private let _queue = DispatchQueue(label: "db.relationship.queue")
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  // MARK: - Load
  
  func getRelationship(_ range: MDBXKeyRange, policy: RelationshipLoadPolicy, order: MDBXReadOrder, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    switch policy {
    case .cacheOrLoad(let chain):
      if let _data, chain == _chain {
        return _data
      }
      fallthrough
    case .ignoreCache(let chain):
      let data: [T] = try database.fetch(range: range, from: _table, order: order)
      _queue.sync {
        _data = data
        _chain = chain
      }
      return data
    }
  }
  
  func getRelationship(_ keys: [MDBXKey], policy: RelationshipLoadPolicy, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data ?? []
    }
    
    switch policy {
    case .cacheOrLoad(let chain):
      if let _data, chain == _chain {
        return _data
      }
      fallthrough
    case .ignoreCache(let chain):
      let data: [T] = try database.fetch(keys: keys, from: _table)
      _queue.sync {
        _data = data
        _chain = chain
      }
      return data
    }
  }
  
  func updateData(_ data: [T], chain: MDBXChain) {
    _queue.sync {
      _data = data
      _chain = chain
    }
  }
}

extension MDBXRelationship: @unchecked Sendable { }
