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
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int {
    let db = try self.database(for: table)
    return try await self.writer.write(table: db, key: key, data: data, mode: mode)
  }
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode) async throws -> Int {
    let data = try object.serialized
    return try await self.write(table: table, key: key, data: data, mode: mode)
  }
  
  @discardableResult
  func write(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode) async throws -> Int {
    let db = try self.database(for: table)
    return try await self.writer.write(table: db, keysAndData: keysAndData, mode: mode)
  }
  
  @discardableResult 
  func write(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode) async throws -> Int {
    let keysAndData: [(MDBXKey, Data)] = try keysAndObjects.map({
      let data = try $0.1.serialized
      return ($0.0, data)
    })
    return try await self.write(table: table, keysAndData: keysAndData, mode: mode)
  }
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, key: key, data: data, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, key: key, object: object, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, keysAndData: keysAndData, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, keysAndObjects: keysAndObjects, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
}
