//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation
import Testing
@testable import mew_wallet_db

@Suite("MDBXKeyCoder tests")
struct MDBXKeyCoderTests {
  @Test("Encoding")
  func encoding() async throws {
    let coder = MDBXKeyCoder()
    
    let data = coder.encode(fields: [
      MDBXChain.eth,
      Address("bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"),
      Address._primary
    ])
    
    #expect(data.hexString == "0x0000000000000000000000000000000103002a626331713863366673687732646c77756e37656b6e397177663337637532726e3735357570637036656ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
  }
  
  @Test("Decoding")
  func decoding() async throws {
    let coder = MDBXKeyCoder()
    
    let data = Data(hex: "0x0000000000000000000000000000000103002a626331713863366673687732646c77756e37656b6e397177663337637532726e3735357570637036656ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
    
    let decoded = try coder.decode(data: data, fields: [
      .chain,
      .address,
      .legacyAddress
    ])
    
    #expect(decoded.count == 3)
    #expect((decoded[0] as? MDBXChain) == MDBXChain.eth)
    #expect((decoded[1] as? Address) == Address.unknown(.bitcoin(.segwit), "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"))
    #expect((decoded[2] as? Address) == Address._primary)
  }
  
  @Test("Test MDBXKeyComponents")
  func components() async throws {
    let coder = MDBXKeyCoder()
    
    let chain: MDBXChain = .arbitrum
    let offset: UInt16 = 255
    let address = Address(rawValue: "0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9")
    
    let encoded = coder.encode(fields: [chain, offset, address])
    debugPrint(encoded.hexString)
    
////    let data = Data(hex: "0x0000000000000000000000000000a4b1010014fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9")
////    let key = OrderedDexItemKey(data: data)
////    debugPrint(key)
////
////    0x0000000000000000000000000000a4b1 010014fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9
////    0x0000000000000000000000000000a4b1 00ff010014fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9
////    0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9
////    0x00c17f958d2ee523a2206206994597c13d831ec7
//    
//    let data = Data(hex: "0x0000000000000000000000000000000103002a626331713863366673687732646c77756e37656b6e397177663337637532726e3735357570637036656ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
//    
//    let decoded = coder.decode(data: data, fields: [
//      .chain,
//      .address,
//      .legacyAddress
//    ])
//    
//    #expect(decoded.count == 3)
//    #expect((decoded[0] as? MDBXChain) == MDBXChain.eth)
//    #expect((decoded[1] as? Address) == Address.unknown(.bitcoin(.segwit), "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"))
//    #expect((decoded[2] as? Address) == Address._primary)
  }
  
  @Test("asd")
  func asd() async throws {
    let data = Data(hex: "0x0000000000000000000000000000a4b1010014fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9")
    let key = OrderedDexItemKey(data: data)
    debugPrint(key)
//
//    0x0000000000000000000000000000a4b1010014fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9
//    0x00c17f958d2ee523a2206206994597c13d831ec7
  }
}
