//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 10/6/25.
//

import Foundation

// MARK: - String + Solana detection

extension String {
  fileprivate static let solanaAlphabet: String = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  
  func satisfy(alphabet: String, length: Range<Int>) -> Bool {
    guard self.count >= length.lowerBound && self.count <= length.upperBound else { return false }
    let characterSet = CharacterSet(charactersIn: alphabet)
    return self.unicodeScalars.allSatisfy { characterSet.contains($0) }
  }
}

// MARK: - Address + Solana detection

package extension Address {
  static func isProbableSolanaAddress(_ value: String) -> Bool {
    // Solana addresses are base58, typically length 32...44 characters
    guard value.satisfy(alphabet: String.solanaAlphabet, length: 32..<45) else { return false }
    guard let decoded = try? value.decodeBase58(alphabet: String.solanaAlphabet) else { return false }
    return decoded.count == 32
  }
}

extension String {
  public enum Base58Error: Error {
    case invalidCharacter
  }

  fileprivate func decodeBase58(alphabet: String) throws -> Data {
    let alphabetBytes = Array(alphabet.utf8)
    let inputBytes = Array(self.utf8)
    guard !alphabetBytes.isEmpty else { return Data() }

    // Count leading zeros (leader = first alphabet char)
    let leader = alphabetBytes[0]
    var zeros = 0
    for b in inputBytes {
      if b == leader { zeros += 1 } else { break }
    }

    // Map each char to its index in the alphabet
    var indices = [Int]()
    indices.reserveCapacity(inputBytes.count)
    for ch in inputBytes {
      guard let idx = alphabetBytes.firstIndex(of: ch) else {
        throw Base58Error.invalidCharacter
      }
      indices.append(idx)
    }

    // Convert base58 -> base256 without BigInt
    var output = [UInt8]() // big-endian base256 bytes
    for idx in indices {
      var carry = idx
      // multiply current output by 58 and add idx
      for i in stride(from: output.count - 1, through: 0, by: -1) {
        let val = Int(output[i]) * 58 + carry
        output[i] = UInt8(val & 0xff)
        carry = val >> 8
      }
      while carry > 0 {
        output.insert(UInt8(carry & 0xff), at: 0)
        carry >>= 8
      }
    }

    // Prepend the zero prefix for each leading leader char
    if zeros > 0 {
      return Data(repeating: 0, count: zeros) + Data(output)
    } else {
      return Data(output)
    }
  }

  package func decodeBase58() throws -> Data {
    return try decodeBase58(alphabet: Self.solanaAlphabet)
  }
}
