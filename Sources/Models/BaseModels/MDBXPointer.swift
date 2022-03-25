//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation
import mdbx_ios

public enum RelationshipLoadPolicy {
  case ignoreCache
  case cacheOrLoad
}

// TODO: Re-do to @propertyWrapper when "Property wrappers currently cannot define an 'async' or 'throws' accessor" will be fixed

public class MDBXPointer<K: MDBXKey, T: MDBXObject> {
  private var _data: T?
  private var _table: MDBXTableName
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  func getData(key: K, policy: RelationshipLoadPolicy = .cacheOrLoad, database: WalletDB?) throws -> T {
    guard let database = database else {
      guard let data = _data else {
        throw MDBXError.notFound
      }
      return data
    }
    switch policy {
    case .cacheOrLoad:
      if let _data = _data {
        return _data
      }
      fallthrough
    case .ignoreCache:
      let data: T = try database.read(key: key, table: _table)
      _data = data
      _data?.database = database
    }
    return _data!
  }
    
  func updateData(_ data: T?) {
    _data = data
  }
}
