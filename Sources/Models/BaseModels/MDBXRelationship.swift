//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public final class MDBXRelationship<K: MDBXKey, T: MDBXObject> {
  private var _data: (chain: MDBXChain, data: [T])?
  private let _table: MDBXTableName
  private let _queue = DispatchQueue(label: "db.relationship.queue")
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  // MARK: - Load
  
  func getRelationship(_ range: MDBXKeyRange, policy: RelationshipLoadPolicy, order: MDBXReadOrder, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data?.data ?? []
    }
    
    switch policy {
    case .cacheOrLoad(let chain):
      if let _data, _data.chain == chain {
        return _data.data
      }
      fallthrough
    case .ignoreCache(let chain):
      let data: [T] = try database.fetch(range: range, from: _table, order: order)
      _queue.sync {
        _data = (chain, data)
      }
      return data
    }
  }
  
  func getRelationship(_ keys: [MDBXKey], policy: RelationshipLoadPolicy, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return _data?.data ?? []
    }
    
    switch policy {
    case .cacheOrLoad(let chain):
      if let _data, _data.chain == chain {
        return _data.data
      }
      fallthrough
    case .ignoreCache(let chain):
      let data: [T] = try database.fetch(keys: keys, from: _table)
      _queue.sync {
        _data = (chain, data)
      }
      return data
    }
  }
  
  func updateData(_ data: [T], chain: MDBXChain) {
    _queue.sync {
      _data = (chain, data)
    }
  }
}

extension MDBXRelationship: @unchecked Sendable { }
