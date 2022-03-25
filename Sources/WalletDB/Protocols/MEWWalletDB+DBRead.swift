//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public protocol DBRead {
  func fetchAll<T: MDBXObject>(from table: MDBXTableName) throws -> [T]
  func fetchRange<T: MDBXObject>(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> [T]
  func countAll(from table: MDBXTableName) throws -> Int
  func countRange(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> Int
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTableName) async throws -> T?
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTableName) throws -> T
}
