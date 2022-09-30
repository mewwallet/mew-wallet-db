//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/29/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf

private let testJson = """
{"featured":[{"contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","price":"1335.32","volume_24h":"11879418220","name":"Ethereum","symbol":"ETH","decimals":18,"timestamp":"2022-09-29T22:30:53.149Z","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png"},{"contract_address":"0x6b175474e89094c44da98b954eedeac495271d0f","price":"0.999943","volume_24h":"434612362","name":"Dai","symbol":"DAI","decimals":18,"timestamp":"2022-09-29T22:26:19.545Z","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/DAI-0x6B175474E89094C44Da98b954EedeAC495271d0F-eth.png"},{"contract_address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48","price":"1.001","volume_24h":"3565243715","name":"USD Coin","symbol":"USDC","decimals":6,"timestamp":"2022-09-29T22:30:32.724Z","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48-eth.png"},{"contract_address":"0xdac17f958d2ee523a2206206994597c13d831ec7","price":"1.001","volume_24h":"43728385952","name":"Tether","symbol":"USDT","decimals":6,"timestamp":"2022-09-29T22:30:50.818Z","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdAC17F958D2ee523a2206206994597C13D831ec7-eth.png"},{"contract_address":"0x2260fac5e5542a773aa44fbcfedf7c193bc2c599","price":"19469.16","volume_24h":"250937661","name":"Wrapped Bitcoin","symbol":"WBTC","decimals":8,"timestamp":"2022-09-29T22:30:37.701Z","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WBTC-0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599-eth.png"}],"tokens":[{"contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","price":"1335.32","volume_24h":"11879418220","name":"Ethereum","symbol":"ETH","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png","decimals":18,"timestamp":"2022-09-29T22:30:53.149Z"},{"contract_address":"0xdac17f958d2ee523a2206206994597c13d831ec7","price":"1.001","volume_24h":"43728385952","name":"Tether","symbol":"USDT","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDT-0xdAC17F958D2ee523a2206206994597C13D831ec7-eth.png","decimals":6,"timestamp":"2022-09-29T22:30:50.818Z"},{"contract_address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48","price":"1.001","volume_24h":"3565243715","name":"USD Coin","symbol":"USDC","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/USDC-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48-eth.png","decimals":6,"timestamp":"2022-09-29T22:30:32.724Z"},{"contract_address":"0x4fabb145d64652a948d72533023f6e7a623c7c53","price":"1.001","volume_24h":"7130742600","name":"Binance USD","symbol":"BUSD","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/BUSD-0x4Fabb145d64652a948d72533023f6E7A623C7C53-eth.png","decimals":18,"timestamp":"2022-09-29T22:30:25.531Z"},{"contract_address":"0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce","price":"0.00001109","volume_24h":"179799160","name":"Shiba Inu","symbol":"SHIB","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/SHIB-0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE-eth.png","decimals":18,"timestamp":"2022-09-29T22:30:15.228Z"},{"contract_address":"0x6b175474e89094c44da98b954eedeac495271d0f","price":"0.999943","volume_24h":"434612362","name":"Dai","symbol":"DAI","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/DAI-0x6B175474E89094C44Da98b954EedeAC495271d0F-eth.png","decimals":18,"timestamp":"2022-09-29T22:26:19.545Z"},{"contract_address":"0xae7ab96520de3a18e5e111b5eaab095312d7fe84","price":"1332.11","volume_24h":"16941855","name":"Lido Staked Ether","symbol":"stETH","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/STETH-0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84-eth.png","decimals":18,"timestamp":"2022-09-29T22:30:02.417Z"},{"contract_address":"0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0","price":"0.758331","volume_24h":"288597025","name":"Polygon","symbol":"MATIC","icon":"https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/MATIC-0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0-eth.png","decimals":18,"timestamp":"2022-09-29T22:30:54.272Z"}]}
"""

private let projectId = "0x00"

final class SwapListV4_tests: XCTestCase {
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
  
  func testSwapListV4() async {
    do {
      let objects = try SwapListV4Wrapper(jsonString: testJson, chain: .eth)
      debugPrint(objects.featured_dexItems)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
