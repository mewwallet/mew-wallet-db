//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 3/31/25.
//

import Foundation
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf
import Testing

@Suite("Token tests")
fileprivate final class TokenTests {
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
  
  @Test("Test simple evm token")
  func evmToken() async throws {
    var token = Token(chain: .eth,
                      address: Address("0x00c17f958d2ee523a2206206994597c13d831ec7"),
                      contractAddress: ._primary,
                      rawAmount: "123456789")
    try await db.write(table: .token, key: token.key, object: token, mode: .recommended(.token))
    let tokens: [Token] = try db.fetch(range: .all, from: .token, order: .asc)
    
    debugPrint(tokens)
    debugPrint(token)
    
//    
//    var account = Account(order: 0,
//                          address: "0x00c17f958d2ee523a2206206994597c13d831ec7",
//                          name: "My account",
//                          source: .recoveryPhrase,
//                          type: .internal,
//                          network: .evm,
//                          derivationPath: nil,
//                          anonymizedId: "anonID",
//                          encryptionPublicKey: nil,
//                          withdrawalPublicKey: nil,
//                          isHidden: true)
//    
//    try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
//    let accounts: [Account] = try db.fetch(range: .all, from: .account, order: .asc)
//    
//    #expect(accounts.count == 1)
//    #expect(accounts.first == account)
//    
//    let key = AccountKey(chain: .evm, address: "0x00c17f958d2ee523a2206206994597c13d831ec7")
//    var dbAccount: Account = try db.read(key: key, table: .account)
//    #expect(account == dbAccount)
//    
//    account.name = "new name"
//    try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
//    dbAccount = try db.read(key: key, table: .account)
//    #expect(account == dbAccount)
  }
  
  @Test("Test simple bitcoin token")
  func btcToken() async throws {
    var token = Token(chain: .eth,
                      address: Address("bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"),
                      contractAddress: ._primary,
                      rawAmount: "123456789")
    try await db.write(table: .token, key: token.key, object: token, mode: .recommended(.token))
    let tokens: [Token] = try db.fetch(range: .all, from: .token, order: .asc)
    
//    0x0000000000000000000000000000000100c17f958d2ee523a2206206994597c13d831ec7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
//    0x0000000000000000000000000000000103002a626331713863366673687732646c77756e37656b6e397177663337637532726e3735357570637036656ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    
    let key = tokens.first?.key as? TokenKey
    
    debugPrint(tokens)
    debugPrint(key?.address)
    debugPrint(key?.contractAddress)
    debugPrint(token)
  }
  
  @Test("Test Address encodedData")
  func addressEncodedData() async throws {
    let address = Address("bc1pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp5z9v2w")
    #expect(address.addressType == .bitcoin(.taproot))
    #expect(address.rawValue == "bc1pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp5z9v2w")
    #expect(address.encodedData.hexString == "0x04005b62633170707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070357a39763277")
    #expect(address.encodedData.count == 94)
    
    let data = Data(hex: "0x04005b62633170707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070357a39763277")
    let restoredAddress = Address(encodedData: data)
    #expect(address == restoredAddress)
    #expect(restoredAddress.rawValue == "bc1pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp5z9v2w")
    #expect(restoredAddress.addressType == .bitcoin(.taproot))
    
    let evmAddress: Address = Address.unknown(.evm, "0x00c17f958d2ee523a2206206994597c13d831ec7")
    #expect(evmAddress.encodedData.hexString == "0x01001400c17f958d2ee523a2206206994597c13d831ec7")
    let evmData = Data(hex: "0x00c17f958d2ee523a2206206994597c13d831ec7")
    let restoredEVMAddress = Address(encodedData: evmData)
    #expect(restoredEVMAddress.addressType == .evm)
    #expect(restoredEVMAddress.rawValue == "0x00c17f958d2ee523a2206206994597c13d831ec7")
  }
  
  @Test("asd")
  func asdasd() async throws {
    let coder = MDBXKeyCoder()
    
    let data = coder.encode(fields: [
      MDBXChain.eth,
      Address("bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"),
      Address._primary
    ])
    debugPrint(data.hexString)
    
    let decoded = try coder.decode(data: data, fields: [
      .chain,
      .address,
      .legacyAddress
    ])
    debugPrint(decoded)
  }
  
  @Test("Test bitcoint account")
  func bitcoinAccount() async throws {
    let btcAccount = Account(order: 0,
                             address: "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el",
                             name: "My account",
                             source: .recoveryPhrase,
                             type: .internal,
                             derivationPath: nil,
                             anonymizedId: "anonID",
                             encryptionPublicKey: nil,
                             withdrawalPublicKey: nil,
                             isHidden: false)
    
    let evmAccount = Account(order: 0,
                             address: "0x00c17f958d2ee523a2206206994597c13d831ec7",
                             name: "My account",
                             source: .recoveryPhrase,
                             type: .internal,
                             network: .evm,
                             derivationPath: nil,
                             anonymizedId: "anonID",
                             encryptionPublicKey: nil,
                             withdrawalPublicKey: nil,
                             isHidden: true)
    
    try await db.write(table: .account, key: btcAccount.key, object: btcAccount, mode: .recommended(.account))
    try await db.write(table: .account, key: evmAccount.key, object: evmAccount, mode: .recommended(.account))
    let accounts: [Account] = try db.fetch(range: .all, from: .account, order: .asc)
    #expect(accounts.count == 2)
    
    debugPrint(accounts)
    
    let btckey = AccountKey(chain: .bitcoin, address: "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el")
    let dbbtcAccount: Account = try db.read(key: btckey, table: .account)
    
    let restoredBtcKey = try #require(dbbtcAccount.key as? AccountKey)
    #expect(restoredBtcKey.chain == btckey.chain)
    #expect(restoredBtcKey.address == btckey.address)
    
    let evmkey = AccountKey(chain: .evm, address: "0x00c17f958d2ee523a2206206994597c13d831ec7")
    let dbevmAccount: Account = try db.read(key: evmkey, table: .account)
    
    let restoredevmKey = try #require(dbevmAccount.key as? AccountKey)
    #expect(restoredevmKey.chain == evmkey.chain)
    #expect(restoredevmKey.address == evmkey.address)
    
    #expect(btcAccount == dbbtcAccount)
    #expect(evmAccount == dbevmAccount)
  }
}
