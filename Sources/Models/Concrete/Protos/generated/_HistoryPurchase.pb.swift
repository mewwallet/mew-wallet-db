// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: _HistoryPurchase.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// Represent Historical Purchase record
struct _HistoryPurchase: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Account's address
  var address: String = String()

  /// Transaction ID on provider side
  var transactionID: String = String()

  /// Fiat amount
  var fiatAmount: String = String()

  /// Fiat currency
  var fiatCurrency: String = String()

  /// Crypto currency amount
  var cryptoAmount: String = String()

  /// Token contract address
  var cryptoCurrency: _ChainedContractAddress {
    get {return _cryptoCurrency ?? _ChainedContractAddress()}
    set {_cryptoCurrency = newValue}
  }
  /// Returns true if `cryptoCurrency` has been explicitly set.
  var hasCryptoCurrency: Bool {return self._cryptoCurrency != nil}
  /// Clears the value of `cryptoCurrency`. Subsequent reads from it will return its default value.
  mutating func clearCryptoCurrency() {self._cryptoCurrency = nil}

  /// Status of purchase
  var status: String = String()

  /// Provider
  var provider: String = String()

  /// Timestamp of the purchase
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_timestamp = newValue}
  }
  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool {return self._timestamp != nil}
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() {self._timestamp = nil}

  /// Encrypted details of the order
  var orderDetails: String {
    get {return _orderDetails ?? String()}
    set {_orderDetails = newValue}
  }
  /// Returns true if `orderDetails` has been explicitly set.
  var hasOrderDetails: Bool {return self._orderDetails != nil}
  /// Clears the value of `orderDetails`. Subsequent reads from it will return its default value.
  mutating func clearOrderDetails() {self._orderDetails = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _cryptoCurrency: _ChainedContractAddress? = nil
  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _orderDetails: String? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension _HistoryPurchase: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "_HistoryPurchase"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .standard(proto: "transaction_id"),
    3: .standard(proto: "fiat_amount"),
    4: .standard(proto: "fiat_currency"),
    5: .standard(proto: "crypto_amount"),
    6: .standard(proto: "crypto_currency"),
    7: .same(proto: "status"),
    8: .same(proto: "provider"),
    9: .same(proto: "timestamp"),
    10: .standard(proto: "order_details"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.address) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.transactionID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.fiatAmount) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.fiatCurrency) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.cryptoAmount) }()
      case 6: try { try decoder.decodeSingularMessageField(value: &self._cryptoCurrency) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.status) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.provider) }()
      case 9: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 10: try { try decoder.decodeSingularStringField(value: &self._orderDetails) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 1)
    }
    if !self.transactionID.isEmpty {
      try visitor.visitSingularStringField(value: self.transactionID, fieldNumber: 2)
    }
    if !self.fiatAmount.isEmpty {
      try visitor.visitSingularStringField(value: self.fiatAmount, fieldNumber: 3)
    }
    if !self.fiatCurrency.isEmpty {
      try visitor.visitSingularStringField(value: self.fiatCurrency, fieldNumber: 4)
    }
    if !self.cryptoAmount.isEmpty {
      try visitor.visitSingularStringField(value: self.cryptoAmount, fieldNumber: 5)
    }
    try { if let v = self._cryptoCurrency {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    } }()
    if !self.status.isEmpty {
      try visitor.visitSingularStringField(value: self.status, fieldNumber: 7)
    }
    if !self.provider.isEmpty {
      try visitor.visitSingularStringField(value: self.provider, fieldNumber: 8)
    }
    try { if let v = self._timestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    } }()
    try { if let v = self._orderDetails {
      try visitor.visitSingularStringField(value: v, fieldNumber: 10)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _HistoryPurchase, rhs: _HistoryPurchase) -> Bool {
    if lhs.address != rhs.address {return false}
    if lhs.transactionID != rhs.transactionID {return false}
    if lhs.fiatAmount != rhs.fiatAmount {return false}
    if lhs.fiatCurrency != rhs.fiatCurrency {return false}
    if lhs.cryptoAmount != rhs.cryptoAmount {return false}
    if lhs._cryptoCurrency != rhs._cryptoCurrency {return false}
    if lhs.status != rhs.status {return false}
    if lhs.provider != rhs.provider {return false}
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs._orderDetails != rhs._orderDetails {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
