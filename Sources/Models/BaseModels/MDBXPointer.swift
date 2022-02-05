//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation

public enum RelationshipLoadPolicy {
  case ignoreCache
  case cacheOrLoad
}

public class MDBXPointer<K: MDBXKey, T: MDBXObject> {
  private var _data: T?
  private var _table: MDBXTable
  
  init(_ table: MDBXTable) {
    _table = table
  }
  
  func getData(key: K, policy: RelationshipLoadPolicy = .cacheOrLoad, database: WalletDB?) -> T? {
    guard let database = database else {
      return _data
    }
    if policy == .ignoreCache || _data == nil {
      do {
        let data: T = try database.read(key: key, table: _table)
        _data = data
        _data?.database = database
      } catch {
      }
    }
    return _data
  }
    
  func updateData(_ data: T?) {
    _data = data
  }
}
