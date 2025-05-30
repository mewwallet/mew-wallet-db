//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/20/25.
//

import Foundation
import mdbx_ios

actor Writer {
  private let unsafeWriter: UnsafeWriter
  
  init(unsafeWriter: UnsafeWriter) {
    self.unsafeWriter = unsafeWriter
  }
  
  // MARK: - Write
  
  func write(table: MDBXTable, key: any MDBXKey, data: Data, mode: DBWriteMode) throws -> Int {
    return try self.unsafeWriter.write(table: table, key: key, data: data, mode: mode)
  }
  
  func write(table: MDBXTable, key: any MDBXKey, object: any MDBXObject, mode: DBWriteMode) throws -> Int {
    return try self.unsafeWriter.write(table: table, key: key, object: object, mode: mode)
  }
  
  func write<S: Sequence>(table: MDBXTable, keysAndData: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyData, S: Sendable {
    return try self.unsafeWriter.write(table: table, keysAndData: keysAndData, mode: mode)
  }
  
  func write<S: Sequence>(table: MDBXTable, keysAndObject: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyObject, S: Sendable {
    return try self.unsafeWriter.write(table: table, keysAndObject: keysAndObject, mode: mode)
  }
  
  // MARK: - Drop
  
  func drop(table: MDBXTable, delete: Bool) throws {
    try self.unsafeWriter.drop(table: table, delete: delete)
  }
  
  // MARK: - Delete
  
  func delete(key: any MDBXKey, in table: MDBXTable) async throws -> Int {
    try self.unsafeWriter.delete(key: key, in: table)
  }
  
  // MARK: - Recover
  
  func recover(table: MDBXTableName) throws -> MDBXDatabase {
    try self.unsafeWriter.recover(table: table)
  }
}
