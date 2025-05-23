//
//  File.swift
//
//
//  Created by Mikhail Nikanorov on 3/2/22.
//

import Foundation
@preconcurrency import mdbx_ios
import os.signpost
import Algorithms

fileprivate struct WriterStatic {
  static let chunkSize = 50
}

final class UnsafeWriter: @unchecked Sendable {
  private var transaction: MDBXTransaction
  
  init(environment: MDBXEnvironment) {
    self.transaction = MDBXTransaction(environment)
  }
  
  // MARK: - Write
  
  func write(table: MDBXTable, key: any MDBXKey, data: Data, mode: DBWriteMode) throws -> Int {
    guard !mode.contains(.diff) else {
      throw DBWriteError.badMode
    }
    return try self.write(table: table, keysAndData: [(key, data)], mode: mode)
  }
  
  func write(table: MDBXTable, key: any MDBXKey, object: any MDBXObject, mode: DBWriteMode) throws -> Int {
    guard !mode.contains(.diff) else {
      throw DBWriteError.badMode
    }
    return try self.write(table: table, keysAndObject: [(key, object)], mode: mode)
  }
  
  func write<S: Sequence>(table: MDBXTable, keysAndData: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyData, S: Sendable {
    return try autoreleasepool {
      let mode: DBWriteMode = mode.isEmpty ? .default : mode
      guard mode.contains(.append) || mode.contains(.override) else {
        throw DBWriteError.badMode
      }
      
      var totalCount = 0
      
      /// Optimize memory usage in diff logic
      if let range: MDBXKeyRange = mode[for: .diff] {
        var keysAndData = Array(keysAndData)
        let deletions: [any MDBXKey]
        try self.transaction.begin(parent: nil, flags: [.readWrite])
        
        /// Sort keysAndObject for proper comparison
        let db = table.db
        keysAndData.sort {
          var lhs = $0.0.key
          var rhs = $1.0.key
          return transaction.compare(a: &lhs, b: &rhs, database: db) <= 0
        }
        let newKeys = keysAndData.lazy.map { $0.0.key }
        
        let cursor = MDBXCursor()
        try cursor.open(transaction: transaction, database: table.db)
        
        /// Use ArraySlice to avoid unnecessary copies
        let results: [Data] = try cursor.fetchKeys(range: range, from: table.db, order: .asc)
        
        let difference = newKeys.difference(from: results)
        deletions = difference.compactMap {
          if case let .remove(_, key, _) = $0 {
            return key
          }
          return nil
        }
        
        if deletions.isEmpty {
          try? self.transaction.abort()
        } else {
          let db = table.db
          try deletions.forEach {
            var key = $0.key
            try transaction.delete(key: &key, database: db)
          }
          try self.transaction.commit()
          totalCount += deletions.count
        }
        
        cursor.close()
      }
      
      os_signpost(.begin, log: .signpost(.write), name: "write", "to table: %{private}@", table.name.rawValue)
      
      let chunks = Array(keysAndData).lazy.chunks(ofCount: WriterStatic.chunkSize)
      
      do {
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
            os_signpost(.event, log: .signpost(.write), name: "write", "put finished")
            try self.transaction.commit()
          } else {
            os_signpost(.event, log: .signpost(.write), name: "write", "nothing to put")
            try self.transaction.abort()
          }
          totalCount += count
        }
        
        os_signpost(.end, log: .signpost(.write), name: "write", "done")
        return totalCount
      } catch {
        os_signpost(.end, log: .signpost(.write), name: "write", "Error: %{private}@", error.localizedDescription)
        Logger.error(.write, error)
        try self.transaction.abort()
        return 0
      }
    }
  }
  
  func write<S: Sequence>(table: MDBXTable, keysAndObject: S, mode: DBWriteMode) throws -> Int where S.Element == MDBXKeyObject, S: Sendable {
    return try autoreleasepool {
      let mode: DBWriteMode = mode.isEmpty ? .default : mode
      guard mode.contains(.append) || mode.contains(.override) else {
        throw DBWriteError.badMode
      }
      
      os_signpost(.begin, log: .signpost(.write), name: "write", "to table: %{private}@", table.name.rawValue)
      var totalCount = 0
      
      /// Optimize memory usage in diff logic
      if let range: MDBXKeyRange = mode[for: .diff] {
        var keysAndObject = Array(keysAndObject)
        let deletions: [any MDBXKey]
        try self.transaction.begin(parent: nil, flags: [.readWrite])
        
        /// Sort keysAndObject for proper comparison
        let db = table.db
        keysAndObject.sort {
          var lhs = $0.0.key
          var rhs = $1.0.key
          return transaction.compare(a: &lhs, b: &rhs, database: db) <= 0
        }
        let newKeys = keysAndObject.lazy.map { $0.0.key }
        
        let cursor = MDBXCursor()
        try cursor.open(transaction: transaction, database: table.db)
        
        /// Use ArraySlice to avoid unnecessary copies
        var results: [Data] = try cursor.fetchKeys(range: range, from: table.db, order: .asc)
        if range.op == .greaterThanStart {
          if let first = results.first?.hexString, first == range.start?.key.hexString {
            results = Array(results.dropFirst())
          }
        }
        
        let difference = newKeys.difference(from: results)
        deletions = difference.compactMap {
          if case let .remove(_, key, _) = $0 {
            return key
          }
          return nil
        }
        
        if deletions.isEmpty {
          try? self.transaction.abort()
        } else {
          let db = table.db
          try deletions.forEach {
            var key = $0.key
            try transaction.delete(key: &key, database: db)
          }
          try self.transaction.commit()
          totalCount += deletions.count
        }
        
        cursor.close()
      }
      
      /// Process in chunks to limit memory usage
      let chunks = Array(keysAndObject).lazy.chunks(ofCount: WriterStatic.chunkSize)
      
      do {
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
            // Serialize objects efficiently
            var data = try object.serialized
            guard try self.canWrite(key: key, data: data, in: table, with: mode) else {
              continue
            }
            
            /// Merge logic optimized for fewer operations
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
            os_signpost(.event, log: .signpost(.write), name: "write", "put finished")
            try self.transaction.commit()
          } else {
            os_signpost(.event, log: .signpost(.write), name: "write", "nothing to put")
            try self.transaction.abort()
          }
          totalCount += count
        }
        
        os_signpost(.end, log: .signpost(.write), name: "write", "done")
        return totalCount
      } catch {
        os_signpost(.end, log: .signpost(.write), name: "write", "Error: %{private}@", error.localizedDescription)
        Logger.error(.write, error)
        try self.transaction.abort()
        return 0
      }
    }
  }
  
  // MARK: - Drop
  
  func drop(table: MDBXTable, delete: Bool) throws {
    os_signpost(.begin, log: .signpost(.table), name: "drop", "table: %{private}@ (%d)", table.name.rawValue, delete)
    
    do {
      os_signpost(.event, log: .signpost(.table), name: "drop", "ready to drop")
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      try self.transaction.drop(database: table.db, delete: delete)
      try self.transaction.commit()
      os_signpost(.end, log: .signpost(.table), name: "drop", "dropped")
    } catch MDBXError.notFound {
      try? self.transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "drop", "Table not found")
    } catch {
      try? self.transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "drop", "Error: %{private}@", error.localizedDescription)
      Logger.critical(.table, "Drop error: \(error.localizedDescription)")
      throw error
    }
  }
  
  // MARK: - Delete
  
  func delete(key: any MDBXKey, in table: MDBXTable) throws -> Int {
    os_signpost(.begin, log: .signpost(.table), name: "delete", "table: %{private}@ (%d)", table.name.rawValue)
    
    do {
      var key = key.key
      os_signpost(.event, log: .signpost(.table), name: "delete", "ready to delete")
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      try self.transaction.delete(key: &key, database: table.db)
      try self.transaction.commit()
      os_signpost(.end, log: .signpost(.table), name: "delete", "dropped")
      return 1
    } catch MDBXError.notFound {
      try? self.transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "delete", "Key not found")
      return 0
    } catch {
      try? self.transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "delete", "Error: %{private}@", error.localizedDescription)
      Logger.error(.table, "Delete error: \(error.localizedDescription)")
      throw error
    }
  }
  
  // MARK: - Recover
  
  func recover(table: MDBXTableName) throws -> MDBXDatabase {
    os_signpost(.begin, log: .signpost(.table), name: "recover")
    try transaction.begin(parent: nil, flags: [.readWrite])
    do {
      os_signpost(.event, log: .signpost(.table), name: "recover", "table prepare: %{private}@", table.rawValue)
      let db = MDBXDatabase()
      try db.open(transaction: transaction, name: table.rawValue, flags: .create)
      os_signpost(.event, log: .signpost(.table), name: "recover", "table done: %{private}@", table.rawValue)
      try transaction.commit()
      os_signpost(.end, log: .signpost(.table), name: "recover")
      return db
    } catch {
      try transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "recover", "error: %{private}@", error.localizedDescription)
      Logger.error(.table, error)
      throw error
    }
  }
  
  // MARK: - Private
  
  /// Returns flag if data should be saved based on mode
  /// - if `mode` contains both `.append` and `.override`, and not `.changes` - we must write anyway
  /// - if `mode` contains `.override`, but key doesn't exist - we should skip object
  /// - if `mode` doesn't contains `override` and contains
  private func canWrite(key: any MDBXKey, data: Data, in table: MDBXTable, with mode: DBWriteMode) throws -> Bool {
    // Write all
    if mode.contains([.append, .override]), !mode.contains(.changes) {
      return true
    }
    if !mode.contains(.override) {
      // Write new only
      guard try !self.transaction.isKeyExist(key: key, database: table.db) else {
        os_signpost(.event, log: .signpost(.write), name: "write", "key exist %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
        return false
      }
      return true
    } else {
      let isExist = try self.transaction.isKeyExist(key: key, database: table.db)
      if !mode.contains(.changes) {
        if !isExist {
          os_signpost(.event, log: .signpost(.write), name: "write", "key not exist %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
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
            os_signpost(.event, log: .signpost(.write), name: "write", "key exist or no changes %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
          }
          return result
        } else {
          let result = isExist && hasChanges
          if !result {
            os_signpost(.event, log: .signpost(.write), name: "write", "key not exist or no changes %{private}@ in table %{private}@. Mode: %{private}d", key.key.hexString, table.name.rawValue, mode.rawValue)
          }
          return result
        }
      }
    }
  }
}
