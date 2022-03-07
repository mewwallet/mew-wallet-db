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

  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    db.delete(name: "test")

    try! db.start(name: "test", tables: MDBXTableName.allCases)
  }

  override func tearDown() {
    super.tearDown()

    db.delete(name: "test")
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
        
//        let asd = [dexItem.alternateKey?.key.hexString,
//                   dexItem2.alternateKey?.key.hexString,
//                   dexItem3.alternateKey?.key.hexString]
//        debugPrint(asd)
        
//        debugPrint(try dexItem.meta)
//        debugPrint()
        
        var dex = try dexItem.meta.dexItem.meta.dexItem
        dex.order = 0
        debugPrint(try dex.meta.sparkline)
        
        
//        debugPrint(metas)
      } catch {
        debugPrint(error)
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  

//  func test() {
//    let expectation = XCTestExpectation()
//
//    writePrices {
//      do {
//        let prices: [Price] = try self.db.fetchAll(from: .price)
//        XCTAssert(prices.count == self.prices.count)
//        debugPrint("Number after write: \(prices.count)")
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//    }
//
//    DispatchQueue.global().async {
//      var attempts = 0
//      while attempts < 100 {
//        Thread.sleep(forTimeInterval: 0.2)
//
//        let contractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
//        let tokenMetaKey = TokenMetaKey(projectId: .eth, contractAddress: contractAddress)
//
//        let priceKey = PriceKey(tokenMetaKey: tokenMetaKey).key
//        do {
//          let decoder = JSONDecoder()
//          decoder.dateDecodingStrategy = .formatted(self.df)
//          _ /*let decoded: Price*/ = try self.db.read(key: priceKey, table: .price)
//          expectation.fulfill()
//          break
//        } catch {
//          attempts += 1
//          debugPrint(error.localizedDescription)
//        }
//      }
//    }
//
//    wait(for: [expectation], timeout: 5)
//  }
//
//  func testDexItemsShouldDecode() -> [DexItem] {
//    let decoder = JSONDecoder()
//
//    do {
//      let dexes = try decoder.decode([DexItem].self, from: dexData)
//      XCTAssertFalse(dexes.isEmpty)
//      return dexes
//    } catch {
//      XCTFail(error.localizedDescription)
//      abort()
//    }
//  }
//
//  func testDexItemsWrite() {
//    let expectation = XCTestExpectation()
//    writeDexes {
//      expectation.fulfill()
//    }
//    wait(for: [expectation], timeout: 5)
//  }
//
//  func testDexItemsWriteAndRead() {
//    let expectation = XCTestExpectation()
//
//    writeDexes {
//      var attempts = 0
//      while attempts < 100 {
//        Thread.sleep(forTimeInterval: 0.2)
//
//        let contractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
//        let tokenMetaKey = TokenMetaKey(chain: .eth, contractAddress: contractAddress)
//
//        do {
//          let decoded: DexItem = try self.db.read(key: tokenMetaKey.key, table: .dex)
//          XCTAssert(decoded.tokenMetaKey!.contractAddress == tokenMetaKey.contractAddress)
//          expectation.fulfill()
//          break
//        } catch {
//          attempts += 1
//          debugPrint(error.localizedDescription)
//        }
//      }
//    }
//
//    wait(for: [expectation], timeout: 5)
//  }
//
//  func testWriteDexesAndPrices() {
//    let dexExpectation = XCTestExpectation()
//    let priceExpectation = XCTestExpectation()
//
//    writeDexes {
//      do {
//        let dexes: [DexItem] = try self.db.fetchAll(from: .dex)
//        XCTAssert(dexes.count > 0)
//        debugPrint("Number after 1st write: \(dexes.count)")
//
//        self.writeDexes {
//          do {
//            let dexes2: [DexItem] = try self.db.fetchAll(from: .dex)
//            XCTAssertEqual(dexes.count, dexes2.count)
//            debugPrint("Number after 2nd write: \(dexes2.count)")
//            dexExpectation.fulfill()
//          } catch {
//            XCTFail(error.localizedDescription)
//          }
//        }
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//    }

//    writePrices {
//      priceExpectation.fulfill()
//    }
//
//    wait(for: [dexExpectation, priceExpectation], timeout: 5)
//  }

//  func testFetchRange() {
//    let expectation = XCTestExpectation()
//
//    let key1 = TokenMetaKey(projectId: .eth, contractAddress: "0x01")
//    let key2 = TokenMetaKey(projectId: .eth, contractAddress: "0x02")
//    let key3 = TokenMetaKey(projectId: .eth, contractAddress: "0x03")
//    let key4 = TokenMetaKey(projectId: .eth, contractAddress: "0x04")
//    Task {
//      do {
//        let keys = [key1, key2, key3, key4]
//        for key in keys.enumerated() {
//          let meta = TokenMeta(
//            name: key.element.contractAddress,
//            decimals: NSDecimalNumber(value: key.offset) as Decimal,
//            tokenMetaKey: key.element,
//            icon: nil,
//            symbol: nil,
//            price: nil
//          )
//          let encoder = JSONEncoder()
//          try await db.write(table: .tokenMeta, key: key.element, value: encoder.encode(meta))
//        }
//
//        let allResults: [TokenMeta] = try db.fetchAll(from: .tokenMeta)
//        XCTAssertTrue(allResults.count == keys.count)
//
//        let rangeResults: [TokenMeta] = try db.fetchRange(startKey: key2, endKey: key3, from: .tokenMeta)
//
//        XCTAssertTrue(rangeResults.count == 2)
//        let result = rangeResults.first!
//        XCTAssertTrue(result.tokenMetaKey.contractAddress == key2.contractAddress)
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      expectation.fulfill()
//    }
//
//    wait(for: [expectation], timeout: 5)
//  }

//  func testBalances() {
//    let expectation = XCTestExpectation()
//
//    Task {
//      do {
//        let (checksum, totalCount) = try await writeBalances()
//        let allResults: [Balance] = try db.fetchAll(from: .balance)
//
//        XCTAssertTrue(allResults.count == totalCount)
//
//        var resultChecksum = 0
//        allResults.forEach {
//          resultChecksum = resultChecksum ^ $0.amount.hashValue ^ $0.contractAddress.hashValue
//        }
//        XCTAssertTrue(resultChecksum == checksum)
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      expectation.fulfill()
//    }
//
//    wait(for: [expectation], timeout: 5.0)
//  }

//  func testTokens() {
//    let expectation = XCTestExpectation()
//
//    Task {
//      do {
//        let _ = try await writeBalances()
//
//        let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
//        let tokenMetas = try decoder.decode([TokenMeta].self, from: tokensData)
//
//
//        var checksum: Int = 0
//        for tokenMeta in tokenMetas {
//          try await db.write(table: .tokenMeta, key: tokenMeta.tokenMetaKey, value: encoder.encode(tokenMeta))
//
//          let tokenKey = TokenKey(address: address, tokenMetaKey: tokenMeta.tokenMetaKey)
//          let token = Token(address: address, tokenMetaKey: tokenMeta.tokenMetaKey)
//
//          XCTAssertTrue(tokenKey.address == address.setLengthLeft(MDBXKeyLength.address))
//
//          try await db.write(table: .token, key: tokenKey, value: encoder.encode(token))
//          checksum = checksum ^ token.address.hashValue ^ token.tokenMetaKey.contractAddress.hashValue
//        }
//
//        let allResults: [Token] = try db.fetchAll(from: .token)
//        XCTAssertTrue(allResults.count == tokenMetas.count)
//
//        var resultChecksum = 0
//        allResults.forEach {
//          resultChecksum = resultChecksum ^ $0.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue
//        }
//        XCTAssertTrue(resultChecksum == checksum)
//
//        // check if there is a primary token
//        let ethContractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
//        let ethKey = TokenKey(address: address, tokenMetaKey: .init(projectId: .eth, contractAddress: ethContractAddress))
//        let token: Token = try db.read(key: ethKey, table: .token)
//        XCTAssertTrue(token.isPrimary)
//        XCTAssertTrue(token.balance!.amount == Decimal(hex: "0x10e2a3d14a33690"))
//        XCTAssertTrue(token.tokenMeta!.name == "Ethereum")
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      expectation.fulfill()
//    }
//
//    wait(for: [expectation], timeout: 5.0)
//  }

//  func testTransfers() {
//    let expecation = XCTestExpectation()
//    Task {
//      do {
//        let decoder = JSONDecoder()
//        // custom date decoding strategy
//        decoder.dateDecodingStrategy = .custom { decoder -> Date in
//          let container = try decoder.singleValueContainer()
//          let dateStr = try container.decode(String.self)
//          let dateFormatter = ISO8601DateFormatter()
//          dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]
//
//          let date = dateFormatter.date(from: dateStr)
//
//          guard let date_ = date else {
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
//          }
//          return date_
//        }
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .custom({ date, encoder in
//          let dateFormatter = ISO8601DateFormatter()
//          dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]
//
//          var container = encoder.singleValueContainer()
//          try container.encode(dateFormatter.string(from: date))
//        })
//
//        let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
//        let transfers = try decoder.decode([Transfer].self, from: transfersData)
//
//        var completedChecksum: Int = 0
//        var pendingChecksum: Int = 0
//
//        for transfer in transfers {
//          let tokenMeta = TokenMeta(tokenMetaKey: transfer.tokenMetaKey)
//          try await db.write(table: .tokenMeta, key: transfer.tokenMetaKey, value: encoder.encode(tokenMeta))
//
//          let transferKey = TransferKey(
//            projectId: .eth,
//            address: address,
//            blockNumber: Decimal(transfer.blockNumber),
//            direction: transfer.direction.rawValue,
//            nonce: Decimal(transfer.nonce)
//          )
//          XCTAssertTrue(transferKey.address == address.setLengthLeft(MDBXKeyLength.address))
//
//          if transfer.isPending {
//            try await db.write(table: .pendingTransfer, key: transferKey, value: encoder.encode(transfer))
//            pendingChecksum = pendingChecksum ^ transfer.ownerKey.address.hashValue ^ transfer.tokenMetaKey.contractAddress.hashValue ^ transfer.amount.hashValue ^ transfer.blockNumber.hashValue ^ transfer.txHash.hashValue ^ transfer.nonce.hashValue
//          } else {
//            try await db.write(table: .completedTransfer, key: transferKey, value: encoder.encode(transfer))
//            completedChecksum = completedChecksum ^ transfer.ownerKey.address.hashValue ^ transfer.tokenMetaKey.contractAddress.hashValue ^ transfer.amount.hashValue ^ transfer.blockNumber.hashValue ^ transfer.txHash.hashValue ^ transfer.nonce.hashValue
//          }
//
//          let recipientKeys = [transfer.ownerKey, transfer.fromKey, transfer.toKey].compactMap { $0 }
//          for recipientKey in recipientKeys {
//            let recipient = Recipient(address: recipientKey.address)
//            try await db.write(table: .recipient, key: recipientKey, value: encoder.encode(recipient))
//          }
//        }
//
//        XCTAssert(try transferReadChecksum(from: .completedTransfer) == completedChecksum)
//        XCTAssert(try transferReadChecksum(from: .pendingTransfer) == pendingChecksum)
//
//        let ethereumTransfer = TransferKey(
//          projectId: .eth,
//          address: address,
//          blockNumber: Decimal(12695817),
//          direction: TransferDirection.outgoing.rawValue,
//          nonce: Decimal(1507)
//        )
//        let transfer: Transfer = try db.read(key: ethereumTransfer, table: .completedTransfer)
//        XCTAssertFalse(transfer.isPending)
//        XCTAssert(transfer.blockNumber == 12695817)
//        XCTAssert(transfer.nonce == 1507)
//        XCTAssert(transfer.from!.address == address.hexString)
//        XCTAssert(transfer.owner!.address == address.hexString)
//        XCTAssert(transfer.to!.address == "0x14095009d85dd694ef5a9ccf9436baf719cb3588")
//        XCTAssert(transfer.direction == .outgoing)
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      expecation.fulfill()
//    }
//
//    wait(for: [expecation], timeout: 5.0)
//  }
//
//  private func transferReadChecksum(from table: MDBXTableName) throws -> Int {
//    let allResults: [Transfer] = try db.fetchAll(from: table)
//
//    var resultChecksum = 0
//    allResults.forEach {
//      resultChecksum = resultChecksum ^ $0.ownerKey.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue ^ $0.amount.hashValue ^ $0.blockNumber.hashValue ^ $0.txHash.hashValue ^ $0.nonce.hashValue
//    }
//    return resultChecksum
//  }

//  private func writeBalances() async throws -> (checksum: Int, count: Int) {
//    let decoder = JSONDecoder()
//    decoder.dateDecodingStrategy = .iso8601
//    let encoder = JSONEncoder()
//
//
//    let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
//    let balances = try decoder.decode([Balance].self, from: balanceData)
//    var checksum: Int = 0
//    for balance in balances {
//      let balanceKey = BalanceKey(
//        address: address,
//        tokenMetaKey: .init(projectId: .eth, contractAddress: balance.contractAddress)
//      )
//      XCTAssertTrue(balanceKey.address == address.setLengthLeft(MDBXKeyLength.address))
//      XCTAssertTrue(balanceKey.tokenMetaKey!.contractAddress == balance.contractAddress)
//
//      try await db.write(table: .balance, key: balanceKey, value: encoder.encode(balance))
//      checksum = checksum ^ balance.amount.hashValue ^ balance.contractAddress.hashValue
//    }
//
//    return (checksum, balances.count)
//  }

//  private func writePrices(completionBlock: @escaping () -> Void) {
//    let priceAndKeys: [(PriceKey, Price)] = self.prices.map { price in
//      let tokenMetaKey = TokenMetaKey(projectId: .eth, contractAddress: price.tokenMetaKey.contractAddress)
//      let priceKey = PriceKey(tokenMetaKey: tokenMetaKey)
//      return (priceKey, price)
//    }
//    db.writeAsync(table: .price, keysAndValues: priceAndKeys) { success in
//      if success {
//        debugPrint("================")
//        debugPrint("Successful write")
//        debugPrint("================")
//      } else {
//        XCTFail("Failed to write data")
//      }
//      completionBlock()
//    }
//  }
//
//  func writeDexes(completionBlock: @escaping () -> Void) {
//    let dexes = testDexItemsShouldDecode()
//
//    let dexesAndKeys: [(TokenMetaKey, DexItem)] = dexes.map { dex in
//      return (dex.tokenMetaKey!, dex)
//    }
//    db.writeAsync(table: .dex, keysAndValues: dexesAndKeys) { success in
//      if success {
//        debugPrint("================")
//        debugPrint("Successful write")
//        debugPrint("================")
//      } else {
//        XCTFail("Failed to write data")
//      }
//      completionBlock()
//    }
//  }
//
//  func testDropTableNotFoundError() {
//    let expectation = XCTestExpectation()
//    Task {
//      do {
//        try await self.db.drop(table: .dex, delete: false)
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      expectation.fulfill()
//    }
//
//    wait(for: [expectation], timeout: 5.0)
//  }
}
