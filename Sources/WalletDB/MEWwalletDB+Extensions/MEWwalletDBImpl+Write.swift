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
  func write(table: MDBXTableName, key: any MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int {
    let env = try self._environmentTable(for: table)
    return try await env.environment.writer.write(table: env.table, key: key, data: data, mode: mode)
  }
  
  @discardableResult
  func write(table: MDBXTableName, key: any MDBXKey, object: any MDBXObject, mode: DBWriteMode) async throws -> Int {
    let env = try self._environmentTable(for: table)
    return try await env.environment.writer.write(table: env.table, key: key, object: object, mode: mode)
  }
  
  @discardableResult
  func write<S: Sequence>(table: MDBXTableName, keysAndData: S, mode: DBWriteMode) async throws -> Int where S.Element == MDBXKeyData, S: Sendable {
    let env = try self._environmentTable(for: table)
    return try await env.environment.writer.write(table: env.table, keysAndData: keysAndData, mode: mode)
  }
  
  @discardableResult
  func write<S: Sequence>(table: MDBXTableName, keysAndObjects: S, mode: DBWriteMode) async throws -> Int where S.Element == MDBXKeyObject, S: Sendable {
    let env = try self._environmentTable(for: table)
    return try await env.environment.writer.write(table: env.table, keysAndObject: keysAndObjects, mode: mode)
  }
  
  @discardableResult
  func unsafeWrite(table: MDBXTableName, key: any MDBXKey, data: Data, mode: DBWriteMode) throws -> Int {
    let env = try self._environmentTable(for: table)
    return try env.environment.unsafeWrite.write(table: env.table, key: key, data: data, mode: mode)
  }
  
  @discardableResult
  func unsafeWrite(table: MDBXTableName, key: any MDBXKey, object: any MDBXObject, mode: DBWriteMode) throws -> Int {
    let env = try self._environmentTable(for: table)
    return try env.environment.unsafeWrite.write(table: env.table, key: key, object: object, mode: mode)
  }
  
  @discardableResult
  func unsafeWrite<S: Sequence>(table: MDBXTableName, keysAndData: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyData, S: Sendable {
    let env = try self._environmentTable(for: table)
    return try env.environment.unsafeWrite.write(table: env.table, keysAndData: keysAndData, mode: mode)
  }
  
  @discardableResult
  func unsafeWrite<S: Sequence>(table: MDBXTableName, keysAndObjects: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyObject, S: Sendable {
    let env = try self._environmentTable(for: table)
    return try env.environment.unsafeWrite.write(table: env.table, keysAndObject: keysAndObjects, mode: mode)
  }
  
  // MARK: - Completions
  
  func writeAsync(table: MDBXTableName, key: any MDBXKey, data: Data, mode: DBWriteMode, completion: @escaping @Sendable (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, key: key, data: data, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, key: any MDBXKey, object: any MDBXObject, mode: DBWriteMode, completion: @escaping @Sendable (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, key: key, object: object, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode, completion: @escaping @Sendable (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, keysAndData: keysAndData, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  func writeAsync(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode, completion: @escaping @Sendable (Bool, Int) -> Void) {
    Task {
      do {
        let count = try await self.write(table: table, keysAndObjects: keysAndObjects, mode: mode)
        completion(true, count)
      } catch {
        completion(false, 0)
      }
    }
  }
  
  // MARK: - Private
  
  private func _environmentTable(for name: MDBXTableName) throws -> (environment: MEWwalletDBEnvironment, table: MDBXTable) {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: name) else { throw MDBXError.notFound }
    
    return (environment, (name, db))
  }
}
