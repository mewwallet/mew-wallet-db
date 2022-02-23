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
  func fetchAll<T: MDBXObject>(from table: MDBXTable) throws -> [T] {
    var results = [T]()
    
    os_signpost(.begin, log: readLogger, name: "fetchAll", "from table: %{private}@", table.rawValue)
    
    do {
      let transaction = MDBXTransaction(self.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      
      let db = try self.prepareTable(table: table, transaction: transaction, create: false)
      
      os_signpost(.event, log: readLogger, name: "fetchAll", "cursor prepared")
      
      let cursor = try self.prepareCursor(transaction: transaction, database: db)
      var key = Data()
      
      var hasNext = true
      while hasNext {
        do {
          let data: Data
          if key.isEmpty {
            data = try cursor.getValue(key: &key, operation: [.setLowerBound, .first])
          } else {
            data = try cursor.getValue(key: &key, operation: [.next])
          }
          
          let encoded = try self.decoder.decode(T.self, from: data)
          encoded.database = self
          results.append(encoded)
        } catch {
          hasNext = false
        }
      }
      
      os_signpost(.end, log: readLogger, name: "fetchAll", "done")
    } catch {
      os_signpost(.end, log: readLogger, name: "fetchAll", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
      throw error
    }
    
    return results
  }
  
  @available(*, renamed: "read()")
  func readAsync<T: MDBXObject>(key: MDBXKey, table: MDBXTable, completionBlock: @escaping (T?) -> Void) {
    read(key: key, table: table, completionBlock: completionBlock)
  }
  
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable, completionBlock: @escaping (T?) -> Void) {
    Task {
      do {
        let result: T? = try await read(key: key, table: table)
        completionBlock(result)
      } catch {
        completionBlock(nil)
      }
    }
  }
  
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable) async throws -> T? {
    return try _read(key: key, table: table, signpost: "readAsync")
  }
  
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable) throws -> T {
    return try _read(key: key, table: table, signpost: "read")
  }
  
  func fetchRange<T: MDBXObject>(startKey: MDBXKey, endKey: MDBXKey, table: MDBXTable) throws -> [T] {
    var results = [T]()
    
    os_signpost(.begin, log: readLogger, name: "fetchRange", "from table: %{private}@", table.rawValue)
    
    do {
      let transaction = MDBXTransaction(self.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      let db = try self.prepareTable(table: table, transaction: transaction, create: false)
      
      os_signpost(.event, log: readLogger, name: "fetchRange", "cursor prepared")
      let cursor = try self.prepareCursor(transaction: transaction, database: db)
      
      var key = startKey.key
      var endKey = endKey.key
      var hasNext = true
      while hasNext {
        do {
          let data: Data
          if results.isEmpty {
            data = try cursor.getValue(key: &key, operation: [.setLowerBound, .first])
          } else {
            data = try cursor.getValue(key: &key, operation: [.next])
          }
          
          if transaction.compare(a: &key, b: &endKey, database: db) > 0 {
            os_signpost(.end, log: readLogger, name: "fetchRange", "done")
            hasNext = false
            break
          }
          
          let encoded = try self.decoder.decode(T.self, from: data)
          encoded.database = self
          results.append(encoded)
        } catch {
          hasNext = false
        }
      }
      os_signpost(.end, log: readLogger, name: "fetchRange", "done")
    } catch {
      os_signpost(.end, log: readLogger, name: "fetchRange", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
      throw error
    }
    
    return results
  }
  
  func read(key: MDBXKey, table: MDBXTable) throws -> Data? {
    var result: Data?
    var readError: Error?
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: readLogger, name: "read", "from table: %{private}@", table.rawValue)
    }
    readWorker.sync {
      do {
        try self.readTransaction.renew()
        defer {
          try? self.readTransaction.reset()
        }
        let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
        var key = key.key
        if #available(iOS 12.0, *) {
          os_signpost(.event, log: readLogger, name: "read", "ready for read")
        }
        result = try self.readTransaction.getValue(for: &key, database: db)
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: readLogger, name: "read", "done")
        }
      } catch {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: readLogger, name: "read", "Error: %{private}@", error.localizedDescription)
        }
        os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
        readError = error
      }
    }
    
    if let error = readError {
      throw error
    }
    
    return result
  }

  // MARK: - Private
  
  private func _read<T: MDBXObject>(key: MDBXKey, table: MDBXTable, signpost: StaticString) throws -> T {
    var result: T!
    os_signpost(.begin, log: readLogger, name: signpost, "from table: %{private}@", table.rawValue)
    
    do {
      let transaction = MDBXTransaction(self.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      let db = try self.prepareTable(table: table, transaction: transaction, create: false)
      var key = key.key
      os_signpost(.event, log: readLogger, name: signpost, "ready for read")
      let data = try transaction.getValue(for: &key, database: db)
      result = try self.decoder.decode(T.self, from: data)
      result?.database = self
      os_signpost(.end, log: readLogger, name: signpost, "done")
    } catch {
      os_signpost(.end, log: readLogger, name: signpost, "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
      throw error
    }
    
    return result
  }
}
