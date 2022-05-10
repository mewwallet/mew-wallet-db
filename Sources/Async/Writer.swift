//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/2/22.
//

import Foundation
import mdbx_ios
import OSLog
import Algorithms

fileprivate struct WriterStatic {
  static let chunkSize = 50
}

actor Writer {
  private var transaction: MDBXTransaction
  
  init(environment: MDBXEnvironment) {
    self.transaction = MDBXTransaction(environment)
  }
  
  // MARK: - Write
  
  func write(table: MDBXTable, key: MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int {
    return try await self.write(table: table, keysAndData: [(key, data)], mode: mode)
  }
  
  func write(table: MDBXTable, key: MDBXKey, object: MDBXObject, mode: DBWriteMode) async throws -> Int {
    return try await self.write(table: table, keysAndObject: [(key, object)], mode: mode)
  }
  
  func write(table: MDBXTable, keysAndData: [MDBXKeyData], mode: DBWriteMode) async throws -> Int {
    let mode: DBWriteMode = mode.isEmpty ? .default : mode
    guard mode.contains(.append) || mode.contains(.override) else {
      throw DBWriteError.badMode
    }
    
    os_signpost(.begin, log: .info(.write), name: "write", "to table: %{private}@", table.name.rawValue)
    
    let chunks = keysAndData.chunks(ofCount: WriterStatic.chunkSize)
    
    do {
      var totalCount = 0
      var dropped = !mode.contains(.dropTable)
      
      for chunk in chunks {
        try self.transaction.begin(parent: nil, flags: [.readWrite])
        /// Drop table if required
        if !dropped {
          try self.transaction.drop(database: table.db, delete: false)
          dropped = true
        }
        var count = 0
        for (key, data) in chunk {
          guard try self.canWrite(key: key, data: data, in: table, with: mode) else {
            continue
          }
          
          count += 1
          try self.transaction.write(key: key, value: data, database: table.db)
        }
        
        if count > 0 {
          os_signpost(.event, log: .info(.write), name: "write", "put finished")
          try self.transaction.commit()
        } else {
          os_signpost(.event, log: .info(.write), name: "write", "nothing to put")
          try self.transaction.abort()
        }
        totalCount += count
      }
      
      os_signpost(.end, log: .info(.write), name: "write", "done")
      return totalCount
    } catch {
      os_signpost(.end, log: .error(.write), name: "write", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: .error(.write), type: .error, error.localizedDescription)
      try self.transaction.abort()
      return 0
    }
  }
  
  func write(table: MDBXTable, keysAndObject: [MDBXKeyObject], mode: DBWriteMode) async throws -> Int {
    let mode: DBWriteMode = mode.isEmpty ? .default : mode
    guard mode.contains(.append) || mode.contains(.override) else {
      throw DBWriteError.badMode
    }
    
    os_signpost(.begin, log: .info(.write), name: "write", "to table: %{private}@", table.name.rawValue)
    
    let chunks = keysAndObject.chunks(ofCount: WriterStatic.chunkSize)
    
    do {
      var totalCount = 0
      var dropped = !mode.contains(.dropTable)
      for chunk in chunks {
        try self.transaction.begin(parent: nil, flags: [.readWrite])
        
        /// Drop table if required
        if !dropped {
          try self.transaction.drop(database: table.db, delete: false)
          dropped = true
        }
        var count = 0
        for (key, object) in chunk {
          var data = try object.serialized
          guard try self.canWrite(key: key, data: data, in: table, with: mode) else {
            continue
          }
          
          /// Merge objects if required
          if mode.contains(.merge) {
            var key = key.key
            do {
              let cachedData = try self.transaction.getValue(for: &key, database: table.db)
              var cachedObject = try type(of: object).init(serializedData: cachedData, chain: key.chain, key: key)
              cachedObject.merge(with: object)
              data = try cachedObject.serialized
              /// Double check if we need to override object
              if mode.contains(.overrideChanges), cachedData == data {
                continue
              }
            } catch MDBXError.notFound {
            } catch {
              throw error
            }
          }
          
          count += 1
          try self.transaction.write(key: key, value: data, database: table.db)
        }
        
        if count > 0 {
          os_signpost(.event, log: .info(.write), name: "write", "put finished")
          try self.transaction.commit()
        } else {
          os_signpost(.event, log: .info(.write), name: "write", "nothing to put")
          try self.transaction.abort()
        }
        totalCount += count
      }
      
      os_signpost(.end, log: .info(.write), name: "write", "done")
      return totalCount
    } catch {
      os_signpost(.end, log: .error(.write), name: "write", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: .error(.write), type: .error, error.localizedDescription)
      try self.transaction.abort()
      return 0
    }
  }
  
  // MARK: - Drop
  
  func drop(table: MDBXTable, delete: Bool) throws {
    os_signpost(.begin, log: .info(.table), name: "drop", "table: %{private}@ (%d)", table.name.rawValue, delete)
    
    do {
      os_signpost(.event, log: .info(.table), name: "drop", "ready to drop")
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      try self.transaction.drop(database: table.db, delete: delete)
      try self.transaction.commit()
      os_signpost(.end, log: .info(.table), name: "drop", "dropped")
    } catch MDBXError.notFound {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "drop", "Table not found")
    } catch {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "drop", "Error: %{private}@", error.localizedDescription)
      os_log("Drop error: %{private}@", log: .info(.table), type: .error, error.localizedDescription)
      throw error
    }
  }
  
  // MARK: - Delete
  
  func delete(key: MDBXKey, in table: MDBXTable) async throws -> Int {
    os_signpost(.begin, log: .info(.table), name: "delete", "table: %{private}@ (%d)", table.name.rawValue)
    
    do {
      var key = key.key
      os_signpost(.event, log: .info(.table), name: "delete", "ready to delete")
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      try self.transaction.delete(key: &key, database: table.db)
      try self.transaction.commit()
      os_signpost(.end, log: .info(.table), name: "delete", "dropped")
      return 1
    } catch MDBXError.notFound {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "delete", "Key not found")
      return 0
    } catch {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "delete", "Error: %{private}@", error.localizedDescription)
      os_log("Delete error: %{private}@", log: .info(.table), type: .error, error.localizedDescription)
      throw error
    }
  }
  
  // MARK: - Recover
  
  func recover(table: MDBXTableName) throws -> MDBXDatabase {
    os_signpost(.begin, log: .info(.table), name: "recover")
    try transaction.begin(parent: nil, flags: [.readWrite])
    do {
      os_signpost(.event, log: .info(.table), name: "recover", "table prepare: %{private}@", table.rawValue)
      let db = MDBXDatabase()
      try db.open(transaction: transaction, name: table.rawValue, flags: .create)
      os_signpost(.event, log: .info(.table), name: "recover", "table done: %{private}@", table.rawValue)
      try transaction.commit()
      os_signpost(.end, log: .info(.table), name: "recover")
      return db
    } catch {
      try transaction.abort()
      os_signpost(.end, log: .info(.table), name: "recover", "error: %{private}@", error.localizedDescription)
      os_log("Prepare table error: %{private}@", log: .error(.table), type: .fault, error.localizedDescription)
      throw error
    }
  }

  
  // MARK: - Private
  
  private func canWrite(key: MDBXKey, data: Data, in table: MDBXTable, with mode: DBWriteMode) throws -> Bool {
    // Write all
    if mode.contains([.append, .override]), !mode.contains(.changes) {
      return true
    }
    if !mode.contains(.override) {
      // Write new only
      guard try !self.transaction.isKeyExist(key: key, database: table.db) else {
        os_signpost(.event, log: .info(.write), name: "write", "key exist %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
        return false
      }
      return true
    } else {
      let isExist = try self.transaction.isKeyExist(key: key, database: table.db)
      if !mode.contains(.changes) {
        if !isExist {
          os_signpost(.event, log: .info(.write), name: "write", "key not exist %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
        }
        return isExist
      } else {
        var hasChanges = false
        
        var key = key.key
        do {
          let cachedData = try self.transaction.getValue(for: &key, database: table.db)
          hasChanges = (data != cachedData)
        } catch MDBXError.notFound {
        } catch {
          throw error
        }
        
        if mode.contains(.append) {
          let result = !isExist || hasChanges
          if !result {
            os_signpost(.event, log: .info(.write), name: "write", "key exist or no changes %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
          }
          return result
        } else {
          let result = isExist && hasChanges
          if !result {
            os_signpost(.event, log: .info(.write), name: "write", "key not exist or no changes %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
          }
          return result
        }
      }
    }
  }
}
