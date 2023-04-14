import Foundation

/// Chain + Order + ContractAddress + hash(EntryTitle)
public final class OrderedCollectionTokenMetaKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var order: UInt16 { return self._order }
  public var contractAddress: Address { return self._contractAddress }
  public var hash: Data { return self._entryTitle }

  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _orderRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order }()
  private lazy var _order: UInt16 = {
    let value = key[_orderRange].withUnsafeBytes { $0.load(as: UInt16.self) }
    return UInt16(bigEndian: value)
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _orderRange.endIndex..<MDBXKeyLength.address }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  private lazy var _entryTitleRange: Range<Int> = { _contractAddressRange.endIndex..<key.count }()
  private lazy var _entryTitle: Data = {
    return key[_entryTitleRange]
  }()

  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, order: UInt16, contractAddress: Address, hash: Data) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)

    self.key = chainPart + orderPart + hashPart
  }
  
  public convenience init(
    chain: MDBXChain,
    order: UInt16,
    contractAddress: Address,
    entryTitle: String
  ) {
    let entryTitleData = entryTitle.data(using: .utf8) ?? ""
    self.init(
      chain: chain,
      order: order,
      contractAddress: contractAddress,
      hash: entryTitleData.sha256
    )
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.orderedCollectionTokenMeta else { return nil }
    self.key = data
  }
}

// MARK: - OrderedDexItemKey + Sendable

extension OrderedCollectionTokenMetaKey: @unchecked Sendable {}
