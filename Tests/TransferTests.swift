//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/27/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf

private let testJson = """
[
  {
    "hash": "0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x9121c7f5976692bc7f97cd380d19a7a7e1d0e0f5",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0x98e8a88dc25efc7897acb329548380b9da4c2270",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15617880,
    "status": "SUCCESS",
    "timestamp": "2022-09-26T13:35:35.000Z",
    "nonce": 12,
    "nft": {
      "id": "5560",
      "name": "UMYC",
      "symbol": "UMYC",
      "image": "https://lh3.googleusercontent.com/HvjEho3QIS5m0_w-yVmNdT1yaFHNVVGA6gsdEV0hcECTLAyKZZpkCVxPnI4ab6gg8oBswAm2gNa6DyA2IZn6Dv75W0sLpypV6zmvWQ"
    },
    "cursor": "1"
  },
  {
    "hash": "0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x1a6c0e1dd4eee3",
    "delta": "0x4547258d1ec000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15617880,
    "status": "SUCCESS",
    "timestamp": "2022-09-26T13:35:35.000Z",
    "nonce": 12,
    "cursor": "1"
  },
  {
    "hash": "0xdd37f0f80c7332e62b863fbcca309200df4c7fa98cd133d42502a077ac724e89",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x76be3b62873462d2142405439777e971754e8e77",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0x632fff377be88f7b07631631293a4d834bde149b",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15584009,
    "status": "SUCCESS",
    "timestamp": "2022-09-21T20:05:11.000Z",
    "nonce": 11,
    "nft": {
      "id": "10762",
      "name": "parallel",
      "symbol": "LL",
      "image": "https://lh3.googleusercontent.com/Glvhg40WKQB9ufYFSkTmNEqfk5SQfomMSWCKuJCOuBqK1azmwWb5J9vILiTcBBsNVZkyV78uKcoDHngnBGsI5Gr6RyZOIDItS6ooqg"
    },
    "cursor": "1"
  },
  {
    "hash": "0xdd37f0f80c7332e62b863fbcca309200df4c7fa98cd133d42502a077ac724e89",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x6a6bd8156e0861",
    "delta": "0x31bcd5ba641800",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15584009,
    "status": "SUCCESS",
    "timestamp": "2022-09-21T20:05:11.000Z",
    "nonce": 11,
    "cursor": "1"
  },
  {
    "hash": "0xa83d0a3e80a2f9c1a1bb6c3201bc6203674d670fdac5a7f7a88ad426f8ce1c9c",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x6400311e9c0887c2c8c559a419be89bbd7a6af9f",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0x4237e57e82b1ec2e572c0ef64689fb2886a5e5e6",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15580790,
    "status": "SUCCESS",
    "timestamp": "2022-09-21T09:10:59.000Z",
    "nonce": 10,
    "nft": {
      "id": "104",
      "name": "web3nation",
      "symbol": "w3",
      "image": "https://lh3.googleusercontent.com/8VaXTLXyMO4CSd9K4c4Ng7pcHOJFDGw7n0IXwoyz6UEVpy4dbA-bNO6ffbIbg4yggDOiz0JXxB5JLGYH0X0pxN-oT5XVjMPRUMdIiA"
    },
    "cursor": "1"
  },
  {
    "hash": "0xa83d0a3e80a2f9c1a1bb6c3201bc6203674d670fdac5a7f7a88ad426f8ce1c9c",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0xa2c154391a9a3b",
    "delta": "0xa4d88ddd94000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15580790,
    "status": "SUCCESS",
    "timestamp": "2022-09-21T09:10:59.000Z",
    "nonce": 10,
    "cursor": "1"
  },
  {
    "hash": "0x9a63062f14c935f6c0d2f25d71d32b13066e434d0460b92f9d7c444d32e70ab6",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x3d201c408b9eaddc76e27ad45d986c4d9c13e0c6",
    "type": "TRANSFER",
    "balance": "0x6d6",
    "delta": "0x6d6",
    "from": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15566030,
    "status": "SUCCESS",
    "timestamp": "2022-09-19T07:18:47.000Z",
    "nonce": 196,
    "cursor": "1"
  },
  {
    "hash": "0xe98a4b748cdd13d51d68576778de22b7a34386854fcb9b818dd84802f545c01c",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0x4cfd50f62df880cccd5e6d489e9ea3039819aad1",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15558755,
    "status": "SUCCESS",
    "timestamp": "2022-09-18T06:49:47.000Z",
    "nonce": 5,
    "nft": {
      "id": "64678271420419587238734041740204762672190823835094097529705205305670747542121",
      "name": "ENS",
      "symbol": "ENS",
      "image": "https://openseauserdata.com/files/862af14df7f2e3d80c0fa8572fbc8acc.svg"
    },
    "cursor": "1"
  },
  {
    "hash": "0xe98a4b748cdd13d51d68576778de22b7a34386854fcb9b818dd84802f545c01c",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0xb2e6592e9c1456",
    "delta": "0x384665653dff6",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15558755,
    "status": "SUCCESS",
    "timestamp": "2022-09-18T06:49:47.000Z",
    "nonce": 5,
    "cursor": "1"
  },
  {
    "hash": "0xde2785cd401177fc3ad411873c6f32bb8b3d77cdc50b424158ba2362a0326cd8",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x02beed1404c69e62b76af6dbdae41bd98bca2eab",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0xcc3e440a81c6d5bdfea98e03f2e877fc6a182a1a",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15556062,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T21:46:23.000Z",
    "nonce": 4,
    "nft": {
      "id": "4508",
      "name": "posers",
      "symbol": "pos",
      "image": "https://openseauserdata.com/files/66e5bfe59e1d3b36530cfe79c44ba801.svg"
    },
    "cursor": "1"
  },
  {
    "hash": "0xde2785cd401177fc3ad411873c6f32bb8b3d77cdc50b424158ba2362a0326cd8",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0xb937adc4987818",
    "delta": "0xbfd8b6c1df0000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15556062,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T21:46:23.000Z",
    "nonce": 4,
    "cursor": "1"
  },
  {
    "hash": "0x21da2f531c012940636cfec0a40e98d8ae57504fb0346927f9c0058017159c7b",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x17c50d02e833ec6",
    "delta": "0x1c110215b9c000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15555808,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T20:54:59.000Z",
    "nonce": 3,
    "cursor": "1"
  },
  {
    "hash": "0x314222c8d0a27daf20a9b8feb491b7abf2b15ae2fc282540ddc53d826371db60",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0x76be3b62873462d2142405439777e971754e8e77",
    "type": "TRANSFER",
    "balance": "0x1",
    "delta": "0x1",
    "from": "0x61a50f6a1ad8aab8efce0036470adfd8ceef65f8",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15555772,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T20:47:47.000Z",
    "nonce": 2,
    "nft": {
      "id": "10878",
      "name": "parallel",
      "symbol": "LL",
      "image": "https://lh3.googleusercontent.com/U9-Bq-ebydhnRINq4MZdu8jtjXlLcAU7ezsjj6K0nyKI5ay3M8bEkGgBRrZmA5spKO8XW-ketiu2RtuP9kA_DQBOcIamZjVH1_X3Ug"
    },
    "cursor": "1"
  },
  {
    "hash": "0x314222c8d0a27daf20a9b8feb491b7abf2b15ae2fc282540ddc53d826371db60",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x19cc15e5207640c",
    "delta": "0x2386f26fc10000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15555772,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T20:47:47.000Z",
    "nonce": 2,
    "cursor": "1"
  },
  {
    "hash": "0x53fb323ea331e40b52ad01ff5d787e0b7b4214f965e91084183c0d8aab60a0c6",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x1c650c975f0b0e9",
    "delta": "0x93cafac6a8000",
    "from": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "to": "0x00000000006c3852cbef3e08e8df289169ede581",
    "block_number": 15555203,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T18:51:47.000Z",
    "nonce": 0,
    "cursor": "1"
  },
  {
    "hash": "0xbac71a4960443728c310d8fb8de2205c8a22ecc471eed7774d6857a7c36652bb",
    "address": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "type": "TRANSFER",
    "balance": "0x1d278a783024000",
    "delta": "0x1d278a783024000",
    "from": "0x8216874887415e2650d12d53ff53516f04a74fd7",
    "to": "0x810fb3b90f7261878c9d3326923e3547d7713971",
    "block_number": 15554728,
    "status": "SUCCESS",
    "timestamp": "2022-09-17T17:15:59.000Z",
    "nonce": 240535,
    "cursor": "1"
  }
]
"""

