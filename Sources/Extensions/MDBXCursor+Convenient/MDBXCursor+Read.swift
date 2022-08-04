//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mdbx_ios

extension MDBXCursor {
  func fetch(range: MDBXKeyRange, from database: MDBXDatabase) throws -> [(Data, Data)] {
    let transaction = try self.transaction
    
    let isRange = range.end != nil
    
    var results: [(Data, Data)] = []
    var key = range.start?.key ?? Data()
    var endKey = range.end?.key ?? Data()
    
    var hasNext = true
    while hasNext {
      do {
        let data: (Data, Data)
        if results.isEmpty || key.isEmpty {
          let value = try self.getValue(key: &key, operation: [.setLowerBound, .first])
          data = (key, value)
        } else {
          let value = try self.getValue(key: &key, operation: [.next])
          data = (key, value)
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
  
  func fetchKeys(range: MDBXKeyRange, from database: MDBXDatabase) throws -> [Data] {
    let transaction = try self.transaction
    
    let isRange = range.end != nil
    
    var results: [Data] = []
    var key = range.start?.key ?? Data()
    var endKey = range.end?.key ?? Data()
    
    var hasNext = true
    while hasNext {
      do {
        let data: Data
        if results.isEmpty || key.isEmpty {
          _ = try self.getValue(key: &key, operation: [.setLowerBound, .first])
          data = key
        } else {
          _ = try self.getValue(key: &key, operation: [.next])
          data = key
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
