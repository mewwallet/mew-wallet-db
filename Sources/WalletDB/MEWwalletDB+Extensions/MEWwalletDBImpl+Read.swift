//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import os.signpost

public extension MEWwalletDBImpl {
  // MARK: - Ranges
  
  func fetch<T: MDBXObject>(range: MDBXKeyRange, from table: MDBXTableName) throws -> [T] {
    var results = [T]()
    
    os_signpost(.begin, log: .signpost(.read), name: "fetchRange", "from table: %{private}@", table.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      guard let db = environment.getDatabase(for: table) else {
        Logger.error(.read, "Error: No DB. Table: \(table.rawValue)")
        os_signpost(.end, log: .signpost(.read), name: "fetchRange", "Error: %{private}@", "No DB")
        throw MDBXError.notFound
      }
      let table: MDBXTable = (table, db)
      
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      
      os_signpost(.event, log: .signpost(.read), name: "fetchRange", "cursor prepared")
      let cursor = MDBXCursor()
      try cursor.open(transaction: transaction, database: table.db)
      defer {
        cursor.close()
      }
      
      results = try cursor.fetch(range: range, from: table.db)
        .compactMap {
          var encoded = try T(serializedData: $0.1, chain: $0.0.chain, key: $0.0)
          encoded.database = self
          return encoded
        }
      
      os_signpost(.end, log: .signpost(.read), name: "fetchRange", "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .signpost(.read), name: "fetchRange", "Error: BackgroundState")
      Logger.error(.read, "Error: Background state. Table: \(table.rawValue)")
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .signpost(.read), name: "fetchRange", "Error: %{private}@", error.localizedDescription)
      Logger.error(.read, "Error: \(error.localizedDescription). Table: \(table.rawValue)")
      throw error
    }
    
    return results
  }
  
  func fetchKeys<K: MDBXKey>(range: MDBXKeyRange, from table: MDBXTableName) throws -> [K] {
    var results = [K]()

    os_signpost(.begin, log: .signpost(.read), name: "fetchKeysRange", "from table: %{private}@", table.rawValue)

    do {
      let environment = try self.getEnvironment()
      guard let db = environment.getDatabase(for: table) else {
        Logger.error(.read, "Error: No DB. Table: \(table.rawValue)")
        os_signpost(.end, log: .signpost(.read), name: "fetchKeysRange", "Error: %{private}@", "No DB")
        throw MDBXError.notFound
      }
      let table: MDBXTable = (table, db)

      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }

      os_signpost(.event, log: .signpost(.read), name: "fetchKeysRange", "cursor prepared")
      let cursor = MDBXCursor()
      try cursor.open(transaction: transaction, database: table.db)
      defer {
        cursor.close()
      }

      results = try cursor.fetchKeys(range: range, from: table.db).compactMap { K(data: $0) }

      os_signpost(.end, log: .signpost(.read), name: "fetchKeysRange", "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .signpost(.read), name: "fetchKeysRange", "Error: BackgroundState")
      Logger.error(.read, "Error: Background state. Table: \(table.rawValue)")
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .signpost(.read), name: "fetchKeysRange", "Error: %{private}@", error.localizedDescription)
      Logger.error(.read, "Error: \(error.localizedDescription). Table: \(table.rawValue)")
      throw error
    }

    return results
  }
  
  func count(range: MDBXKeyRange, from table: MDBXTableName) throws -> Int {
    var results: Int = 0
    
    os_signpost(.begin, log: .signpost(.read), name: "countRange", "from table: %{private}@", table.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      guard let db = environment.getDatabase(for: table) else {
        Logger.error(.read, "Error: No DB. Table: \(table.rawValue)")
        os_signpost(.end, log: .signpost(.read), name: "countRange", "Error: %{private}@", "No DB")
        throw MDBXError.notFound
      }
      let table: MDBXTable = (table, db)
      
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      
      os_signpost(.event, log: .signpost(.read), name: "countRange", "cursor prepared")
      let cursor = MDBXCursor()
      try cursor.open(transaction: transaction, database: table.db)
      defer {
        cursor.close()
      }
      
      results = try cursor.fetchKeys(range: range, from: table.db).count
      
      os_signpost(.end, log: .signpost(.read), name: "countRange", "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .signpost(.read), name: "countRange", "Error: BackgroundState")
      Logger.error(.read, "Error: BackgroundState")
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .signpost(.read), name: "countRange", "Error: %{private}@", error.localizedDescription)
      Logger.error(.read, error)
      throw error
    }
    
    return results
  }
  
  @available(*, deprecated, message: "Use fetch(range:from)")
  func fetchAll<T: MDBXObject>(from table: MDBXTableName) throws -> [T] {
    return try self.fetchRange(startKey: nil, endKey: nil, from: table)
  }
  
  @available(*, deprecated, message: "Use fetch(range:from)")
  func fetchRange<T: MDBXObject>(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> [T] {
    return try self.fetch(range: .with(start: startKey, end: endKey), from: table)
  }
  
  @available(*, deprecated, message: "Use count(range:from)")
  func countAll(from table: MDBXTableName) throws -> Int {
    return try countRange(startKey: nil, endKey: nil, from: table)
  }
  
  @available(*, deprecated, message: "Use count(range:from)")
  func countRange(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> Int {
    return try count(range: .with(start: startKey, end: endKey), from: table)
  }
  
  // MARK: - Single Objects
  
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTableName) throws -> T {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    let table: MDBXTable = (table, db)
    return try _read(key: key, table: table, signpost: "read")
  }

  // MARK: - Private
  
  private func _read<T: MDBXObject>(key: MDBXKey, table: MDBXTable, signpost: StaticString) throws -> T {
    var result: T!
    os_signpost(.begin, log: .signpost(.read), name: signpost, "from table: %{private}@", table.name.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      var key = key.key
      os_signpost(.event, log: .signpost(.read), name: signpost, "ready for read")
      let data = try transaction.getValue(for: &key, database: table.db)
      result = try T(serializedData: data, chain: key.chain, key: key)
      result?.database = self
      os_signpost(.end, log: .signpost(.read), name: signpost, "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .signpost(.read), name: signpost, "Error: BackgroundState")
      Logger.error(.read, "Error: BackgroundState. Table: \(table.name.rawValue), Key: \(key.key.hexString)")
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .signpost(.read), name: signpost, "Error: %{private}@", error.localizedDescription)
      Logger.error(.read, "Error: \(error.localizedDescription). Table: \(table.name.rawValue), Key: \(key.key.hexString)")
      throw error
    }
    
    return result
  }
}
