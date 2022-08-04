//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public protocol DBRead {
  func fetch<T: MDBXObject>(range: MDBXKeyRange, from table: MDBXTableName) throws -> [T]
  func fetchKeys<K: MDBXKey>(range: MDBXKeyRange, from table: MDBXTableName) throws -> [K]
  func count(range: MDBXKeyRange, from table: MDBXTableName) throws -> Int
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTableName) throws -> T
  
  // MARK: - Deprecated
  
  @available(*, deprecated, message: "Use fetch(range:from)")
  func fetchAll<T: MDBXObject>(from table: MDBXTableName) throws -> [T]
  
  @available(*, deprecated, message: "Use fetch(range:from)")
  func fetchRange<T: MDBXObject>(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> [T]
  
  @available(*, deprecated, message: "Use count(range:from)")
  func countAll(from table: MDBXTableName) throws -> Int
  
  @available(*, deprecated, message: "Use count(range:from)")
  func countRange(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> Int
}
