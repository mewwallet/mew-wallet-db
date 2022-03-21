//
//  File.swift
//  
//
//  Created by Sergey Kolokolnikov on 23.02.2022.
//

import Foundation
import XCTest
import SwiftProtobuf
@testable import mew_wallet_db

private let testJson = """
[
  {
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "price": "2629.39",
    "volume_24h": "12857964066",
    "name": "Ethereum",
    "symbol": "ETH",
    "decimals": 18,
    "timestamp": "2022-02-21T12:34:25.655Z",
    "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png"
  },
  {
    "contract_address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
    "price": "1.003",
    "volume_24h": "35542575558",
    "name": "Tether",
    "symbol": "USDT",
    "decimals": 6,
    "timestamp": "2022-02-21T12:32:22.086Z",
    "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdAC17F958D2ee523a2206206994597C13D831ec7-eth.png"
  },
  {
    "contract_address": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "price": "1.001",
    "volume_24h": "2813764960",
    "name": "USD Coin",
    "symbol": "USDC",
    "decimals": 6,
    "timestamp": "2022-02-21T12:35:45.475Z",
    "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48-eth.png"
  },
  {
    "contract_address": "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
    "price": "37657",
    "volume_24h": "212735090",
    "name": "Wrapped Bitcoin",
    "symbol": "WBTC",
    "decimals": 8,
    "timestamp": "2022-02-21T12:35:23.956Z",
    "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WBTC-0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599-eth.png"
  }
]
"""


final class TokenMetaTests: XCTestCase {
  private var db: MEWwalletDBImpl!
  private let table: MDBXTableName = .tokenMeta
  
  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    db.delete(name: "test")
    
    do {
      try self.db.start(name: "test", tables: MDBXTableName.allCases)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
  }
  
  override func tearDown() {
    super.tearDown()
    db.delete(name: "test")
    db = nil
  }
  
//  func test() {
//    
//    guard let data = testJson.data(using: .utf8) else {
//      XCTFail("Invalid json")
//      return
//    }
//    
//    guard let tokensAccountRouteResponse = try? TokensAccountRouteResponse(jsonUTF8Data: data) else {
//      XCTFail("serialise data error")
//      return
//    }
//    
//    // How to deal with extensions?
//    // Message is a base?
//    // What about relationshop?
//    // What's pointer? why do we need that?
//    // Clean Models, we don't need most of them
//    
//    writeToDB(items: tokensAccountRouteResponse.featured) {
//      self.db.commit(table: self.table)
//      
//      for item in tokensAccountRouteResponse.featured {
//        let key = TokenMetaKeyV2(projectId: .eth, address: item.contractAddress)
//        guard let data = try? self.db.read(key: key, table: self.table) else {
//          XCTFail("response read data error")
//          return
//        }
//        
//        guard let  tokenMetaPBData_ = try? TokenMetaPB(jsonUTF8Data: data) else {
//          XCTFail("response serialize to json data error")
//          return
//        }
//        
//        guard tokenMetaPBData_.contractAddress == item.contractAddress else {
//          XCTFail("Invalid response data")
//          return
//        }
//      }
//    }
//    
//  }
  
//  private func writeToDB(items: [TokenMetaPB], completionBlock: @escaping () -> Void) {
//    
//    guard let data = testJson.data(using: .utf8) else {
//      XCTFail("Invalid json")
//      return
//    }
//    
//    for item in items {
//      let key = TokenMetaKeyV2(projectId: .eth, address: item.contractAddress)
//      db.writeAsync(table: self.table, key: key, value: data) { success -> MDBXWriteAction in
//        switch success {
//        case true:
//          debugPrint("================")
//          debugPrint("Successful write item with address: \(item.contractAddress)")
//          debugPrint("================")
//          completionBlock()
//        case false:
//          completionBlock()
//          XCTFail("Failed to write data")
//          
//        }
//        return .none
//      }
//    }
//    
//  }
  
}
