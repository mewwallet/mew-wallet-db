//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/21.
//

import Foundation
import XCTest
@testable import MEWwalletDB

private let testJson = """
{
  "results": [
    {
      "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
      "name": "Ethereum",
      "price": "3906.63",
      "market_cap": "452970439775",
      "timestamp": "2021-05-11T05:31:25.272Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
      "website": "https://ethereum.org/",
      "symbol": "ETH",
      "decimals": 18
    },
    {
      "contract_address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
      "name": "Tether",
      "price": "1",
      "market_cap": "56723942405",
      "timestamp": "2021-05-11T05:07:08.104Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdac17f958d2ee523a2206206994597c13d831ec7.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdac17f958d2ee523a2206206994597c13d831ec7.png",
      "website": "https://tether.to",
      "symbol": "USDT",
      "decimals": 6
    },
    {
      "contract_address": "0x514910771af9ca656af840dff83e8264ecf986ca",
      "name": "Chainlink",
      "price": "45.72",
      "market_cap": "19519631356",
      "timestamp": "2021-05-11T05:29:46.317Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/LINK-0x514910771af9ca656af840dff83e8264ecf986ca.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/LINK-0x514910771af9ca656af840dff83e8264ecf986ca.png",
      "website": "https://link.smartcontract.com",
      "symbol": "LINK",
      "decimals": 18
    },
    {
      "contract_address": "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
      "name": "Uniswap",
      "price": "36.47",
      "market_cap": "19053008609",
      "timestamp": "2021-05-11T05:28:58.840Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/UNI-0x1f9840a85d5af5bf1d1762f925bdaddc4201f984.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/UNI-0x1f9840a85d5af5bf1d1762f925bdaddc4201f984.png",
      "website": "https://uniswap.org/",
      "symbol": "UNI",
      "decimals": 18
    },
    {
      "contract_address": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
      "name": "USD Coin",
      "price": "1",
      "market_cap": "15794185019",
      "timestamp": "2021-05-11T05:29:28.226Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
      "website": "https://www.centre.io",
      "symbol": "USDC",
      "decimals": 6
    },
    {
      "contract_address": "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
      "name": "Wrapped Bitcoin",
      "price": "55330",
      "market_cap": "9606339022",
      "timestamp": "2021-05-11T05:29:42.550Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WBTC-0x2260fac5e5542a773aa44fbcfedf7c193bc2c599.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WBTC-0x2260fac5e5542a773aa44fbcfedf7c193bc2c599.png",
      "website": "https://www.wbtc.network",
      "symbol": "WBTC",
      "decimals": 8
    },
    {
      "contract_address": "0x75231f58b43240c9718dd58b4967c5114342a86c",
      "name": "OKB",
      "price": "34.1",
      "market_cap": "9302492298",
      "timestamp": "2021-05-11T05:29:22.882Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/OKB-0x75231f58b43240c9718dd58b4967c5114342a86c.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/OKB-0x75231f58b43240c9718dd58b4967c5114342a86c.png",
      "website": "",
      "symbol": "OKB",
      "decimals": 18
    },
    {
      "contract_address": "0x4fabb145d64652a948d72533023f6e7a623c7c53",
      "name": "Binance USD",
      "price": "0.999367",
      "market_cap": "7876615554",
      "timestamp": "2021-05-11T05:30:14.645Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/BUSD-0x4fabb145d64652a948d72533023f6e7a623c7c53.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/BUSD-0x4fabb145d64652a948d72533023f6e7a623c7c53.png",
      "website": "https://www.paxos.com/busd",
      "symbol": "BUSD",
      "decimals": 18
    },
    {
      "contract_address": "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5",
      "name": "cETH",
      "price": "78.34",
      "market_cap": "5924466015",
      "timestamp": "2021-05-11T05:27:54.502Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/cETH-0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/cETH-0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5.png",
      "website": "",
      "symbol": "cETH",
      "decimals": 8
    },
    {
      "contract_address": "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9",
      "name": "Aave",
      "price": "431.96",
      "market_cap": "5514531930",
      "timestamp": "2021-05-11T05:29:12.855Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/AAVE-0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/AAVE-0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9.png",
      "website": "",
      "symbol": "AAVE",
      "decimals": 18
    },
    {
      "contract_address": "0x6f259637dcd74c767781e37bc6133cd6a68aa161",
      "name": "Huobi Token",
      "price": "30.45",
      "market_cap": "5471371955",
      "timestamp": "2021-05-11T05:29:05.182Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/HT-0x6f259637dcd74c767781e37bc6133cd6a68aa161.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/HT-0x6f259637dcd74c767781e37bc6133cd6a68aa161.png",
      "website": "",
      "symbol": "HT",
      "decimals": 18
    },
    {
      "contract_address": "0x50d1c9771902476076ecfc8b2a83ad6b9355a4c9",
      "name": "FTX Token",
      "price": "58.89",
      "market_cap": "5186063162",
      "timestamp": "2021-05-11T05:29:35.530Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/FTT-0x50d1c9771902476076ecfc8b2a83ad6b9355a4c9.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/FTT-0x50d1c9771902476076ecfc8b2a83ad6b9355a4c9.png",
      "website": "https://ftx.com",
      "symbol": "FTT",
      "decimals": 18
    },
    {
      "contract_address": "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0",
      "name": "Polygon",
      "price": "0.834937",
      "market_cap": "5070809696",
      "timestamp": "2021-05-11T05:29:20.999Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/MATIC-0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/MATIC-0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0.png",
      "website": "",
      "symbol": "MATIC",
      "decimals": 18
    },
    {
      "contract_address": "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643",
      "name": "cDAI",
      "price": "0.02144161",
      "market_cap": "4855851144",
      "timestamp": "2021-05-11T05:27:54.913Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/CDAI-0x5d3a536e4d6dbd6114cc1ead35777bab948e3643.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/CDAI-0x5d3a536e4d6dbd6114cc1ead35777bab948e3643.png",
      "website": "",
      "symbol": "CDAI",
      "decimals": 8
    },
    {
      "contract_address": "0x6b175474e89094c44da98b954eedeac495271d0f",
      "name": "Dai",
      "price": "1",
      "market_cap": "4580083265",
      "timestamp": "2021-05-11T05:06:56.381Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/DAI-0x6b175474e89094c44da98b954eedeac495271d0f.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/DAI-0x6b175474e89094c44da98b954eedeac495271d0f.png",
      "website": "https://makerdao.com",
      "symbol": "DAI",
      "decimals": 18
    },
    {
      "contract_address": "0x39aa39c021dfbae8fac545936693ac917d5e7563",
      "name": "cUSDC",
      "price": "0.02199731",
      "market_cap": "4495346078",
      "timestamp": "2021-05-11T05:27:54.630Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/cUSDC-0x39aa39c021dfbae8fac545936693ac917d5e7563.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/cUSDC-0x39aa39c021dfbae8fac545936693ac917d5e7563.png",
      "website": "",
      "symbol": "cUSDC",
      "decimals": 8
    },
    {
      "contract_address": "0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2",
      "name": "Maker",
      "price": "4918.84",
      "market_cap": "4447089616",
      "timestamp": "2021-05-11T05:29:23.695Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/MKR-0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/MKR-0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2.png",
      "website": "https://makerdao.com",
      "symbol": "MKR",
      "decimals": 18
    },
    {
      "contract_address": "0xc00e94cb662c3520282e6f5717214004a7f26888",
      "name": "Compound",
      "price": "799.21",
      "market_cap": "4132981121",
      "timestamp": "2021-05-11T05:29:03.059Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/COMP-0xc00e94cb662c3520282e6f5717214004a7f26888.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/COMP-0xc00e94cb662c3520282e6f5717214004a7f26888.png",
      "website": "",
      "symbol": "COMP",
      "decimals": 18
    },
    {
      "contract_address": "0xa0b73e1ff0b80914ab6fe0444e65848c4c34450b",
      "name": "Crypto.com Coin",
      "price": "0.158085",
      "market_cap": "4008421860",
      "timestamp": "2021-05-11T05:29:27.500Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/CRO-0xa0b73e1ff0b80914ab6fe0444e65848c4c34450b.png",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/CRO-0xa0b73e1ff0b80914ab6fe0444e65848c4c34450b.png",
      "website": "",
      "symbol": "CRO",
      "decimals": 8
    },
    {
      "contract_address": "0x2af5d2ad76741191d15dfe7bf6ac92d4bd912ca3",
      "name": "LEO Token",
      "price": "3.46",
      "market_cap": "3301123403",
      "timestamp": "2021-05-11T05:28:26.177Z",
      "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/LEO-0x2af5d2ad76741191d15dfe7bf6ac92d4bd912ca3.svg",
      "icon_png": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/LEO-0x2af5d2ad76741191d15dfe7bf6ac92d4bd912ca3.png",
      "website": "https://www.bitfinex.com",
      "symbol": "LEO",
      "decimals": 18
    }
  ],
  "paginationToken": "2"
}
"""