private let projectId = "0x00"

final class Transfer_tests: XCTestCase {
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
  
  func testTransfers() async {
    do {
      let objects = try Transfer.array(fromJSONString: testJson, chain: .eth)
      let keysAndObjects: [(MDBXKey, MDBXObject)] = objects.lazy.map ({
        return ($0.key, $0)
      })
      
      debugPrint(keysAndObjects.map({ $0.0.key.hexString }))
      try await db.write(table: .transfer, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
      let transfers: [Transfer] = try db.fetch(range: .all(limit: 10), from: .transfer, order: .asc)
      
      debugPrint(transfers.map({$0.block}))
      
//      let dexItem = DexItem(chain: MDBXChain(rawValue: Data(hex: "0x1")), contractAddress: "0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", order: 0)
//      let dexItem2 = DexItem(chain: .eth, contractAddress: "0x00c17f958d2ee523a2206206994597c13d831ec7", order: 2)
//      let dexItem3 = DexItem(chain: .eth, contractAddress: "0x00aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE", order: 1)
      
//      try await db.write(table: .orderedDex, keysAndObjects: [
//        (dexItem.alternateKey!, dexItem),
//        (dexItem2.alternateKey!, dexItem2),
//        (dexItem3.alternateKey!, dexItem3)
//      ], mode: .append)
      
//      try await db.write(table: .dex, keysAndObjects: [
//        (dexItem.key, dexItem),
//        (dexItem2.key, dexItem2),
//        (dexItem3.key, dexItem3)
//      ], mode: .append)
//
//      var dex = try dexItem.meta.dexItem.meta.dexItem
//      dex.order = 0
      
//      let renBTC: TokenMeta = try db.read(key: TokenMetaKey(chain: .eth, contractAddress: .renBTC), table: .tokenMeta)
//      XCTAssertEqual(renBTC.contract_address, .renBTC)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testDoubleSave() async {
    do {
      let txs1 =
      """
      [{"hash":"0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737452","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x1db4d4b5c2770","delta":"0xa8e30bebe115c1","from":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","to":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","block_number":11318917,"status":"SUCCESS","timestamp":"2020-11-24T04:49:18.000Z","nonce":0,"cursor":"1"},{"hash":"0xdc99245a8fc795125a2c36fa5bd5c311f40c6d0d445370ef41eda5fb3f6664ef","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0xae5ac248305d31","delta":"0x9c9749104fdd31","from":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","to":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","block_number":11312010,"status":"SUCCESS","timestamp":"2020-11-23T03:21:35.000Z","nonce":98,"cursor":"1"},{"hash":"0x2a78aca0440cc0419173c944cfe2f436c8a558380942937be052e737f649da2e","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0xc12d1c73ee7dc3615ba4e37e4abfdbddfa38907e","type":"TRANSFER","balance":"0x0","delta":"0x5f5e100","from":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","to":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","block_number":10145908,"status":"FAIL","timestamp":"2020-05-27T05:25:05.000Z","nonce":13,"cursor":"1"},{"hash":"0xc02be610b50fa70f22601b3eef7855001455029fa2c0740fb5f9ca42f0653f0c","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x11c37937e08000","delta":"0x11688627664000","from":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","to":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","block_number":10055106,"status":"SUCCESS","timestamp":"2020-05-13T02:29:58.000Z","nonce":10,"cursor":"1"},{"hash":"0x76f38af08e7b540c00efb639ce63dd662ec0a7950eeab4bd7eecba9699b8cecc","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x5af3107a4000","delta":"0x5af3107a4000","from":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","to":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","block_number":10055100,"status":"SUCCESS","timestamp":"2020-05-13T02:28:20.000Z","nonce":9,"cursor":"1"},{"hash":"0x3e9390ebc2fc6e7e6cefd8b933fcf3536cd3e57359b7ecd367612fde9b831933","address":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","contract_address":"0x80fb784b7ed66730e8b1dbd9820afd29931aab03","type":"TRANSFER","balance":"0x120a871cc0020000","delta":"0x120a871cc0020000","from":"0x14095009d85dd694ef5a9ccf9436baf719cb3588","to":"0x7fb1077e28b8c771330d323dbdc42e0623e05e3d","block_number":9958767,"status":"SUCCESS","timestamp":"2020-04-28T04:20:53.000Z","nonce":8,"cursor":"1"}]
      """
      
      let txs2 =
      """
      [{"hash":"0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x9121c7f5976692bc7f97cd380d19a7a7e1d0e0f5","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0x98e8a88dc25efc7897acb329548380b9da4c2270","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15617880,"status":"SUCCESS","timestamp":"2022-09-26T13:35:35.000Z","nonce":12,"nft":{"id":"5560","name":"UMYC","symbol":"UMYC","image":"https://lh3.googleusercontent.com/HvjEho3QIS5m0_w-yVmNdT1yaFHNVVGA6gsdEV0hcECTLAyKZZpkCVxPnI4ab6gg8oBswAm2gNa6DyA2IZn6Dv75W0sLpypV6zmvWQ"},"cursor":"1"},{"hash":"0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x1a6c0e1dd4eee3","delta":"0x4547258d1ec000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15617880,"status":"SUCCESS","timestamp":"2022-09-26T13:35:35.000Z","nonce":12,"cursor":"1"},{"hash":"0xdd37f0f80c7332e62b863fbcca309200df4c7fa98cd133d42502a077ac724e89","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x76be3b62873462d2142405439777e971754e8e77","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0x632fff377be88f7b07631631293a4d834bde149b","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15584009,"status":"SUCCESS","timestamp":"2022-09-21T20:05:11.000Z","nonce":11,"nft":{"id":"10762","name":"parallel","symbol":"LL","image":"https://lh3.googleusercontent.com/Glvhg40WKQB9ufYFSkTmNEqfk5SQfomMSWCKuJCOuBqK1azmwWb5J9vILiTcBBsNVZkyV78uKcoDHngnBGsI5Gr6RyZOIDItS6ooqg"},"cursor":"1"},{"hash":"0xdd37f0f80c7332e62b863fbcca309200df4c7fa98cd133d42502a077ac724e89","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x6a6bd8156e0861","delta":"0x31bcd5ba641800","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15584009,"status":"SUCCESS","timestamp":"2022-09-21T20:05:11.000Z","nonce":11,"cursor":"1"},{"hash":"0xa83d0a3e80a2f9c1a1bb6c3201bc6203674d670fdac5a7f7a88ad426f8ce1c9c","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x6400311e9c0887c2c8c559a419be89bbd7a6af9f","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0x4237e57e82b1ec2e572c0ef64689fb2886a5e5e6","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15580790,"status":"SUCCESS","timestamp":"2022-09-21T09:10:59.000Z","nonce":10,"nft":{"id":"104","name":"web3nation","symbol":"w3","image":"https://lh3.googleusercontent.com/8VaXTLXyMO4CSd9K4c4Ng7pcHOJFDGw7n0IXwoyz6UEVpy4dbA-bNO6ffbIbg4yggDOiz0JXxB5JLGYH0X0pxN-oT5XVjMPRUMdIiA"},"cursor":"1"},{"hash":"0xa83d0a3e80a2f9c1a1bb6c3201bc6203674d670fdac5a7f7a88ad426f8ce1c9c","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0xa2c154391a9a3b","delta":"0xa4d88ddd94000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15580790,"status":"SUCCESS","timestamp":"2022-09-21T09:10:59.000Z","nonce":10,"cursor":"1"},{"hash":"0x9a63062f14c935f6c0d2f25d71d32b13066e434d0460b92f9d7c444d32e70ab6","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x3d201c408b9eaddc76e27ad45d986c4d9c13e0c6","type":"TRANSFER","balance":"0x6d6","delta":"0x6d6","from":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15566030,"status":"SUCCESS","timestamp":"2022-09-19T07:18:47.000Z","nonce":196,"cursor":"1"},{"hash":"0xe98a4b748cdd13d51d68576778de22b7a34386854fcb9b818dd84802f545c01c","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0x4cfd50f62df880cccd5e6d489e9ea3039819aad1","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15558755,"status":"SUCCESS","timestamp":"2022-09-18T06:49:47.000Z","nonce":5,"nft":{"id":"64678271420419587238734041740204762672190823835094097529705205305670747542121","name":"ENS","symbol":"ENS","image":"https://openseauserdata.com/files/862af14df7f2e3d80c0fa8572fbc8acc.svg"},"cursor":"1"},{"hash":"0xe98a4b748cdd13d51d68576778de22b7a34386854fcb9b818dd84802f545c01c","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0xb2e6592e9c1456","delta":"0x384665653dff6","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15558755,"status":"SUCCESS","timestamp":"2022-09-18T06:49:47.000Z","nonce":5,"cursor":"1"},{"hash":"0xde2785cd401177fc3ad411873c6f32bb8b3d77cdc50b424158ba2362a0326cd8","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x02beed1404c69e62b76af6dbdae41bd98bca2eab","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0xcc3e440a81c6d5bdfea98e03f2e877fc6a182a1a","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15556062,"status":"SUCCESS","timestamp":"2022-09-17T21:46:23.000Z","nonce":4,"nft":{"id":"4508","name":"posers","symbol":"pos","image":"https://openseauserdata.com/files/66e5bfe59e1d3b36530cfe79c44ba801.svg"},"cursor":"1"},{"hash":"0xde2785cd401177fc3ad411873c6f32bb8b3d77cdc50b424158ba2362a0326cd8","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0xb937adc4987818","delta":"0xbfd8b6c1df0000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15556062,"status":"SUCCESS","timestamp":"2022-09-17T21:46:23.000Z","nonce":4,"cursor":"1"},{"hash":"0x21da2f531c012940636cfec0a40e98d8ae57504fb0346927f9c0058017159c7b","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x17c50d02e833ec6","delta":"0x1c110215b9c000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15555808,"status":"SUCCESS","timestamp":"2022-09-17T20:54:59.000Z","nonce":3,"cursor":"1"},{"hash":"0x314222c8d0a27daf20a9b8feb491b7abf2b15ae2fc282540ddc53d826371db60","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0x76be3b62873462d2142405439777e971754e8e77","type":"TRANSFER","balance":"0x1","delta":"0x1","from":"0x61a50f6a1ad8aab8efce0036470adfd8ceef65f8","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15555772,"status":"SUCCESS","timestamp":"2022-09-17T20:47:47.000Z","nonce":2,"nft":{"id":"10878","name":"parallel","symbol":"LL","image":"https://lh3.googleusercontent.com/U9-Bq-ebydhnRINq4MZdu8jtjXlLcAU7ezsjj6K0nyKI5ay3M8bEkGgBRrZmA5spKO8XW-ketiu2RtuP9kA_DQBOcIamZjVH1_X3Ug"},"cursor":"1"},{"hash":"0x314222c8d0a27daf20a9b8feb491b7abf2b15ae2fc282540ddc53d826371db60","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x19cc15e5207640c","delta":"0x2386f26fc10000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15555772,"status":"SUCCESS","timestamp":"2022-09-17T20:47:47.000Z","nonce":2,"cursor":"1"},{"hash":"0x53fb323ea331e40b52ad01ff5d787e0b7b4214f965e91084183c0d8aab60a0c6","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x1c650c975f0b0e9","delta":"0x93cafac6a8000","from":"0x810fb3b90f7261878c9d3326923e3547d7713971","to":"0x00000000006c3852cbef3e08e8df289169ede581","block_number":15555203,"status":"SUCCESS","timestamp":"2022-09-17T18:51:47.000Z","nonce":0,"cursor":"1"},{"hash":"0xbac71a4960443728c310d8fb8de2205c8a22ecc471eed7774d6857a7c36652bb","address":"0x810fb3b90f7261878c9d3326923e3547d7713971","contract_address":"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee","type":"TRANSFER","balance":"0x1d278a783024000","delta":"0x1d278a783024000","from":"0x8216874887415e2650d12d53ff53516f04a74fd7","to":"0x810fb3b90f7261878c9d3326923e3547d7713971","block_number":15554728,"status":"SUCCESS","timestamp":"2022-09-17T17:15:59.000Z","nonce":240535,"cursor":"1"}]
      """
      
      var objects = try Transfer.array(fromJSONString: txs1, chain: .eth)
      var keysAndObjects: [(MDBXKey, MDBXObject)] = objects.lazy.map ({
        return ($0.key, $0)
      })
      
      try await db.write(table: .transfer, keysAndObjects: keysAndObjects, mode: .recommended(.transfer))
      
      objects = try Transfer.array(fromJSONString: txs2, chain: .eth)
      keysAndObjects = objects.lazy.map ({
        return ($0.key, $0)
      })
      
      try await db.write(table: .transfer, keysAndObjects: keysAndObjects, mode: .recommended(.transfer))
      
      
      let transfers: [Transfer] = try db.fetch(range: TransferKey.range(chain: .eth, address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"), limit: 3),
                                               from: .transfer, order: .desc)
      
      let transfers2: [Transfer] = try db.fetch(range: TransferKey.range(chain: .eth, address: .unknown("0x810fb3b90f7261878c9d3326923e3547d7713971"), limit: 3),
                                               from: .transfer, order: .desc)
      
      debugPrint(transfers.map({ $0.hash }))
      debugPrint(transfers2.map({ $0.hash }))
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testKey() {
//    let tokenKey = TokenKey(chain: .eth, address: "0x112233445566778899aabbccddeeff0011223344", contractAddress: "0x5566778899aabbccddeeff001122334455667788")
//    XCTAssertEqual(tokenKey.address, "0x112233445566778899aabbccddeeff0011223344")
//    XCTAssertEqual(tokenKey.contractAddress, "0x5566778899aabbccddeeff001122334455667788")
//    XCTAssertEqual(tokenKey.key.hexString, "0x00000000000000000000000000000001112233445566778899aabbccddeeff00112233445566778899aabbccddeeff001122334455667788")
  }
}

//["0xbac71a4960443728c310d8fb8de2205c8a22ecc471eed7774d6857a7c36652bb", "0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737452", "0xdc99245a8fc795125a2c36fa5bd5c311f40c6d0d445370ef41eda5fb3f6664ef"]
//["0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e", "0xa404cbb8b4f30192fe84b8f8d71731f9bd371076a78f77de7c47dd44d1eb538e", "0xdd37f0f80c7332e62b863fbcca309200df4c7fa98cd133d42502a077ac724e89"]

//["0x3e9390ebc2fc6e7e6cefd8b933fcf3536cd3e57359b7ecd367612fde9b831933", "0x76f38af08e7b540c00efb639ce63dd662ec0a7950eeab4bd7eecba9699b8cecc", "0xc02be610b50fa70f22601b3eef7855001455029fa2c0740fb5f9ca42f0653f0c"]
//["0xbac71a4960443728c310d8fb8de2205c8a22ecc471eed7774d6857a7c36652bb", "0x53fb323ea331e40b52ad01ff5d787e0b7b4214f965e91084183c0d8aab60a0c6", "0x314222c8d0a27daf20a9b8feb491b7abf2b15ae2fc282540ddc53d826371db60"]
