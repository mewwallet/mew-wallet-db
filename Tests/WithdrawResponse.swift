
import Foundation
import XCTest
import SwiftProtobuf
@testable import mew_wallet_db

private let testJson = """
{
    "amount": "0",
    "final_amount": "0",
    "minimum_deposit": "0.00001355",
    "ren_fee_percentage": "0.001",
    "mew_fee_percentage": "0.01",
    "total_fee_percentage": "0.011",
    "transfer_fee": "0.000008"
}
"""

final class withdraw_response_tests: XCTestCase {
    
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
    
    private var withdrawResponseData: WithdrawResponse!
    private var db: MEWwalletDBImpl!
        
    override func setUp() {
        super.setUp()
        db = MEWwalletDBImpl(encoder: self.encoder, decoder: self.decoder)
        db.delete(databaseName: "test")
        
        guard let data = testJson.data(using: .utf8) else {
            XCTFail("Invalid json")
            return
        }
        
        do {
            try self.db.start(databaseName: "test", tables: MDBXTable.allCases)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            self.withdrawResponseData = try WithdrawResponse(jsonUTF8Data: data)
        } catch {
            XCTFail("withdraw response data error: \(error.localizedDescription)")
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        db.delete(databaseName: "test")
    }
    
    func test() {
        
        writeWithdrawResponse {
            self.db.commit(table: .withdrawResponse)
            let key = WithdrawResponseKey(projectId: .eth, id: "000000")
            self.db.readAsync(key: key, table: .withdrawResponse) { withdrawResponseData in
                guard let _ = withdrawResponseData else {
                    print("withdraw response data is error")
                    return
                }
            }
        }
        
    }
    
    private func writeWithdrawResponse(completionBlock: @escaping () -> Void) {

        let key = WithdrawResponseKey(projectId: .eth, id: "000000")

        guard let data = testJson.data(using: .utf8) else {
            XCTFail("Invalid json")
            return
        }
        
        db.writeAsync(table: .withdrawResponse, key: key, value: data) { success -> MDBXWriteAction in
            switch success {
            case true:
                debugPrint("================")
                debugPrint("Successful write (WithdrawResponse)")
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
