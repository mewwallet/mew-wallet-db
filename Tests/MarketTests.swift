//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation
import XCTest
import SwiftProtobuf
import mdbx_ios
@testable import mew_wallet_db



final class market_collection_tests: XCTestCase {
  
  private var db: MEWwalletDBImpl!
  private let table: MDBXTableName = .marketCollection
  private let account_address = "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1"
  
  lazy private var _path: String = {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db")
    return url.path
  }()
  
  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)
    
    do {
      try self.db.start(path: self._path, tables: MDBXTableName.allCases)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  override func tearDown() {
    super.tearDown()
    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func testMarketCollection() async {
    do {
      let bundlePath = Foundation.Bundle.module.bundlePath
      
      let filePath = "\(bundlePath)/Contents/Resources/json/MarketCollection.json"
      let url = URL(fileURLWithPath: filePath)
      let testMarketCollectionJson = try String(contentsOf: url, encoding: .utf8)

      let chain = MDBXChain.universal
      let items = try MarketCollectionItem.array(fromJSONString: testMarketCollectionJson, chain: chain)
      for (index, item) in items.enumerated() {
        let key = MarketCollectionItemKey(chain: chain, index: UInt64(index))
        try await db.write(
          table: .marketCollection,
          key: key,
          object: item,
          mode: .recommended(.marketCollection)
        )
      }
      
      // read key with 1
      let keyIndex1 = MarketCollectionItemKey(chain: chain, index: 1)
      let item1 = items[1]
      let marketCollectionItem1: MarketCollectionItem = try db.read(key: keyIndex1, table: .marketCollection)
      XCTAssertEqual(item1, marketCollectionItem1)
      XCTAssertFalse(marketCollectionItem1.filters.isEmpty)
      XCTAssertFalse(marketCollectionItem1.tokens.isEmpty)
      XCTAssertEqual(marketCollectionItem1.tokens[0].price, Decimal(hex: item1.tokens[0]._wrapped.price))

      // lowest range
      let startKey = MarketCollectionItemKey(chain: .universal, lowerRange: true)
      let endKey = MarketCollectionItemKey(chain: .universal, lowerRange: false)

      let marketItems: [MarketCollectionItem] = try db.fetch(range: .with(start: startKey, end: endKey), from: .marketCollection, order: .asc)
      for (index, value) in marketItems.enumerated() {
        XCTAssertEqual(items[index], value)
      }
      XCTAssertTrue(marketItems.count == 3)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMarketMovers() async {
    do {
      let chain = MDBXChain.universal
      var options = JSONDecodingOptions()
      options.ignoreUnknownFields = true
      
      let bundlePath = Foundation.Bundle.module.bundlePath
      
      let filePath = "\(bundlePath)/Contents/Resources/json/MarketMovers.json"
      let url = URL(fileURLWithPath: filePath)
      let marketMoversJsonString = try String(contentsOf: url, encoding: .utf8)
      
      let response = try MarketMoversV3Wrapper(jsonString: marketMoversJsonString, chain: .universal)
      XCTAssertEqual("USD", response.currency)

      for (index, item) in response.items.enumerated() {
        let key = MarketMoversItemKey(
          chain: chain,
          timestamp: UInt64(item.timestamp.timeIntervalSinceReferenceDate),
          index: UInt64(index)
        )
        try await db.write(
          table: .marketMovers,
          key: key,
          object: item,
          mode: .recommended(.marketMovers)
        )
      }
      
      // read key with 1
      let keyIndex1 = MarketMoversItemKey(chain: chain, timestamp: UInt64(response.items[1].timestamp.timeIntervalSinceReferenceDate), index: 1)
      XCTAssertEqual(keyIndex1.index, 1)
      
      let item1 = response.items[1]
      let marketMoversItem1: MarketMoversItem = try db.read(key: keyIndex1, table: .marketMovers)
      XCTAssertEqual(item1, marketMoversItem1)
      
      
      // non-existing key
      let nonexistingCurrency = MarketMoversItemKey(chain: chain, timestamp: 0, index: 1)
      do {
        let _: MarketMoversItem = try db.read(key: nonexistingCurrency, table: .marketMovers)
        XCTFail("found non-existing item")
      } catch MDBXError.notFound {
        XCTAssertTrue(true)
      } catch {
        XCTFail(error.localizedDescription)
      }

      let nonexistingSort = MarketMoversItemKey(chain: chain, timestamp: 0, index: 1)
      do {
        let _: MarketMoversItem = try db.read(key: nonexistingSort, table: .marketMovers)
        XCTFail("found non-existing item")
      } catch MDBXError.notFound {
        XCTAssertTrue(true)
      } catch {
        XCTFail(error.localizedDescription)
      }

      let nonexistingChain = MarketMoversItemKey(chain: .polygon_mumbai, timestamp: UInt64(item1.timestamp.timeIntervalSinceReferenceDate), index: 1)
      do {
        let _: MarketMoversItem = try db.read(key: nonexistingChain, table: .marketMovers)
        XCTFail("found non-existing item")
      } catch MDBXError.notFound {
        XCTAssertTrue(true)
      } catch {
        XCTFail(error.localizedDescription)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
//  func testMarketList() async {
//    do {
//      let chain = MDBXChain.universal
//      var options = JSONDecodingOptions()
//      options.ignoreUnknownFields = true
//
//      let bundlePath = Foundation.Bundle.module.bundlePath
//
//      let filePath = "\(bundlePath)/Contents/Resources/json/MarketList.json"
//      let url = URL(fileURLWithPath: filePath)
//      let marketListJsonString = try String(contentsOf: url, encoding: .utf8)
//
//      let response = try MarketListV3Wrapper(jsonString: marketListJsonString, chain: .universal)
//      XCTAssertEqual("USD", response.currency)
//      XCTAssertEqual("marketCap", response.sort)
//      XCTAssertEqual(chain, response._chain)
//
//      for (index, item) in response.items.enumerated() {
//        let key = MarketItemKey(
//          chain: chain,
//          currency: response.currency,
//          sort: response.sort,
//          index: UInt64(index)
//        )
//        try await db.write(
//          table: .marketList,
//          key: key,
//          object: item,
//          mode: .recommended(.marketList)
//        )
//      }
//
//      // read key with 1
//      let keyIndex1 = MarketMoversItemKey(chain: chain, currency: "USD", sort: "marketCap", index: 1)
//      XCTAssertEqual(keyIndex1.sort, "marketCap".sha256.setLengthLeft(MDBXKeyLength.hash))
//
//      let item1 = response.items[1]
//      let marketItem1: TokenMeta = try db.read(key: keyIndex1, table: .marketList)
//      XCTAssertEqual(item1, marketItem1)
//
//      // lowest range
//      let startKey = MarketMoversItemKey(chain: chain, currency: "USD", sort: "marketCap", lowerRange: true)
//      let endKey = MarketMoversItemKey(chain: chain, currency: "USD", sort: "marketCap", lowerRange: false)
//
//      let moversItem: [TokenMeta] = try db.fetch(range: .with(start: startKey, end: endKey), from: .marketList, order: .asc)
//      XCTAssertEqual(moversItem.count, response.items.count)
//      for (index, value) in moversItem.enumerated() {
//        XCTAssertEqual(response.items[index], value)
//      }
//    } catch {
//      XCTFail(error.localizedDescription)
//    }
//  }
}
