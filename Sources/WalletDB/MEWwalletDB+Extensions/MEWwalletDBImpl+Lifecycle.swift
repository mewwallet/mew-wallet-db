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
  func start(databaseName: String, tables: [MDBXTable]) throws {
    guard environment == nil else { return }
    
    let environment = MDBXEnvironment()
    try environment.create()
    try environment.setMaxReader(42)
    try environment.setMaxDatabases(42)
    
    let geometry = MDBXGeometry(
      sizeLower: -1,
      sizeNow: 1024 * 10,
      sizeUpper: 1024 * 1024 * 50,
      growthStep: 1024,
      shrinkThreshold: -1,
      pageSize: -1
    )
    #if DEBUG
    try environment.setHandleSlowReaders { (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
      os_log("===========", log: lifecycleLogger, type: .info)
      os_log("Slow reader", log: lifecycleLogger, type: .info)
      os_log("===========", log: lifecycleLogger, type: .info)
      return -1
    }
    #endif
    try environment.setGeometry(geometry)
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(databaseName).path
    
    os_log("Database path: %{private}@", log: lifecycleLogger, type: .info, path)
    
    try environment.open(path: path, flags: [.envDefaults, .noTLS], mode: .iOSPermission)
    self.environment = environment
    
    var success = true
    writeWorker.sync {
      let writeTransaction = MDBXTransaction(environment)

      do {
        try self.beginTransaction(transaction: writeTransaction)
        self.writeTransaction = writeTransaction
      } catch {
        os_log("Error of write transaction: %{private}@", log: lifecycleLogger, type: .error, error.localizedDescription)
        success = false
      }
    }
    
    readWorker.sync {
      let readTransaction = MDBXTransaction(environment)
      self.readTransaction = readTransaction
      do {
        try self.readTransaction.begin(flags: [.readOnlyPrepare])
      } catch {
        os_log("Error of read transaction: %{private}@", log: lifecycleLogger, type: .error, error.localizedDescription)
      }
    }
    
    guard success else {
      throw MEWwalletDBError.internalError
    }
  }
  
  func stop() {
    readWorker.stop()
    writeWorker.sync {
      do {
        try self.writeTransaction.abort()
      } catch {
        os_log("Error during %{private}@: %{private}@", log: lifecycleLogger, type: .error, error.localizedDescription)
      }
    }
    writeWorker.stop()
    self.environment.close(false)
  }
}
