//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 8/2/22.
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
    "address": "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1",
    "name": "ETH Blocks (by MEW)",
    "description": "**ETH Blocks** is an NFT series created by MEW (MyEtherWallet) representing mined Ethereum blocks and their properties. Go to [MEW](https://www.myetherwallet.com/wallet/dapps/eth-blocks) to mint and own your favorite block – whether it's a special block number, the block of your first transaction, or a block that contains a tx with a special message. Own a part of history with ETH Blocks by MEW.",
    "image": "https://lh3.googleusercontent.com/ZnIoAna1KSv-WZyTs06ft6FcKy0ZFStWA12iCKIEtVI4n6EsB2RSJ_zOlRzPDqeiYgNZBqGEw7VrgBlZHQbawkWjvpJNoDqfnOjc=s120",
    "schema_type": "ERC721",
    "contract_address": "0x01234567bac6ff94d7e4f0ee23119cf848f93245",
    "contract_name": "ETH Blocks",
    "contract_symbol": "ETHB",
    "social": {
      "website": "https://www.myetherwallet.com/wallet/dapps/eth-blocks",
      "telegram": "https://t.me/myetherwallet"
    },
    "stats": {
      "count": "1331",
      "owners": "719"
    },
    "assets": [
      {
        "token_id": "9999999",
        "contract_address": "0x01234567bac6ff94d7e4f0ee23119cf848f93245",
        "name": "Block #9999999",
        "description": "Completed on 5/4/2020, this iconic piece of history included 187 transactions. Note the use of 9,995,773 in gas. With a size of 31,769 bytes, this immutable piece will look fantastic next to a pillar.",
        "traits": [
          {
            "trait": "sequence",
            "count": 132,
            "value": "Palindrome",
            "percentage": "0.099174",
            "display_type": "STRING"
          },
          {
            "trait": "author",
            "count": 16,
            "value": "0x04668ec2f57cc15c381b461b9fedab5d451c8f7f",
            "percentage": "0.012021",
            "display_type": "STRING"
          }
        ],
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/J6HMVlVATeRoXyYEqZidlrAc1tb-B0lyCeWcdOHuC5mZX9j426xnitVnb48TyBBW54rVDjKEFcyukOkT05jNqP-bNwdva2FB7dSJ"
          }
        ],
        "last_sale": {
          "price": "55000000000000000000",
          "token": {
            "contract_address": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            "symbol": "WETH",
            "name": "WETH",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WETH-0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2-eth.png",
            "website": "https://weth.io/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/ethereum/0x01234567bac6ff94d7e4f0ee23119cf848f93245/9999999"
      }
    ]
  },
  {
    "address": "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1",
    "name": "ETH Blocks (by MEW)",
    "description": "**ETH Blocks** is an NFT series created by MEW (MyEtherWallet) representing mined Ethereum blocks and their properties. Go to [MEW](https://www.myetherwallet.com/wallet/dapps/eth-blocks) to mint and own your favorite block – whether it's a special block number, the block of your first transaction, or a block that contains a tx with a special message. Own a part of history with ETH Blocks by MEW.",
    "image": "https://lh3.googleusercontent.com/ZnIoAna1KSv-WZyTs06ft6FcKy0ZFStWA12iCKIEtVI4n6EsB2RSJ_zOlRzPDqeiYgNZBqGEw7VrgBlZHQbawkWjvpJNoDqfnOjc=s120",
    "schema_type": "ERC721",
    "contract_address": "0xabc34567bac6ff94d7e4f0ee23119cf848f93245",
    "contract_name": "ETH Blocks",
    "contract_symbol": "ETHB",
    "social": {
      "website": "https://www.myetherwallet.com/wallet/dapps/eth-blocks",
      "telegram": "https://t.me/myetherwallet"
    },
    "stats": {
      "count": "1331",
      "owners": "719"
    },
    "assets": [
      {
        "token_id": "8888888",
        "contract_address": "0xabc34567bac6ff94d7e4f0ee23119cf848f93245",
        "name": "Block #9999999",
        "description": "Completed on 5/4/2020, this iconic piece of history included 187 transactions. Note the use of 9,995,773 in gas. With a size of 31,769 bytes, this immutable piece will look fantastic next to a pillar.",
        "traits": [
          {
            "trait": "sequence",
            "count": 132,
            "value": "Palindrome",
            "percentage": "0.099174",
            "display_type": "STRING"
          },
          {
            "trait": "author",
            "count": 16,
            "value": "0x04668ec2f57cc15c381b461b9fedab5d451c8f7f",
            "percentage": "0.012021",
            "display_type": "STRING"
          },
          {
            "trait": "Registration Date",
            "display_type": "DATE",
            "count": 4,
            "value": "1580935689",
            "percentage": "0.000003"
          }
        ],
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/J6HMVlVATeRoXyYEqZidlrAc1tb-B0lyCeWcdOHuC5mZX9j426xnitVnb48TyBBW54rVDjKEFcyukOkT05jNqP-bNwdva2FB7dSJ"
          }
        ],
        "opensea_url": "https://opensea.io/assets/ethereum/0x01234567bac6ff94d7e4f0ee23119cf848f93245/9999999"
      }
    ]
  }
]
"""

final class diff_tests: XCTestCase {
  
  private var db: MEWwalletDBImpl!
  private let table: MDBXTableName = .nftCollection
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
      try self.db.start(path: self._path, tables: MDBXTableName.allCases, readOnly: false)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
  }
  
  override func tearDown() {
    super.tearDown()
    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func test() async {
    do {
      let account = Account(order: 0,
                            address: "0x4Dd2a335d53BCD17445EBF4504c5632c13A818A1",
                            name: "My account",
                            source: .recoveryPhrase,
                            type: .internal,
                            network: .evm,
                            derivationPath: nil,
                            anonymizedId: "anonID",
                            encryptionPublicKey: nil,
                            withdrawalPublicKey: nil,
                            isHidden: true)
      
      try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
      
      let objects = try NFTCollection.array(fromJSONString: testJson, chain: .eth)
      var keysAndObjects: [(any MDBXKey, any MDBXObject)] = objects.lazy.map { ($0.key, $0) }
      
      try await db.write(table: .nftCollection, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
      
      keysAndObjects = try objects.collectAssets.lazy.map { ($0.key, $0) }
      
      try await db.write(table: .nftAsset, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
      
      keysAndObjects = try objects.collectMetas(chain: .eth).lazy.map { ($0.key, $0) }
      
      try await db.write(table: .tokenMeta, keysAndObjects: keysAndObjects, mode: .recommended(.tokenMeta))
      
      var asset = try objects.collectAssets.last!
      asset.database = db
      
      XCTAssertFalse(asset.isFavorite(chain: .eth))
      
      if let accountToUpdate = asset.toggleFavorite() {
        try await db.write(table: .account, key: accountToUpdate.key, object: accountToUpdate, mode: .recommended(.account))
      } else {
        XCTFail("Bad update")
      }
      XCTAssertTrue(asset.isFavorite(chain: .eth))
      if let accountToUpdate = asset.toggleFavorite() {
        try await db.write(table: .account, key: accountToUpdate.key, object: accountToUpdate, mode: .recommended(.account))
      }
      XCTAssertFalse(asset.isFavorite(chain: .eth))
      
      XCTAssertEqual(try db.count(range: .all, from: .nftCollection), 2)
      XCTAssertEqual(try db.count(range: .all, from: .nftAsset), 2)
      XCTAssertEqual(try db.count(range: .all, from: .tokenMeta), 1)
      
      var oldKeys: [NFTCollectionKey] = try db.fetchKeys(range: .with(start: NFTCollectionKey(chain: .eth, address: Address(account_address), lowerRange: true),
                                                                      end: NFTCollectionKey(chain: .eth, address: Address(account_address), lowerRange: false)),
                                                              from: .nftCollection,
                                                         order: .asc)
      oldKeys.forEach {
        debugPrint($0.key.hexString)
      }
      
      debugPrint("===")
      let first = oldKeys.removeFirst()
      oldKeys.append(first)
      
      oldKeys.forEach {
        debugPrint($0.key.hexString)
      }
      
      debugPrint("===")
      let transaction = MDBXTransaction(db.environment!.environment)
      try transaction.begin(flags: [.readOnly])
      defer {
        try? transaction.abort()
      }
      oldKeys.sort { lhs, rhs in
        var lhsData = lhs.key
        var rhsData = rhs.key
        return transaction.compare(a: &lhsData, b: &rhsData, database: db.environment!.getDatabase(for: .nftCollection)!) <= 0
      }
      
      oldKeys.forEach {
        debugPrint($0.key.hexString)
      }
      
      var randomKeys = [
        Data(hex: "0x0123456789aa"),
        Data(hex: "0xabc751934934"),
        Data(hex: "0x0012bcabdcd4"),
        Data(hex: "0xac85105bcd99"),
        Data(hex: "0xac351959bdcd"),
        Data(hex: "0x0012bcabdcd3"),
        Data(hex: "0xabcdabcdabcd"),
      ]
      randomKeys.sort { lhs, rhs in
        var lhsData = lhs
        var rhsData = rhs
        return transaction.compare(a: &lhsData, b: &rhsData, database: db.environment!.getDatabase(for: .nftCollection)!) <= 0
      }
      randomKeys.forEach {
        debugPrint($0.hexString)
      }
    } catch {
      debugPrint(error.localizedDescription)
      XCTFail(error.localizedDescription)
    }
  }
}
