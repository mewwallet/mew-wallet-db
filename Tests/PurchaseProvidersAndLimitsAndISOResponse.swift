
import Foundation
import XCTest
import SwiftProtobuf
@testable import mew_wallet_db

private let testJson = """
[
{
    "name": "MOONPAY",
    "fiat_currencies": ["USD","RUB","EUR","JPY","AUD","CAD","GBP"],
    "crypto_currencies": ["ETH"],
    "ach": false,
    "prices": [{"fiat_currency": "GBP", "crypto_currency": "ETH", "price": "2362.48505"}, {"fiat_currency": "EUR", "crypto_currency": "ETH", "price": "2362.48505"}],
    "limits": [{"type": "WEB", "fiat_currency": "AUD", "limit": {"min": "50", "max": "16000"}}],
    "conversion_rates": [{"fiat_currency": "GBP", "exchange_rate": "0.7362549990589432"}, {"fiat_currency": "EUR", "exchange_rate": "0.8776798959474532"}, {"fiat_currency": "USD", "exchange_rate": "1"}]
},
{
    "name": "SIMPLEX",
    "fiat_currencies": ["USD","RUB","EUR","JPY","AUD","CAD","GBP"],
    "crypto_currencies": ["ETH"],
    "ach": false,
    "prices": [{"fiat_currency": "GBP", "crypto_currency": "ETH", "price": "2362.48505"}, {"fiat_currency": "EUR", "crypto_currency": "ETH", "price": "2362.48505"}],
    "limits": [{"type": "WEB", "fiat_currency": "AUD", "limit": {"min": "50", "max": "16000"}}],
    "conversion_rates": [{"fiat_currency": "GBP", "exchange_rate": "0.7362549990589432"}, {"fiat_currency": "EUR", "exchange_rate": "0.8776798959474532"}, {"fiat_currency": "USD", "exchange_rate": "1"}]
},
{
    "name": "WYRE",
    "fiat_currencies": ["USD","RUB","EUR","JPY","AUD","CAD","GBP"],
    "crypto_currencies": ["ETH"],
    "ach": false,
    "prices": [{"fiat_currency": "GBP", "crypto_currency": "ETH", "price": "2362.48505"}, {"fiat_currency": "EUR", "crypto_currency": "ETH", "price": "2362.48505"}],
    "limits": [{"type": "WEB", "fiat_currency": "AUD", "limit": {"min": "50", "max": "16000"}}],
    "conversion_rates": [{"fiat_currency": "GBP", "exchange_rate": "0.7362549990589432"}, {"fiat_currency": "EUR", "exchange_rate": "0.8776798959474532"}, {"fiat_currency": "USD", "exchange_rate": "1"}]
}
]
"""


final class purchas_providers_limits_iso_response_tests: XCTestCase {
    
    private lazy var df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
        return df
    }()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    
    private var purchaseProvidersAndLimitsAndISOResponseData: PurchaseProvidersAndLimitsAndISOResponse!
    private var db: MEWwalletDBImpl!
    private let key = PurchaseProvidersAndLimitsAndISOResponseKey(projectId: .eth, id: "000000")
    
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
            self.purchaseProvidersAndLimitsAndISOResponseData = try PurchaseProvidersAndLimitsAndISOResponse(jsonUTF8Data: data)
        } catch {
            XCTFail("providers response data error: \(error.localizedDescription)")
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        db.delete(databaseName: "test")
    }
    
    func test() {
        
        writeToDB {
            self.db.commit(table: .providersPBDResponse)
            self.db.readAsync(key: self.key, table: .providersPBDResponse) { withdrawResponseData in
                guard let _ = withdrawResponseData else {
                    print("providers response data is error")
                    return
                }
            }
        }
        
    }
    
    private func writeToDB(completionBlock: @escaping () -> Void) {

        guard let data = testJson.data(using: .utf8) else {
            XCTFail("Invalid json")
            return
        }
        
        db.writeAsync(table: .providersPBDResponse, key: key, value: data) { success -> MDBXWriteAction in
            switch success {
            case true:
                debugPrint("================")
                debugPrint("Successful write (ProvidersResponse)")
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
