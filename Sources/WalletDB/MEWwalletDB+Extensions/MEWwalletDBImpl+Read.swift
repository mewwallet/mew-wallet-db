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
  // MARK: - Ranges
  
  func fetchAll<T: MDBXObject>(from table: MDBXTableName) throws -> [T] {
    return try self.fetchRange(startKey: nil, endKey: nil, from: table)
  }
  
  func fetchRange<T: MDBXObject>(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> [T] {
    var results = [T]()
    
    os_signpost(.begin, log: .info(.read), name: "fetchRange", "from table: %{private}@", table.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
      let table: MDBXTable = (table, db)
      
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      
      os_signpost(.event, log: .info(.read), name: "fetchRange", "cursor prepared")
      let cursor = MDBXCursor()
      try cursor.open(transaction: transaction, database: table.db)
      defer {
        cursor.close()
      }
      
      results = try cursor.fetchRange(startKey: startKey, endKey: endKey, from: table.db)
        .compactMap {
          var encoded = try T(serializedData: $0.1, chain: $0.0.chain, key: $0.0)
          encoded.database = self
          return encoded
        }
      
      os_signpost(.end, log: .info(.read), name: "fetchRange", "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .info(.read), name: "fetchRange", "Error: BackgroundState")
      os_log("Error: Background state. Table: %{private}@", log: .error(.read), type: .fault, table.rawValue)
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .info(.read), name: "fetchRange", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@. Table: %{private}@", log: .error(.read), type: .error, error.localizedDescription, table.rawValue)
      throw error
    }
    
    return results
  }
  
  func countAll(from table: MDBXTableName) throws -> Int {
    return try self.countRange(startKey: nil, endKey: nil, from: table)
  }
  
  func countRange(startKey: MDBXKey?, endKey: MDBXKey?, from table: MDBXTableName) throws -> Int {
    var results: Int = 0
    
    os_signpost(.begin, log: .info(.read), name: "countRange", "from table: %{private}@", table.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
      let table: MDBXTable = (table, db)
      
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      
      os_signpost(.event, log: .info(.read), name: "countRange", "cursor prepared")
      let cursor = MDBXCursor()
      try cursor.open(transaction: transaction, database: table.db)
      defer {
        cursor.close()
      }
      
      results = try cursor.fetchRange(startKey: startKey, endKey: endKey, from: table.db).count
      
      os_signpost(.end, log: .info(.read), name: "countRange", "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .info(.read), name: "countRange", "Error: BackgroundState")
      os_log("Error: BackgroundState", log: .info(.read), type: .fault)
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .info(.read), name: "countRange", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: .info(.read), type: .error, error.localizedDescription)
      throw error
    }
    
    return results
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
    os_signpost(.begin, log: .info(.read), name: signpost, "from table: %{private}@", table.name.rawValue)
    
    do {
      let environment = try self.getEnvironment()
      let transaction = MDBXTransaction(environment.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      var key = key.key
      os_signpost(.event, log: .info(.read), name: signpost, "ready for read")
      let data = try transaction.getValue(for: &key, database: table.db)
      result = try T(serializedData: data, chain: key.chain, key: key)
      result?.database = self
      os_signpost(.end, log: .info(.read), name: signpost, "done")
    } catch MEWwalletDBError.backgroundState {
      os_signpost(.end, log: .info(.read), name: signpost, "Error: BackgroundState")
      os_log("Error: BackgroundState. Table: %{private}@, Key: %{private}@", log: .error(.read), type: .fault, table.name.rawValue, key.key.hexString)
      throw MEWwalletDBError.backgroundState
    } catch {
      os_signpost(.end, log: .info(.read), name: signpost, "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@. Table: %{private}@, Key: %{private}@", log: .error(.read), type: .error, error.localizedDescription, table.name.rawValue, key.key.hexString)
      throw error
    }
    
    return result
  }
}
