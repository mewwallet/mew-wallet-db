//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/4/22.
//

import Foundation
import Testing
@testable import mew_wallet_db
import mew_wallet_ios_extensions
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
      "2638.41", "2635.22", "2635.09", "2639.07", "2634.42", "2626.58", "2628.29", "2617.45", "2615.83", "2622.89"
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
      "contract_address":"0xeb4c2781e4eba804ce9a9803c67d0893436bb27d",
      "price":"1.002",
      "volume_24h":"53291079872",
      "name":"RenBTC",
      "symbol":"renBTC",
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

@Suite("TokenMeta tests")
fileprivate final class TokenMetaTests {
  private var db: MEWwalletDBImpl!
  private let _path: String
  
  init() async throws {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db-\(UUID().uuidString)")
    self._path = url.path
    
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)

    try! db.start(path: self._path, tables: MDBXTableName.allCases, readOnly: false)
  }
  
  deinit {
    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  @Test("Token meta with dexes")
  func tokenMetaWithDexes() async throws {
    let objects = try TokenMeta.array(fromJSONString: testJson, chain: .eth)
    let keysAndObjects: [(any MDBXKey, any MDBXObject)] = objects.lazy.map ({
      return ($0.key, $0)
    })
    try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
    try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects, mode: [.append, .changes])
    
    let dexItem = DexItem(chain: MDBXChain(rawValue: Data(hex: "0x1")), contractAddress: "0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",name: "name", symbol: "symbol", order: 0, crosschain: false)
    let dexItem2 = DexItem(chain: .eth, contractAddress: "0x00c17f958d2ee523a2206206994597c13d831ec7", name: "name", symbol: "symbol", order: 2, crosschain: false)
    let dexItem3 = DexItem(chain: .eth, contractAddress: "0x00aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE", name: "name", symbol: "symbol",order: 1, crosschain: false)
    
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
    
    var dex = try dexItem.meta.dexItem.meta.dexItem
    dex.order = 0
    
    let renBTC: TokenMeta = try db.read(key: TokenMetaKey(chain: .eth, contractAddress: .renBTC), table: .tokenMeta)
    #expect(renBTC.contract_address == .renBTC)
  }
  
  @Test("Token meta ranges")
  func tokenMetaRanges() async throws {
    let objects1: [TokenMeta] = [
      .init(chain: .eth, contractAddress: Address("0x0000000000000000000000000000000000000000")),
      .init(chain: .eth, contractAddress: Address("0x1111111111111111111111111111111111111111")),
      .init(chain: .eth, contractAddress: Address("0x2222222222222222222222222222222222222222")),
      .init(chain: .eth, contractAddress: Address("0x3333333333333333333333333333333333333333")),
      .init(chain: .eth, contractAddress: Address("0x4444444444444444444444444444444444444444")),
      .init(chain: .eth, contractAddress: Address("0x5555555555555555555555555555555555555555")),
    ]
    let objects2: [TokenMeta] = [
      .init(chain: .arbitrum, contractAddress: Address("0x0000000000000000000000000000000000000000")),
      .init(chain: .arbitrum, contractAddress: Address("0x1111111111111111111111111111111111111111")),
      .init(chain: .arbitrum, contractAddress: Address("0x2222222222222222222222222222222222222222")),
      .init(chain: .arbitrum, contractAddress: Address("0x3333333333333333333333333333333333333333")),
      .init(chain: .arbitrum, contractAddress: Address("0x4444444444444444444444444444444444444444")),
      .init(chain: .arbitrum, contractAddress: Address("0x5555555555555555555555555555555555555555")),
    ]
    let keysAndObjects1: [(any MDBXKey, any MDBXObject)] = objects1.lazy.map({
      return ($0.key, $0)
    })
    let keysAndObjects2: [(any MDBXKey, any MDBXObject)] = objects2.lazy.map({
      return ($0.key, $0)
    })
    try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects1, mode: [.append, .changes, .override])
    try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects2, mode: [.append, .changes, .override])
    
    let readAll: [TokenMeta] = try db.fetch(range: .all, from: .tokenMeta, order: .asc)
    #expect(readAll.count == 12)
    
    let range1 = TokenMetaKey.range(chain: .eth)
    let readRange1: [TokenMeta] = try db.fetch(range: range1, from: .tokenMeta, order: .asc)
    let range2 = TokenMetaKey.range(chain: .arbitrum)
    let readRange2: [TokenMeta] = try db.fetch(range: range2, from: .tokenMeta, order: .asc)
    let range3 = TokenMetaKey.range(chain: .base)
    let readRange3: [TokenMeta] = try db.fetch(range: range3, from: .tokenMeta, order: .asc)
    
    #expect(readRange1 == objects1)
    #expect(readRange2 == objects2)
    #expect(readRange3.isEmpty)
  }
  
  @Test("Test key")
  func key() async throws {
    let tokenKey = TokenKey(chain: .eth, address: "0x112233445566778899aabbccddeeff0011223344", contractAddress: "0x5566778899aabbccddeeff001122334455667788")
    #expect(tokenKey.address == "0x112233445566778899aabbccddeeff0011223344")
    #expect(tokenKey.contractAddress == "0x5566778899aabbccddeeff001122334455667788")
    #expect(tokenKey.key.hexString == "0x00000000000000000000000000000001010014112233445566778899aabbccddeeff00112233440100145566778899aabbccddeeff001122334455667788")
  }
}
