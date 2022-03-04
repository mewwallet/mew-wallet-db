//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import OSLog

public extension MEWwalletDBImpl {
  func write(table: MDBXTableName, key: MDBXKey, value: Data, override: Bool = true) async throws {
    let db = try self.database(for: table)
    try await self.writer.write(table: db, key: key, value: value, override: override)
  }
  
  func write(table: MDBXTableName, key: MDBXKey, value: MDBXObject, override: Bool = true) async throws {
    let value = try self.encoder.encode(value)
    try await self.write(table: table, key: key, value: value, override: override)
  }
  
  func write(table: MDBXTableName, keysAndValues: [(MDBXKey, Data)], override: Bool = true) async throws {
    let db = try self.database(for: table)
    try await self.writer.write(table: db, keysAndValues: keysAndValues, override: override)
  }
  
  func write(table: MDBXTableName, keysAndValues: [(MDBXKey, MDBXObject)], override: Bool = true) async throws {
    let keysAndValues: [(MDBXKey, Data)] = try keysAndValues.map({
      let data = try self.encoder.encode($0.1)
      return ($0.0, data)
    })
    try await self.write(table: table, keysAndValues: keysAndValues, override: override)
  }
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, value: Data, override: Bool = true, completion: @escaping (Bool) -> Void) {
    Task {
      do {
        try await self.write(table: table, key: key, value: value, override: override)
        completion(true)
      } catch {
        completion(false)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, value: MDBXObject, override: Bool = true, completion: @escaping (Bool) -> Void) {
    Task {
      do {
        try await self.write(table: table, key: key, value: value, override: override)
        completion(true)
      } catch {
        completion(false)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndValues: [(MDBXKey, Data)], override: Bool = true, completion: @escaping (Bool) -> Void) {
    Task {
      do {
        try await self.write(table: table, keysAndValues: keysAndValues, override: override)
        completion(true)
      } catch {
        completion(false)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndValues: [(MDBXKey, MDBXObject)], override: Bool = true, completion: @escaping (Bool) -> Void) {
    Task {
      do {
        try await self.write(table: table, keysAndValues: keysAndValues, override: override)
        completion(true)
      } catch {
        completion(false)
      }
    }
  }
}