private struct ArrayResult<T: Codable>: Codable {
  let results: [T]
}

private let projectId = "0x00"

final class MEWwalletDBTests: XCTestCase {
  var prices: [Price] = []
  
  lazy var df: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
    return df
  }()
  
  lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(self.df)
    return decoder
  }()
  
  lazy var encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(self.df)
    return encoder
  }()
  
  private var db: MEWwalletDBImpl!
  
  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl(encoder: self.encoder, decoder: self.decoder)
    db.delete(databaseName: "test")
    
    prices = try! self.decoder.decode(ArrayResult<Price>.self, from: testJson.data(using: .utf8)!).results
    try! db.start(databaseName: "test", tables: MDBXTable.allCases)
  }
  
  override func tearDown() {
    super.tearDown()
    
    db.delete(databaseName: "test")
    db = nil
  }
  
  func test() {
    let expectation = XCTestExpectation()
    
    var committed = false
    
    writePrices {
      self.db.commit(table: .price)
      committed = true
      
      do {
        let prices: [Price] = try self.db.fetchAll(from: .price)
        XCTAssert(prices.count == self.prices.count)
        debugPrint("Number after write: \(prices.count)")
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
    DispatchQueue.global().async {
      var attempts = 0
      while attempts < 100 || committed == false {
        Thread.sleep(forTimeInterval: 0.2)

        let contractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
        let tokenMetaKey = TokenMetaKey(projectId: .eth, contractAddress: contractAddress)
        
        let priceKey = PriceKey(tokenMetaKey: tokenMetaKey).key
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .formatted(self.df)
          _ /*let decoded: Price*/ = try self.db.read(key: priceKey, table: .price)
          expectation.fulfill()
          break
        } catch {
          if committed {
            attempts += 1
            debugPrint(error.localizedDescription)
          }
        }
      }
    }
    
    wait(for: [expectation], timeout: 5)
  }
  
  func testDexItemsShouldDecode() -> [DexItem] {
    let decoder = JSONDecoder()
    
    do {
      let dexes = try decoder.decode([DexItem].self, from: dexData)
      XCTAssertFalse(dexes.isEmpty)
      return dexes
    } catch {
      XCTFail(error.localizedDescription)
      abort()
    }
  }
  
  func testDexItemsWrite() {
    let expectation = XCTestExpectation()
    writeDexes {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 5)
  }
  
  func testDexItemsWriteAndRead() {
    let expectation = XCTestExpectation()
    
    var committed = false
    
    writeDexes {
      self.db.commit(table: .dex)
      committed = true
    }
    
    DispatchQueue.global().async {
      var attempts = 0
      while attempts < 100 || committed == false {
        Thread.sleep(forTimeInterval: 0.2)
        
        let contractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
        let tokenMetaKey = TokenMetaKey(projectId: .eth, contractAddress: contractAddress)
        
        do {
          let decoded: DexItem = try self.db.read(key: tokenMetaKey.key, table: .dex)
          XCTAssert(decoded.tokenMetaKey!.contractAddress == tokenMetaKey.contractAddress)
          expectation.fulfill()
          break
        } catch {
          if committed {
            attempts += 1
            debugPrint(error.localizedDescription)
          }
        }
      }
    }
    
    wait(for: [expectation], timeout: 5)

  }
  
  func testWriteDexesAndPrices() {
    let dexExpectation = XCTestExpectation()
    let priceExpectation = XCTestExpectation()
    
    writeDexes {
      do {
        let dexes: [DexItem] = try self.db.fetchAll(from: .dex)
        XCTAssert(dexes.count > 0)
        debugPrint("Number after 1st write: \(dexes.count)")
        
        self.writeDexes {
          do {
            let dexes2: [DexItem] = try self.db.fetchAll(from: .dex)
            XCTAssert(dexes.count == dexes2.count)
            debugPrint("Number after 2nd write: \(dexes2.count)")
            dexExpectation.fulfill()
          } catch {
            XCTFail(error.localizedDescription)
          }
        }
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
    writePrices {
      priceExpectation.fulfill()
    }
    
    wait(for: [dexExpectation, priceExpectation], timeout: 5)
  }
  
  func testFetchRange() {
    let key1 = TokenMetaKey(projectId: .eth, contractAddress: "0x01")
    let key2 = TokenMetaKey(projectId: .eth, contractAddress: "0x02")
    let key3 = TokenMetaKey(projectId: .eth, contractAddress: "0x03")
    let key4 = TokenMetaKey(projectId: .eth, contractAddress: "0x04")
    do {
      let keys = [key1, key2, key3, key4]
      try keys.enumerated().forEach {
        let meta = TokenMeta(
          name: $0.element.contractAddress,
          decimals: NSDecimalNumber(value: $0.offset) as Decimal,
          tokenMetaKey: $0.element,
          icon: nil,
          symbol: nil,
          price: nil
        )
        let encoder = JSONEncoder()
        try db.write(table: .tokenMeta, key: $0.element, value: encoder.encode(meta))
        db.commit(table: .tokenMeta)
      }
      
      let allResults: [TokenMeta] = try db.fetchAll(from: .tokenMeta)
      XCTAssertTrue(allResults.count == keys.count)
      
      let rangeResults: [TokenMeta] = try db.fetchRange(startKey: key2, endKey: key3, table: .tokenMeta)
      
      XCTAssertTrue(rangeResults.count == 2)
      let result = rangeResults.first!
      XCTAssertTrue(result.tokenMetaKey.contractAddress == key2.contractAddress)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testBalances() {
    do {
      let (checksum, totalCount) = try writeBalances()
      let allResults: [Balance] = try db.fetchAll(from: .balance)
      
      XCTAssertTrue(allResults.count == totalCount)

      var resultChecksum = 0
      allResults.forEach {
        resultChecksum = resultChecksum ^ $0.amount.hashValue ^ $0.contractAddress.hashValue
      }
      XCTAssertTrue(resultChecksum == checksum)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTokens() {
    do {
      let _ = try writeBalances()
      
      let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
      let tokenMetas = try decoder.decode([TokenMeta].self, from: tokensData)
      
      
      var checksum: Int = 0
      try tokenMetas.forEach {
        try db.write(table: .tokenMeta, key: $0.tokenMetaKey, value: encoder.encode($0))
        
        let tokenKey = TokenKey(address: address, tokenMetaKey: $0.tokenMetaKey)
        let token = Token(address: address, tokenMetaKey: $0.tokenMetaKey)
        
        XCTAssertTrue(tokenKey.address == address.setLengthLeft(MDBXKeyLength.address))
        
        try db.write(table: .token, key: tokenKey, value: encoder.encode(token))
        checksum = checksum ^ token.address.hashValue ^ token.tokenMetaKey.contractAddress.hashValue
        db.commit(table: .token)
        db.commit(table: .tokenMeta)
      }
      
      let allResults: [Token] = try db.fetchAll(from: .token)
      XCTAssertTrue(allResults.count == tokenMetas.count)

      var resultChecksum = 0
      allResults.forEach {
        resultChecksum = resultChecksum ^ $0.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue
      }
      XCTAssertTrue(resultChecksum == checksum)
      
      // check if there is a primary token
      let ethContractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
      let ethKey = TokenKey(address: address, tokenMetaKey: .init(projectId: .eth, contractAddress: ethContractAddress))
      let token: Token = try db.read(key: ethKey, table: .token)
      XCTAssertTrue(token.isPrimary)
      XCTAssertTrue(token.balance!.amount == Decimal(hex: "0x10e2a3d14a33690"))
      XCTAssertTrue(token.tokenMeta!.name == "Ethereum")
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransfers() {
    do {
      let decoder = JSONDecoder()
      // custom date decoding strategy
      decoder.dateDecodingStrategy = .custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]

        let date = dateFormatter.date(from: dateStr)
        
        guard let date_ = date else {
          throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
        }
        return date_
      }
      
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .custom({ date, encoder in
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]

        var container = encoder.singleValueContainer()
        try container.encode(dateFormatter.string(from: date))
      })
      
      let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
      let transfers = try decoder.decode([Transfer].self, from: transfersData)
      
      var completedChecksum: Int = 0
      var pendingChecksum: Int = 0
      
      try transfers.forEach {
        let tokenMeta = TokenMeta(tokenMetaKey: $0.tokenMetaKey)
        try db.write(table: .tokenMeta, key: $0.tokenMetaKey, value: encoder.encode(tokenMeta))
        
        let transferKey = TransferKey(
          projectId: .eth,
          address: address,
          blockNumber: Decimal($0.blockNumber),
          direction: $0.direction.rawValue,
          nonce: Decimal($0.nonce)
        )
        XCTAssertTrue(transferKey.address == address.setLengthLeft(MDBXKeyLength.address))

        if $0.isPending {
          try db.write(table: .pendingTransfer, key: transferKey, value: encoder.encode($0))
          pendingChecksum = pendingChecksum ^ $0.ownerKey.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue ^ $0.amount.hashValue ^ $0.blockNumber.hashValue ^ $0.txHash.hashValue ^ $0.nonce.hashValue
        } else {
          try db.write(table: .completedTransfer, key: transferKey, value: encoder.encode($0))
          completedChecksum = completedChecksum ^ $0.ownerKey.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue ^ $0.amount.hashValue ^ $0.blockNumber.hashValue ^ $0.txHash.hashValue ^ $0.nonce.hashValue
        }
        
        let recipientKeys = [$0.ownerKey, $0.fromKey, $0.toKey].compactMap { $0 }
        try recipientKeys.forEach { recipientKey in
          let recipient = Recipient(address: recipientKey.address)
          try db.write(table: .recipient, key: recipientKey, value: encoder.encode(recipient))
        }
      }
      db.commit(table: .tokenMeta)
      db.commit(table: .completedTransfer)
      db.commit(table: .pendingTransfer)
      db.commit(table: .recipient)

      XCTAssert(try transferReadChecksum(from: .completedTransfer) == completedChecksum)
      XCTAssert(try transferReadChecksum(from: .pendingTransfer) == pendingChecksum)

      let ethereumTransfer = TransferKey(
        projectId: .eth,
        address: address,
        blockNumber: Decimal(12695817),
        direction: TransferDirection.outgoing.rawValue,
        nonce: Decimal(1507)
      )
      let transfer: Transfer = try db.read(key: ethereumTransfer, table: .completedTransfer)
      XCTAssertFalse(transfer.isPending)
      XCTAssert(transfer.blockNumber == 12695817)
      XCTAssert(transfer.nonce == 1507)
      XCTAssert(transfer.from!.address == address.hexString)
      XCTAssert(transfer.owner!.address == address.hexString)
      XCTAssert(transfer.to!.address == "0x14095009d85dd694ef5a9ccf9436baf719cb3588")
      XCTAssert(transfer.direction == .outgoing)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  private func transferReadChecksum(from table: MDBXTable) throws -> Int {
    let allResults: [Transfer] = try db.fetchAll(from: table)

    var resultChecksum = 0
    allResults.forEach {
      resultChecksum = resultChecksum ^ $0.ownerKey.address.hashValue ^ $0.tokenMetaKey.contractAddress.hashValue ^ $0.amount.hashValue ^ $0.blockNumber.hashValue ^ $0.txHash.hashValue ^ $0.nonce.hashValue
    }
    return resultChecksum
  }
  
  private func writeBalances() throws -> (checksum: Int, count: Int) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let encoder = JSONEncoder()
    

    let address = Data(hex: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1")
    let balances = try decoder.decode([Balance].self, from: balanceData)
    var checksum: Int = 0
    try balances.forEach {
      let balanceKey = BalanceKey(
        address: address,
        tokenMetaKey: .init(projectId: .eth, contractAddress: $0.contractAddress)
      )
      XCTAssertTrue(balanceKey.address == address.setLengthLeft(MDBXKeyLength.address))
      XCTAssertTrue(balanceKey.tokenMetaKey!.contractAddress == $0.contractAddress)
      
      try db.write(table: .balance, key: balanceKey, value: encoder.encode($0))
      checksum = checksum ^ $0.amount.hashValue ^ $0.contractAddress.hashValue
      db.commit(table: .balance)
    }
    
    return (checksum, balances.count)
  }
  
  private func writePrices(completionBlock: @escaping () -> Void) {
    let group = DispatchGroup()
    prices.enumerated().forEach {
      group.enter()
      let element = $0.element
      let offset = $0.offset
      
      let tokenMetaKey = TokenMetaKey(projectId: .eth, contractAddress: element.tokenMetaKey.contractAddress)
      let priceKey = PriceKey(tokenMetaKey: tokenMetaKey)
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .formatted(df)
      let encoded = try! encoder.encode($0.element)
      db.writeAsync(table: .price, key: priceKey.key, value: encoded) { success -> MDBXWriteAction in
        group.leave()
        if success == false {
          XCTFail("Failed to write data")
          return .none
        } else if offset == self.prices.count - 1 && success {
          debugPrint("================")
          debugPrint("Successful write")
          debugPrint("================")
          
          return .none
        } else if offset > 0 && offset % 5 == 0 && success {
          return .commit
        } else {
          return .none
        }
      }
    }
    
    group.notify(queue: DispatchQueue.main) {
      completionBlock()
    }
  }
  
  func writeDexes(completionBlock: @escaping () -> Void) {
    let group = DispatchGroup()
    let dexes = testDexItemsShouldDecode()

    dexes.enumerated().forEach {
      group.enter()
      let element = $0.element
      let offset = $0.offset
      
      let tokenMetaKey = element.tokenMetaKey
      let encoder = JSONEncoder()
      let encoded = try! encoder.encode($0.element)
      db.writeAsync(table: .dex, key: tokenMetaKey!.key, value: encoded) { success -> MDBXWriteAction in
        group.leave()
        if success == false {
          XCTFail("Failed to write data")
          return .none
        } else if offset == self.prices.count - 1 && success {
          debugPrint("================")
          debugPrint("Successful write")
          debugPrint("================")
          
          return .commit
        } else if offset > 0 && offset % 5 == 0 && success {
          return .commit
        } else {
          return .none
        }
      }
    }

    group.notify(queue: DispatchQueue.main) {
      completionBlock()
    }
  }
  
  func testDropTableNotFoundError() {
    do {
      try db.drop(table: .dex, delete: false)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
