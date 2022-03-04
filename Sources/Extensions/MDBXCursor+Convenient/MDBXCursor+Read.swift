//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mdbx_ios

extension MDBXCursor {
  func fetchAll(from database: MDBXDatabase) throws -> [Data] {
    try self.fetchRange(startKey: nil, endKey: nil, from: database)
  }
  
  func fetchRange(startKey: MDBXKey?, endKey: MDBXKey?, from database: MDBXDatabase) throws -> [Data] {
    let transaction = try self.transaction
    
    let isRange = endKey != nil
    
    var results: [Data] = []
    var key = startKey?.key ?? Data()
    var endKey = endKey?.key ?? Data()
    
    var hasNext = true
    while hasNext {
      do {
        let data: Data
        if results.isEmpty || key.isEmpty {
          data = try self.getValue(key: &key, operation: [.setLowerBound, .first])
        } else {
          data = try self.getValue(key: &key, operation: [.next])
        }
        
        if isRange {
          if transaction.compare(a: &key, b: &endKey, database: database) > 0 {
            hasNext = false
            break
          }
        }
        
        results.append(data)
      } catch {
        hasNext = false
      }
    }
    return results
  }
}
