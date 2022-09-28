//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mdbx_ios

extension MDBXCursor {
  func fetch(range: MDBXKeyRange, from database: MDBXDatabase, order: MDBXReadOrder) throws -> [(Data, Data)] {
    let transaction = try self.transaction
    
    let isRange = range.isRange
    
    var results: [(Data, Data)] = []
    let limit = range.limit ?? 0
    
    var key: Data
    var endKey: Data
    var stepOperation: MDBXCursorOperations
    var compare: (inout Data, inout Data, MDBXDatabase) -> Bool
    switch order {
    case .asc:
      // Prepare parameters
      key = range.start?.key ?? Data()
      endKey = range.end?.key ?? Data()
      stepOperation = .next
      compare = { key, endKey, database in
        return transaction.compare(a: &key, b: &endKey, database: database) > 0
      }
      
      // Do first read
      var data: (Data, Data)
      do {
        let value = try self.getValue(key: &key, operation: .setLowerBound)
        data = (key, value)
      } catch MDBXError.notFound {
        return []
      }
      
      // Check for range
      if isRange {
        guard !compare(&key, &endKey, database) else {
          return results
        }
      }
      results.append(data)

      // Check for limit
      if limit != 0,
         limit == results.count {
        return results
      }
    case .desc:
      // Prepare parameters
      key = range.end?.key ?? Data()
      endKey = range.start?.key ?? Data()
      stepOperation = .prev
      compare = { key, endKey, database in
        return transaction.compare(a: &key, b: &endKey, database: database) < 0
      }
      
      // Do first read
      var data: (Data, Data)
      do {
        let value = try self.getValue(key: &key, operation: .set)
        data = (key, value)
      } catch MDBXError.notFound {
        do {
          let value = try self.getValue(key: &key, operation: .prev)
          data = (key, value)
        } catch {
          return []
        }
      }
      
      // Check for range
      if isRange {
        guard !compare(&key, &endKey, database) else {
          return results
        }
      }
      results.append(data)

      // Check for limit
      if limit != 0,
         limit == results.count {
        return results
      }
    }
    
    var counter: UInt = UInt(clamping: results.count)
    var hasNext = true
    while hasNext {
      do {
        let data: (Data, Data)
        let value = try self.getValue(key: &key, operation: stepOperation)
        data = (key, value)
        
        if isRange {
          if compare(&key, &endKey, database) {
            hasNext = false
            break
          }
        }
        
        results.append(data)
        counter += 1
        
        if limit != 0,
           limit == counter {
          hasNext = false
          break
        }
      } catch {
        hasNext = false
      }
    }
    return results
  }
  
  func fetchKeys(range: MDBXKeyRange, from database: MDBXDatabase, order: MDBXReadOrder) throws -> [Data] {
    let transaction = try self.transaction
    
    let isRange = range.isRange
    var results: [Data] = []
    let limit = range.limit ?? 0
    
    var key: Data
    var endKey: Data
    var stepOperation: MDBXCursorOperations
    var compare: (inout Data, inout Data, MDBXDatabase) -> Bool
    
    switch order {
    case .asc:
      // Prepare parameters
      key = range.start?.key ?? Data()
      endKey = range.end?.key ?? Data()
      stepOperation = .next
      compare = { key, endKey, database in
        return transaction.compare(a: &key, b: &endKey, database: database) > 0
      }
      
      // Do first read
      var data: Data
      do {
        _ = try self.getValue(key: &key, operation: .setLowerBound)
        data = key
      } catch MDBXError.notFound {
        return []
      }
      
      // Check for range
      if isRange {
        guard !compare(&key, &endKey, database) else {
          return results
        }
      }
      results.append(data)

      // Check for limit
      if limit != 0,
         limit == results.count {
        return results
      }
    case .desc:
      // Prepare parameters
      key = range.end?.key ?? Data()
      endKey = range.start?.key ?? Data()
      stepOperation = .prev
      compare = { key, endKey, database in
        return transaction.compare(a: &key, b: &endKey, database: database) < 0
      }
      
      // Do first read
      var data: Data
      do {
        _ = try self.getValue(key: &key, operation: .set)
        data = key
      } catch MDBXError.notFound {
        do {
          _ = try self.getValue(key: &key, operation: .prev)
          data = key
        } catch {
          return []
        }
      }
      
      // Check for range
      if isRange {
        guard !compare(&key, &endKey, database) else {
          return results
        }
      }
      results.append(data)

      // Check for limit
      if limit != 0,
         limit == results.count {
        return results
      }
    }
    
    var counter: UInt = 0
    var hasNext = true
    while hasNext {
      do {
        let data: Data
        
        _ = try self.getValue(key: &key, operation: stepOperation)
        data = key
        
        if isRange {
          if compare(&key, &endKey, database) {
            hasNext = false
            break
          }
        }
        
        results.append(data)
        counter += 1
        
        if limit != 0,
           limit == counter {
          hasNext = false
          break
        }
      } catch {
        hasNext = false
      }
    }
    return results
  }
}
