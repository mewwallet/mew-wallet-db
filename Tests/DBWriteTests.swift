//
//  File.swift
//
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf
import mdbx_ios

private let testJson = """
[
  {
    "contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "price":"2629.93",
    "volume_24h":"13636411006",
    "name":"Ethereum",
    "symbol":"ETH",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
    "decimals":18,
    "timestamp":"2022-03-05T06:10:15.445Z"
  },
  {
    "contract_address":"0xdac17f958d2ee523a2206206994597c13d831ec7",
    "price":"1.002",
    "volume_24h":"53291079872",
    "name":"Tether",
    "symbol":"USDT",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdAC17F958D2ee523a2206206994597C13D831ec7-eth.png",
    "decimals":6,
    "timestamp":"2022-03-05T06:07:12.814Z"
  },
  {
    "contract_address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "price":"1.001",
    "volume_24h":"3650640928",
    "name":"USD Coin",
    "symbol":"USDC",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48-eth.png",
    "decimals":6,
    "timestamp":"2022-03-05T06:10:35.250Z"
  },
  {
    "contract_address":"0x4fabb145d64652a948d72533023f6e7a623c7c53",
    "price":"1.002",
    "volume_24h":"3371353985",
    "name":"Binance USD",
    "symbol":"BUSD",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/BUSD-0x4Fabb145d64652a948d72533023f6E7A623C7C53-eth.png",
    "decimals":18,
    "timestamp":"2022-03-05T06:10:12.325Z"
  }
]
"""

private let testJson2 = """
[
  {
    "contract_address":"0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce",
    "price":"0.00002416",
    "volume_24h":"627052736",
    "name":"Shiba Inu",
    "symbol":"SHIB",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/SHIB-0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE-eth.png",
    "decimals":18,
    "timestamp":"2022-03-05T06:10:11.907Z"
  }
]
"""

private let testJson3 = """
[
  {
    "contract_address":"0xdac17f958d2ee523a2206206994597c13d831ec7",
    "price":"1.002",
    "volume_24h":"53291079872",
    "name":"Tether",
    "symbol":"USDT",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdAC17F958D2ee523a2206206994597C13D831ec7-eth.png",
    "decimals":6,
    "timestamp":"2022-03-05T06:07:12.814Z"
  },
  {
    "contract_address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "price":"1.000",
    "volume_24h":"3650640928",
    "name":"USD Coin",
    "symbol":"USDC",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48-eth.png",
    "decimals":6,
    "timestamp":"2022-03-05T06:10:35.250Z"
  },
  {
    "contract_address":"0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce",
    "price":"0.10002416",
    "volume_24h":"627052736",
    "name":"Shiba Inu",
    "symbol":"SHIB",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/SHIB-0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE-eth.png",
    "decimals":18,
    "timestamp":"2022-03-05T06:10:11.907Z"
  }
]
"""

final class DBWrite_tests: XCTestCase {
  private var db: MEWwalletDBImpl!
  
