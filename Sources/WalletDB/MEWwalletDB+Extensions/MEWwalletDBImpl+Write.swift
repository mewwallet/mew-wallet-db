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
  func writeAsync(table: MDBXTable, key: MDBXKey, value: Data, completionBlock: @escaping (Bool) -> MDBXWriteAction) {
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: writeLogger, name: "writeAsync of value", "to table: %{private}@", table.rawValue)
    }
    writeWorker.async { [weak self] in
      guard let self = self else {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of value", "aborted")
        }
        return
      }
      
      do {
        var key = key.key
        var value = value
        let db = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
        try self.writeTransaction.put(
          value: &value,
          forKey: &key,
          database: db,
          flags: [.upsert]
        )
        
        if #available(iOS 12.0, *) {
          os_signpost(.event, log: writeLogger, name: "writeAsync of value", "put finished")
        }
        
        let action = completionBlock(true)
        try self.process(writeAction: action, table: table)
        
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of value", "done")
        }
      } catch {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of value", "Error: %{private}@", error.localizedDescription)
        }
        os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
        _ = completionBlock(false)
      }
    }
  }
  
  func writeAsync(table: MDBXTable, key: MDBXKey, object: MDBXObject, completionBlock: @escaping (Bool) -> MDBXWriteAction) {
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: writeLogger, name: "writeAsync of Object", "to table: %{private}@", table.rawValue)
    }
    writeWorker.async { [weak self] in
      guard let self = self else {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of Object", "aborted")
        }
        return
      }
      
      do {
        var key = key.key
        var value = try self.encoder.encode(object)
        let db = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
        try self.writeTransaction.put(
          value: &value,
          forKey: &key,
          database: db,
          flags: [.upsert]
        )
        
        if #available(iOS 12.0, *) {
          os_signpost(.event, log: writeLogger, name: "writeAsync of object", "put finished")
        }
        
        let action = completionBlock(true)
        try self.process(writeAction: action, table: table)
        
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of object", "done")
        }
      } catch {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "writeAsync of object", "Error: %{private}@", error.localizedDescription)
        }
        os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
        _ = completionBlock(false)
      }
    }
  }
  
  func write<T: Encodable>(table: MDBXTable, key: MDBXKey, value: T) throws {
    try write(table: table, key: key, value: try encoder.encode(value))
  }
  
  func write(table: MDBXTable, key: MDBXKey, value: Data) throws {
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: writeLogger, name: "write of value", "to table: %{private}@", table.rawValue)
    }
    var writeError: Error?
    writeWorker.sync {
      do {
        var key = key.key
        var value = value
        let db = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
        try self.writeTransaction.put(
          value: &value,
          forKey: &key,
          database: db,
          flags: [.upsert]
        )
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "write of value", "done")
        }
      } catch {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "write of value", "Error: %{private}@", error.localizedDescription)
        }
        os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
        writeError = error
      }
    }
    if let error = writeError { throw error }
  }

  func writeIfNotExists<T: Encodable>(table: MDBXTable, key: MDBXKey, value: T) throws {
    try writeIfNotExists(table: table, key: key, value: try encoder.encode(value))
  }
  
  func writeIfNotExists(table: MDBXTable, key: MDBXKey, value: Data) throws {
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: writeLogger, name: "write of value if not exists", "to table: %{private}@", table.rawValue)
    }
    var writeError: Error?
    readWorker.sync { [weak self] in
      guard let self = self else { return }
      
      do {
        try self.readTransaction.renew()
        defer {
          try? self.readTransaction.reset()
        }
        let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
        var key = key.key
        if #available(iOS 12.0, *) {
          os_signpost(.event, log: writeLogger, name: "read", "ready for read")
        }
        let _ = try self.readTransaction.getValue(for: &key, database: db)
      } catch MDBXError.notFound {
        self.writeWorker.sync {
          do {
            var key = key.key
            var value = value
            let db = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
            try self.writeTransaction.put(
              value: &value,
              forKey: &key,
              database: db,
              flags: [.upsert]
            )
            if #available(iOS 12.0, *) {
              os_signpost(.end, log: writeLogger, name: "write of value", "done")
            }
          } catch {
            if #available(iOS 12.0, *) {
              os_signpost(.end, log: writeLogger, name: "write of value", "Error: %{private}@", error.localizedDescription)
            }
            os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
            writeError = error
          }
        }
      } catch {
        writeError = error
      }
    }
    if let error = writeError { throw error }

  }
  
  func commit(table: MDBXTable) {
    if #available(iOS 12.0, *) {
      os_signpost(.begin, log: writeLogger, name: "commit", "to table: %{private}@", table.rawValue)
    }
    
    writeWorker.sync { [weak self] in
      guard let self = self else {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "commit", "aborted")
        }
        return
      }
      
      do {
        let _ = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
        try self.writeTransaction.commit()
        if #available(iOS 12.0, *) {
          os_signpost(.event, log: writeLogger, name: "commit", "commited")
        }
        try self.beginTransaction(transaction: self.writeTransaction)
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "commit", "re-begin transaction")
        }
      } catch {
        if #available(iOS 12.0, *) {
          os_signpost(.end, log: writeLogger, name: "commit", "Error: %{private}@", error.localizedDescription)
        }
        os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
      }
    }
  }
  
  // MARK: - Private
  
  private func process(writeAction: MDBXWriteAction, table: MDBXTable) throws {
    switch writeAction {
    case .commit:
      commit(table: table)
    case .abort:
      try self.writeTransaction.abort()
    default: break
    }
  }
}
