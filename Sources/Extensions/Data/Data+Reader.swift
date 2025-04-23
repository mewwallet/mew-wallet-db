//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/22/25.
//

import Foundation

enum DataReaderError: Swift.Error {
  case outOfBounds
}

extension Data {
  /// Moves the cursor forward by `offsetBy` bytes and returns the traversed range.
  ///
  /// - Parameters:
  ///   - cursor: The current index in the `Data` buffer (advanced in-place).
  ///   - offsetBy: Number of bytes to move forward.
  /// - Returns: A `Range<Data.Index>` representing the advanced region.
  /// - Throws: `DataReaderError.outOfBounds` if the cursor exceeds buffer bounds.
  @discardableResult
  internal func seek(_ cursor: inout Index, offsetBy: Int) throws(DataReaderError) -> Range<Self.Index> {
    guard cursor + offsetBy <= self.endIndex else { throw .outOfBounds }
    let newCursor = index(cursor, offsetBy: offsetBy)
    let range = cursor..<newCursor
    cursor = newCursor
    return range
  }
  
  /// Reads `offsetBy` bytes starting at the given cursor and advances it.
  ///
  /// - Parameters:
  ///   - cursor: Cursor position to read from (advanced in-place).
  ///   - offsetBy: Number of bytes to read.
  /// - Returns: A `SubSequence` view into the original `Data`.
  /// - Throws: `DataReaderError.outOfBounds` if out of bounds.
  internal func read(_ cursor: inout Index, offsetBy: Int) throws(DataReaderError) -> Data.SubSequence {
    guard cursor + offsetBy <= self.endIndex else { throw .outOfBounds }
    let newCursor = index(cursor, offsetBy: offsetBy)
    let data = self[cursor..<newCursor]
    cursor = newCursor
    return data
  }
  
  /// Reads `offsetBy` bytes from the cursor, reverses them, and returns the result.
  ///
  /// - Parameters:
  ///   - cursor: Cursor position to read from (advanced in-place).
  ///   - offsetBy: Number of bytes to read.
  /// - Returns: A reversed `Data` slice.
  /// - Throws: `DataReaderError.outOfBounds` if range is invalid.
  internal func readReversed(_ cursor: inout Index, offsetBy: Int) throws(DataReaderError) -> Data.SubSequence {
    return try Data(read(&cursor, offsetBy: offsetBy).reversed())
  }
  
  /// Reads a single byte at the cursor and advances.
  ///
  /// - Parameter cursor: Cursor to read from.
  /// - Returns: The byte read at the current position.
  /// - Throws: `DataReaderError.outOfBounds` if there is no data to read.
  internal func read(_ cursor: inout Index) throws(DataReaderError) -> Self.Element {
    return try self.read(&cursor, offsetBy: 1).first!
  }
  
  /// Reads a fixed-width integer of type `T` from `cursor` using big-endian byte order.
  ///
  /// - Parameter cursor: Cursor to read from (advanced in-place).
  /// - Returns: The decoded integer value.
  /// - Throws: `.outOfBounds` or `.badSize` if the read is invalid.
  internal func readBE<T: FixedWidthInteger>(_ cursor: inout Index) throws(DataReaderError) -> T {
    let size = MemoryLayout<T>.size
    guard cursor + size <= self.endIndex else { throw .outOfBounds }
    let newCursor = index(cursor, offsetBy: size-1)
    let result: T = try self[cursor...newCursor].readBE()
    cursor = newCursor
    return result
  }
  
  /// Decodes a fixed-width integer from the data buffer assuming big-endian layout.
  ///
  /// - Returns: A decoded integer of type `T`.
  /// - Throws: `.badSize` if the data length does not match `T`'s size.
  internal func readBE<T: FixedWidthInteger>() throws(DataReaderError) -> T {
    guard self.count == MemoryLayout<T>.size else { throw .outOfBounds }

    return self.withUnsafeBytes {
      let value = $0.loadUnaligned(as: T.self)
      return T(bigEndian: value)
    }
  }
}