  lazy private var _path: String = {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db")
    return url.path
  }()
  
  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)

    try! db.start(path: self._path, tables: MDBXTableName.allCases)
  }
  
  override func tearDown() {
    super.tearDown()
    
    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func testWriteModes() {
    let expectation = XCTestExpectation()
    Task {
      do {
        let set0 = try TokenMeta.array(fromJSONString: testJson, chain: .eth).map { ($0.key, $0 ) } // all new
        let set1 = try TokenMeta.array(fromJSONString: testJson2, chain: .eth).map { ($0.key, $0 ) } // extra new
        let set2 = try TokenMeta.array(fromJSONString: testJson3, chain: .eth).map { ($0.key, $0 ) } // from set0 - equal + changed
        let set0_2 = set0 + set2
        let set3 = set0 + set2 // all new + equal + changed
        
        let allNew = set0 + set1
        
        XCTAssertEqual(set0.count, 4)
        XCTAssertEqual(set1.count, 1)
        XCTAssertEqual(set2.count, 3)
        XCTAssertEqual(set0_2.count, 7)
        XCTAssertEqual(set3.count, 7)
        XCTAssertEqual(allNew.count, 5)
        
        let mode22: DBWriteMode = [.append, .override]
        
        debugPrint(mode22)
        
        // APPEND
        var count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append])
        var fetched: [TokenMeta] = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        count = try await db.write(table: .tokenMeta, keysAndObjects: allNew, mode: [.append])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(fetched.count, 5)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // APPEND + OVERRIDE
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append, .override])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        count = try await db.write(table: .tokenMeta, keysAndObjects: allNew, mode: [.append, .override])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 5)
        XCTAssertEqual(fetched.count, 5)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // APPEND + CHANGES
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append, .changes])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        count = try await db.write(table: .tokenMeta, keysAndObjects: allNew, mode: [.append, .changes])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(fetched.count, 5)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // OVERRIDE
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.override])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 0)
        XCTAssertEqual(fetched.count, 0)
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        count = try await db.write(table: .tokenMeta, keysAndObjects: allNew, mode: [.override])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // CHANGES + OVERRIDE
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0_2, mode: [.append])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 5)
        XCTAssertEqual(fetched.count, 5)
        XCTAssertEqual(set2.count, 3)
        count = try await db.write(table: .tokenMeta, keysAndObjects: set2, mode: [.override, .changes])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(fetched.count, 5)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // APPEND + CHANGES + OVERRIDE
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append, .changes, .override])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        XCTAssertEqual(set3.count, 7)
        count = try await db.write(table: .tokenMeta, keysAndObjects: set3, mode: [.append, .override, .changes])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(fetched.count, 5)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // DIFF + APPEND
        count = try await db.write(table: .tokenMeta, keysAndObjects: set2, mode: [.append, .diff(range: .all)])
        XCTAssertEqual(count, 3)
        count = try await db.write(table: .tokenMeta, keysAndObjects: set1, mode: [.append, .diff(range: .with(start: TokenMetaKey(chain: .eth, contractAddress: .primary), end: nil))])
        XCTAssertEqual(count, 3)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 1)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        // CHANGES
        do {
          try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.changes])
          XCTFail()
        } catch {
          XCTAssertEqual(error as? DBWriteError, DBWriteError.badMode)
        }
      } catch {
        XCTFail(error.localizedDescription)
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testDrop() {
    let expectation = XCTestExpectation()
    Task {
      do {
        let set0 = try TokenMeta.array(fromJSONString: testJson, chain: .eth).map { ($0.key, $0 ) } // all new
        
        // APPEND
        var count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append])
        var fetched: [TokenMeta] = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        
        try await db.drop(table: .tokenMeta, delete: false)
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(fetched.count, 0)
        
        try await db.drop(table: .tokenMeta, delete: true)
        
        do {
          fetched = try db.fetch(range: .all, from: .tokenMeta)
        } catch {
          func rethrow() throws {
            throw error
          }
          XCTAssertThrowsError(try rethrow()) { error in
            XCTAssertEqual(error as? MDBXError, MDBXError.notFound)
          }
        }
        
        try await db.recover(table: .tokenMeta)
        do {
          try await db.recover(table: .tokenMeta)
        } catch {
          XCTAssertEqual(error as? MDBXError, MDBXError.keyExist)
        }
        
        count = try await db.write(table: .tokenMeta, keysAndObjects: set0, mode: [.append])
        fetched = try db.fetch(range: .all, from: .tokenMeta)
        XCTAssertEqual(count, 4)
        XCTAssertEqual(fetched.count, 4)
        
        try await db.drop(table: .tokenMeta, delete: true)
        do {
          try await db.drop(table: .tokenMeta, delete: true)
        } catch {
          XCTAssertEqual(error as? MDBXError, MDBXError.notFound)
        }
      } catch {
        XCTFail(error.localizedDescription)
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
}
