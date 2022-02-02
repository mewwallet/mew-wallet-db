//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios

public extension MEWwalletDBImpl {
  func beginWriteTransaction() throws {
    var resultError: Error?
    writeWorker.sync {
      do {
        try self.beginTransaction(transaction: self.writeTransaction, readonly: false, flags: [])
      } catch {
        resultError = error
      }
    }
    if let error = resultError {
      throw error
    }
  }
  
  func beginTransaction(transaction: MDBXTransaction, readonly: Bool = false, flags: MDBXTransactionFlags = []) throws {
    try transaction.begin(flags: flags)
  }
  
  func prepareCursor(transaction: MDBXTransaction, database: MDBXDatabase) throws -> MDBXCursor {
    let cursor = MDBXCursor()
    try cursor.open(transaction: transaction, database: database)
    
    return cursor
  }
  
  func delete(databaseName: String) {
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(databaseName).path
    try? FileManager.default.removeItem(atPath: path)
  }

}
