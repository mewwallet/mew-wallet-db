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
        var readError: Error?
        
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log: readLogger, name: "fetchAll", "from table: %{private}@", table.rawValue)
        }
        
        readWorker.sync {
            do {
                try self.readTransaction.renew()
                defer {
                    try? self.readTransaction.reset()
                }
                let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
                
                if #available(iOS 12.0, *) {
                    os_signpost(.event, log: readLogger, name: "fetchAll", "cursor prepared")
                }
                let cursor = try self.prepareCursor(transaction: self.readTransaction, database: db)
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
                
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "fetchAll", "done")
                }
            } catch {
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "fetchAll", "Error: %{private}@", error.localizedDescription)
                }
                os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
                readError = error
            }
        }
        
        if let error = readError {
            throw error
        }
        
        return results
    }
    
    
    func readAsync<T: MDBXObject>(key: MDBXKey, table: MDBXTable, completionBlock: @escaping (T?) -> Void) {
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log: readLogger, name: "readAsync", "from table: %{private}@", table.rawValue)
        }
        readWorker.async {[weak self] in
            guard let self = self else {
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "readAsync", "aborted")
                }
                return
            }
            do {
                try self.readTransaction.renew()
                defer {
                    try? self.readTransaction.reset()
                }
                let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
                var key = key.key
                if #available(iOS 12.0, *) {
                    os_signpost(.event, log: readLogger, name: "readAsync", "ready for read")
                }
                let data = try self.readTransaction.getValue(for: &key, database: db)
                let result = try self.decoder.decode(T.self, from: data)
                result.database = self
                
                completionBlock(result)
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "readAsync", "done")
                }
            } catch {
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "readAsync", "Error: %{private}@", error.localizedDescription)
                }
                os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
                completionBlock(nil)
            }
        }
    }
    
    func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable) throws -> T {
        var result: T!
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
                let data = try self.readTransaction.getValue(for: &key, database: db)
                result = try self.decoder.decode(T.self, from: data)
                result?.database = self
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
    
    func fetchRange<T: MDBXObject>(startKey: MDBXKey, endKey: MDBXKey, table: MDBXTable) throws -> [T] {
        var results = [T]()
        var readError: Error?
        
        if #available(iOS 12.0, *) {
            os_signpost(.begin, log: readLogger, name: "fetchRange", "from table: %{private}@", table.rawValue)
        }
        
        readWorker.sync {
            do {
                try self.readTransaction.renew()
                defer {
                    try? self.readTransaction.reset()
                }
                let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
                
                if #available(iOS 12.0, *) {
                    os_signpost(.event, log: readLogger, name: "fetchRange", "cursor prepared")
                }
                let cursor = try self.prepareCursor(transaction: self.readTransaction, database: db)
                
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
                        
                        if self.readTransaction.compare(a: &key, b: &endKey, database: db) > 0 {
                            if #available(iOS 12.0, *) {
                                os_signpost(.end, log: readLogger, name: "fetchRange", "done")
                            }
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
                
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "fetchRange", "done")
                }
            } catch {
                if #available(iOS 12.0, *) {
                    os_signpost(.end, log: readLogger, name: "fetchRange", "Error: %{private}@", error.localizedDescription)
                }
                os_log("Error: %{private}@", log: readLogger, type: .error, error.localizedDescription)
                readError = error
            }
        }
        
        if let error = readError {
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
    
    // TODO: Works for duplicate only, not in use atm
    /*
     func count(in table: MDBXTable) throws -> Int {
     var count: Int = 0
     var readError: Error?
     
     readWorker.sync {
     do {
     try self.readTransaction.renew()
     defer {
     try? self.readTransaction.reset()
     }
     let db = try self.prepareTable(table: table, transaction: self.readTransaction, create: false)
     
     let cursor = try self.prepareCursor(transaction: self.readTransaction, database: db)
     var key = Data()
     _ = try cursor.getValue(key: &key, operation: [.setLowerBound])
     count = try cursor.count()
     } catch {
     readError = error
     }
     }
     
     if let error = readError {
     throw error
     }
     
     return count
     }
     */
}
