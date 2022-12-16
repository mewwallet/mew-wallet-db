//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation
import mdbx_ios

enum RelationshipLoadPolicy {
  case ignoreCache(chain: MDBXChain)
  case cacheOrLoad(chain: MDBXChain)
}

// TODO: Re-do to @propertyWrapper when "Property wrappers currently cannot define an 'async' or 'throws' accessor" will be fixed

public final class MDBXPointer<K: MDBXKey, T: MDBXObject> {
  private var _data: T?
  private var _chain: MDBXChain = .invalid
  private let _table: MDBXTableName
  private let _queue = DispatchQueue(label: "db.pointer.queue")
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  func getData(key: K, policy: RelationshipLoadPolicy, database: WalletDB?) throws -> T {
    guard let database = database else {
      guard let data = _data else {
        throw MDBXError.notFound
      }
      return data
    }
    switch policy {
    case .cacheOrLoad(let chain):
      if let _data, chain == _chain {
        return _data
      }
      fallthrough
    case .ignoreCache(let chain):
      let data: T = try database.read(key: key, table: _table)
      _queue.sync {
        _data = data
        _data?.database = database
        _chain = chain
      }
      return data
    }
  }
    
  func updateData(_ data: T?, chain: MDBXChain) {
    _queue.sync {
      _data = data
      _chain = chain
    }
  }
}

// MARK: RelationshipLoadPolicy + Equatable

extension RelationshipLoadPolicy: Equatable {
  static func ==(lhs: RelationshipLoadPolicy, rhs: RelationshipLoadPolicy) -> Bool {
    switch (lhs, rhs) {
    case (.ignoreCache, .ignoreCache): return true
    case (.cacheOrLoad, .cacheOrLoad): return true
    default:                           return false
    }
  }
}

// MARK: - MDBXPointer + Sendable

extension MDBXPointer: @unchecked Sendable {}
