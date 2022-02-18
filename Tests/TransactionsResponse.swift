
import Foundation
import XCTest
import SwiftProtobuf
@testable import mew_wallet_db

private let testJson = """
{
"transactions": [
  {
    "hash": "0x977e290e33ae303490f4812622c1f0bd3e01722cc72a925eebc3d1b05f41fb47",
    "address": "0x4c572fbc03d4a2b683cf4f10ffdcafd00885e108",
    "contract_address": "0x4c572fbc03d4a2b683cf4f10ffdcafd00885e108",
    "type": "TRANSFER",
    "balance": "0x2386f26fc10000",
    "delta": "0x2386f26fc10000",
    "from": "0x4c572fbc03d4a2b683cf4f10ffdcafd00885e108",
    "to": "0x4c572fbc03d4a2b683cf4f10ffdcafd00885e108",
    "block_hash": "0x977e290e33ae303490f4812622c1f0bd3e01722cc72a925eebc3d1b05f41fb47",
    "block_number": 6548234,
    "status": "PENDING",
    "timestamp": "2019-10-10T20:37:01.000Z",
    "nonce": 1
  }
]
}
"""

final class transactions_response_tests: XCTestCase {
    
    private lazy var df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
        return df
    }()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(self.df)
        return decoder
    }()
    
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(self.df)
        return encoder
    }()
    
    private var db: MEWwalletDBImpl!
    private let table: MDBXTable = .transactionsHistoryResponse
    
    override func setUp() {
        super.setUp()
        db = MEWwalletDBImpl(encoder: self.encoder, decoder: self.decoder)
        db.delete(databaseName: "test")
                
        do {
            try self.db.start(databaseName: "test", tables: MDBXTable.allCases)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        db.delete(databaseName: "test")
    }
    
    func test() {
        
        guard let data = testJson.data(using: .utf8) else {
            XCTFail("Invalid json")
            return
        }

        guard let transactionsHistoryResponse = try? TransactionsHistoryResponse(jsonUTF8Data: data) else {
            XCTFail("serialise data error")
            return
        }
        
        writeToDB(items: transactionsHistoryResponse.transactions) {
            self.db.commit(table: self.table)
            
            for item in transactionsHistoryResponse.transactions {
                let key = TransactionsHistoryResponseKey(projectId: .eth, id: item.hash)
                guard let data = try? self.db.read(key: key, table: self.table) else {
                    XCTFail("withdraw response read data error")
                    return
                }
                
                guard let  transactionPBData_ = try? TransactionPB(jsonUTF8Data: data) else {
                    XCTFail("withdraw response serialize to json data error")
                    return
                }
                    
                guard transactionPBData_.hash == item.hash else {
                    XCTFail("Invalid withdraw response data")
                    return
                }
            }
        }
        
    }
    
    private func writeToDB(items: [TransactionPB], completionBlock: @escaping () -> Void) {

        guard let data = testJson.data(using: .utf8) else {
            XCTFail("Invalid json")
            return
        }
        
        for item in items {
            let key = TransactionsHistoryResponseKey(projectId: .eth, id: item.hash)
            db.writeAsync(table: self.table, key: key, value: data) { success -> MDBXWriteAction in
                switch success {
                case true:
                    debugPrint("================")
                    debugPrint("Successful write tx with hash: \(item.hash)")
                    debugPrint("================")
                    completionBlock()
                case false:
                    completionBlock()
                    XCTFail("Failed to write data")
                    
                }
                return .none
            }
        }

    }

}
