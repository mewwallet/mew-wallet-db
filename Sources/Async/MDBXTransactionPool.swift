//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/11/21.
//

import Foundation
import mdbx_ios

enum Static {
  static let mdbxTransactionKey = "mdbxTransaction"
}

final class MDBXTransactionPool {
  let environment: MDBXEnvironment
  
  init(environment: MDBXEnvironment) {
    self.environment = environment
  }
  
  func readTransactionForCurrentThread() throws -> MDBXTransaction {
    let threadDict = Thread.current.threadDictionary
    if let transaction = threadDict[Static.mdbxTransactionKey] as? MDBXTransaction {
      try transaction.renew()
      return transaction
    }
    
    let transaction = MDBXTransaction(environment)
    threadDict.setObject(transaction, forKey: Static.mdbxTransactionKey as NSString)

    return transaction
  }

}
