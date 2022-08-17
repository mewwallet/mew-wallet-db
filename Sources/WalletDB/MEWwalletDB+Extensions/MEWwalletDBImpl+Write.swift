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
  
  // MARK: - Async/await
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    let table = (table, db)
    return try await environment.writer.write(table: table, key: key, data: data, mode: mode)
  }
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode) async throws -> Int {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    let table = (table, db)
    return try await environment.writer.write(table: table, key: key, object: object, mode: mode)
  }
  
  @discardableResult
  func write(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode) async throws -> Int {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    let table = (table, db)
    return try await environment.writer.write(table: table, keysAndData: keysAndData, mode: mode)
  }
  
  @discardableResult 
  func write(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode) async throws -> Int {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    let table = (table, db)
    return try await environment.writer.write(table: table, keysAndObject: keysAndObjects, mode: mode)
  }
  
  // MARK: - Completions
  
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
