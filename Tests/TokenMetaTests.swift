//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/4/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import MEWextensions
import SwiftProtobuf

private let testJson = """
[
  {
    "contract_address":"0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "price":"2629.93",
    "volume_24h":"13636411006",
    "name":"Ethereum",
    "symbol":"ETH",
    "icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
    "decimals":18,
    "timestamp":"2022-03-05T06:10:15.445Z",
    "sparkline": [
      "2668.38", "2671.82", "2668.75", "2660.89", "2667.53", "2670.15", "2665.54", "2668.71", "2676.91", "2674.32",
      "2673.37", "2672.3", "2666.46", "2664.43", "2668.36", "2669.24", "2661.75", "2651.5", "2633.63", "2664.01",
      "2656.92", "2655.48", "2656.53", "2655.67", "2657.16", "2650.89", "2651.79", "2652.02", "2646.36", "2644.13",
      "2640", "2625.39", "2620.6", "2599.88", "2607.24", "2603.44", "2605.45", "2609.75", "2612.87", "2618.88",
      "2625.4", "2644", "2644.31", "2637.2", "2632.19", "2629.64", "2624.67", "2628.58", "2646.43", "2644.19",
      "2638.41", "2635.22", "2635.09", "2639.07", "2634.42", "2626.58", "2628.29", "2617.45", "2615.83", "2622.89",
    ]
  },
  {
    "contract_address":"0x00c17f958d2ee523a2206206994597c13d831ec7",
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
  },
  {
    "contract_address":"0x00ad61b0a150d79219dcf64e1e6cc01f0b64c4ce",
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

private let projectId = "0x00"

final class TokenMeta_tests: XCTestCase {
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
  
  func test() {
    let expectation = XCTestExpectation()
    Task {
      do {
        let objects = try TokenMeta.array(fromJSONString: testJson, chain: .eth)
        let keysAndObjects: [(MDBXKey, MDBXObject)] = objects.lazy.map ({
          return ($0.key, $0)
        })
        try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
        try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects, mode: [.append, .changes])
        
        let dexItem = DexItem(chain: MDBXChain(rawValue: Data(hex: "0x1")), contractAddress: "0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", order: 0)
        let dexItem2 = DexItem(chain: .eth, contractAddress: "0x00c17f958d2ee523a2206206994597c13d831ec7", order: 2)
        let dexItem3 = DexItem(chain: .eth, contractAddress: "0x00aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE", order: 1)
        
        try await db.write(table: .orderedDex, keysAndObjects: [
          (dexItem.alternateKey!, dexItem),
          (dexItem2.alternateKey!, dexItem2),
          (dexItem3.alternateKey!, dexItem3)
        ], mode: .append)
        
        try await db.write(table: .dex, keysAndObjects: [
          (dexItem.key, dexItem),
          (dexItem2.key, dexItem2),
          (dexItem3.key, dexItem3)
        ], mode: .append)
        
        let dexes: [DexItem] = try db.fetchAll(from: .orderedDex)
        let metas = dexes.map({$0.alternateKey?.key.chain})
        
        var dex = try dexItem.meta.dexItem.meta.dexItem
        dex.order = 0
      } catch {
        debugPrint(error)
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testKey() {
    let tokenKey = TokenKey(chain: .eth, address: "0x112233445566778899aabbccddeeff0011223344", contractAddress: "0x5566778899aabbccddeeff001122334455667788")
    XCTAssertEqual(tokenKey.address, "0x112233445566778899aabbccddeeff0011223344")
    XCTAssertEqual(tokenKey.contractAddress, "0x5566778899aabbccddeeff001122334455667788")
    XCTAssertEqual(tokenKey.key.hexString, "0x00000000000000000000000000000001112233445566778899aabbccddeeff00112233445566778899aabbccddeeff001122334455667788")
  }
}
