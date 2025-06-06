// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: _Account.proto
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

struct _Account: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Account address
  var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  /// GroupID, for future purposes. Could be used if we will need to manage few recoveryPhrases in the app
  var groupID: UInt32 {
    get {return _storage._groupID}
    set {_uniqueStorage()._groupID = newValue}
  }

  var source: _Account._Source {
    get {return _storage._source}
    set {_uniqueStorage()._source = newValue}
  }

  var type: _Account._Type {
    get {return _storage._type}
    set {_uniqueStorage()._type = newValue}
  }

  var keys: _Account._Keys {
    get {return _storage._keys ?? _Account._Keys()}
    set {_uniqueStorage()._keys = newValue}
  }
  /// Returns true if `keys` has been explicitly set.
  var hasKeys: Bool {return _storage._keys != nil}
  /// Clears the value of `keys`. Subsequent reads from it will return its default value.
  mutating func clearKeys() {_uniqueStorage()._keys = nil}

  var state: _Account._UserState {
    get {return _storage._state ?? _Account._UserState()}
    set {_uniqueStorage()._state = newValue}
  }
  /// Returns true if `state` has been explicitly set.
  var hasState: Bool {return _storage._state != nil}
  /// Clears the value of `state`. Subsequent reads from it will return its default value.
  mutating func clearState() {_uniqueStorage()._state = nil}

  var networkType: _NetworkType {
    get {return _storage._networkType ?? .evm}
    set {_uniqueStorage()._networkType = newValue}
  }
  /// Returns true if `networkType` has been explicitly set.
  var hasNetworkType: Bool {return _storage._networkType != nil}
  /// Clears the value of `networkType`. Subsequent reads from it will return its default value.
  mutating func clearNetworkType() {_uniqueStorage()._networkType = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// Source describes account source, like 'generated/restored in the app', or plain private key (for now, private key could be read-only)
  enum _Source: SwiftProtobuf.Enum, Swift.CaseIterable {
    typealias RawValue = Int
    case unknown // = 0

    /// Generated internally
    case recoveryPhrase // = 1

    /// Copy-paste of watch-only address or imprort of private key
    case privateKey // = 2

    /// External connection via WalletConnect
    case walletConnect // = 3
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .recoveryPhrase
      case 2: self = .privateKey
      case 3: self = .walletConnect
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .recoveryPhrase: return 1
      case .privateKey: return 2
      case .walletConnect: return 3
      case .UNRECOGNIZED(let i): return i
      }
    }

    // The compiler won't synthesize support with the UNRECOGNIZED case.
    static let allCases: [_Account._Source] = [
      .unknown,
      .recoveryPhrase,
      .privateKey,
      .walletConnect,
    ]

  }

  /// Type describes origin of account, like 'generated/restored in the app' or external source like 'WalletConnect'
  enum _Type: SwiftProtobuf.Enum, Swift.CaseIterable {
    typealias RawValue = Int

    /// Generated internally
    case `internal` // = 0

    /// Watch-only address
    case readOnly // = 1

    /// WalletConnect address
    case external // = 2
    case UNRECOGNIZED(Int)

    init() {
      self = .internal
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .internal
      case 1: self = .readOnly
      case 2: self = .external
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .internal: return 0
      case .readOnly: return 1
      case .external: return 2
      case .UNRECOGNIZED(let i): return i
      }
    }

    // The compiler won't synthesize support with the UNRECOGNIZED case.
    static let allCases: [_Account._Type] = [
      .internal,
      .readOnly,
      .external,
    ]

  }

  /// Keys describes related information for account, like eth_encryptionPublicKey or withdrawalPublicKey which is requires for ETH2 staking via Staked.us
  struct _Keys: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Now it's optional, since we're going to support external sources and plain private keys
    var derivationPath: String {
      get {return _derivationPath ?? String()}
      set {_derivationPath = newValue}
    }
    /// Returns true if `derivationPath` has been explicitly set.
    var hasDerivationPath: Bool {return self._derivationPath != nil}
    /// Clears the value of `derivationPath`. Subsequent reads from it will return its default value.
    mutating func clearDerivationPath() {self._derivationPath = nil}

    /// Derives from PrivateKey, we don't have an access to anonymizedId with address
    var anonymizedID: String {
      get {return _anonymizedID ?? String()}
      set {_anonymizedID = newValue}
    }
    /// Returns true if `anonymizedID` has been explicitly set.
    var hasAnonymizedID: Bool {return self._anonymizedID != nil}
    /// Clears the value of `anonymizedID`. Subsequent reads from it will return its default value.
    mutating func clearAnonymizedID() {self._anonymizedID = nil}

    /// Derives from PrivateKey, we don't have an access to encryptionPublicKey with address
    var encryptionPublicKey: String {
      get {return _encryptionPublicKey ?? String()}
      set {_encryptionPublicKey = newValue}
    }
    /// Returns true if `encryptionPublicKey` has been explicitly set.
    var hasEncryptionPublicKey: Bool {return self._encryptionPublicKey != nil}
    /// Clears the value of `encryptionPublicKey`. Subsequent reads from it will return its default value.
    mutating func clearEncryptionPublicKey() {self._encryptionPublicKey = nil}

    /// Derives from PrivateKey, we don't have an access to withdrawalPublicKey with address
    var withdrawalPublicKey: String {
      get {return _withdrawalPublicKey ?? String()}
      set {_withdrawalPublicKey = newValue}
    }
    /// Returns true if `withdrawalPublicKey` has been explicitly set.
    var hasWithdrawalPublicKey: Bool {return self._withdrawalPublicKey != nil}
    /// Clears the value of `withdrawalPublicKey`. Subsequent reads from it will return its default value.
    mutating func clearWithdrawalPublicKey() {self._withdrawalPublicKey = nil}

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}

    fileprivate var _derivationPath: String? = nil
    fileprivate var _anonymizedID: String? = nil
    fileprivate var _encryptionPublicKey: String? = nil
    fileprivate var _withdrawalPublicKey: String? = nil
  }

  /// UserState describes user-related information, like 'name' of account or 'isHidden'
  struct _UserState: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Account order, used sorting of accounts
    var order: UInt32 = 0

    /// Account name, user's name of account
    var name: String = String()

    /// Represent if account was hidden
    var isHidden: Bool = false

    /// DEPRECATED: Represents hidden NFT in account
    ///
    /// NOTE: This field was marked as deprecated in the .proto file.
    var deprecatedNftHidden: [String] = []

    /// DEPRECATED: Represents favorite NFT in account
    ///
    /// NOTE: This field was marked as deprecated in the .proto file.
    var deprecatedNftFavorite: [String] = []

    /// Represents hidden NFT in account
    var nftHidden: [_Account._UserState._NFT] = []

    /// Represents favorite NFT in account
    var nftFavorite: [_Account._UserState._NFT] = []

    /// Represents hidden tokens in account
    var tokenHidden: [_Account._UserState._Token] = []

    var unknownFields = SwiftProtobuf.UnknownStorage()

    /// Represents NFT which is hidden or favorite
    struct _NFT: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Represents NFTAsset key
      var key: String = String()

      /// Represents timestamp, of last changed date
      var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
        get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
        set {_timestamp = newValue}
      }
      /// Returns true if `timestamp` has been explicitly set.
      var hasTimestamp: Bool {return self._timestamp != nil}
      /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
      mutating func clearTimestamp() {self._timestamp = nil}

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}

      fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
    }

    /// Represents Token which is hidden or favorite
    struct _Token: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Represents TokenMeta contractAddress
      var contractAddress: String = String()

      /// Represents locked version of token (ERC-777)
      var locked: Bool = false

      /// Represents timestamp, of last changed date
      var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
        get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
        set {_timestamp = newValue}
      }
      /// Returns true if `timestamp` has been explicitly set.
      var hasTimestamp: Bool {return self._timestamp != nil}
      /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
      mutating func clearTimestamp() {self._timestamp = nil}

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}

      fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
    }

    init() {}
  }

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension _Account: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "_Account"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "groupID"),
    3: .same(proto: "source"),
    4: .same(proto: "type"),
    5: .same(proto: "keys"),
    6: .same(proto: "state"),
    7: .same(proto: "networkType"),
  ]

  fileprivate class _StorageClass {
    var _address: String = String()
    var _groupID: UInt32 = 0
    var _source: _Account._Source = .unknown
    var _type: _Account._Type = .internal
    var _keys: _Account._Keys? = nil
    var _state: _Account._UserState? = nil
    var _networkType: _NetworkType? = nil

    #if swift(>=5.10)
      // This property is used as the initial default value for new instances of the type.
      // The type itself is protecting the reference to its storage via CoW semantics.
      // This will force a copy to be made of this reference when the first mutation occurs;
      // hence, it is safe to mark this as `nonisolated(unsafe)`.
      static nonisolated(unsafe) let defaultInstance = _StorageClass()
    #else
      static let defaultInstance = _StorageClass()
    #endif

    private init() {}

    init(copying source: _StorageClass) {
      _address = source._address
      _groupID = source._groupID
      _source = source._source
      _type = source._type
      _keys = source._keys
      _state = source._state
      _networkType = source._networkType
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularStringField(value: &_storage._address) }()
        case 2: try { try decoder.decodeSingularUInt32Field(value: &_storage._groupID) }()
        case 3: try { try decoder.decodeSingularEnumField(value: &_storage._source) }()
        case 4: try { try decoder.decodeSingularEnumField(value: &_storage._type) }()
        case 5: try { try decoder.decodeSingularMessageField(value: &_storage._keys) }()
        case 6: try { try decoder.decodeSingularMessageField(value: &_storage._state) }()
        case 7: try { try decoder.decodeSingularEnumField(value: &_storage._networkType) }()
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 1)
      }
      if _storage._groupID != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._groupID, fieldNumber: 2)
      }
      if _storage._source != .unknown {
        try visitor.visitSingularEnumField(value: _storage._source, fieldNumber: 3)
      }
      if _storage._type != .internal {
        try visitor.visitSingularEnumField(value: _storage._type, fieldNumber: 4)
      }
      try { if let v = _storage._keys {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      } }()
      try { if let v = _storage._state {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      } }()
      try { if let v = _storage._networkType {
        try visitor.visitSingularEnumField(value: v, fieldNumber: 7)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Account, rhs: _Account) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._address != rhs_storage._address {return false}
        if _storage._groupID != rhs_storage._groupID {return false}
        if _storage._source != rhs_storage._source {return false}
        if _storage._type != rhs_storage._type {return false}
        if _storage._keys != rhs_storage._keys {return false}
        if _storage._state != rhs_storage._state {return false}
        if _storage._networkType != rhs_storage._networkType {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Account._Source: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "RECOVERY_PHRASE"),
    2: .same(proto: "PRIVATE_KEY"),
    3: .same(proto: "WALLET_CONNECT"),
  ]
}

extension _Account._Type: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "INTERNAL"),
    1: .same(proto: "READ_ONLY"),
    2: .same(proto: "EXTERNAL"),
  ]
}

extension _Account._Keys: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Account.protoMessageName + "._Keys"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "derivationPath"),
    2: .same(proto: "anonymizedId"),
    3: .same(proto: "encryptionPublicKey"),
    4: .same(proto: "withdrawalPublicKey"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self._derivationPath) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self._anonymizedID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self._encryptionPublicKey) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self._withdrawalPublicKey) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._derivationPath {
      try visitor.visitSingularStringField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._anonymizedID {
      try visitor.visitSingularStringField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._encryptionPublicKey {
      try visitor.visitSingularStringField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._withdrawalPublicKey {
      try visitor.visitSingularStringField(value: v, fieldNumber: 4)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Account._Keys, rhs: _Account._Keys) -> Bool {
    if lhs._derivationPath != rhs._derivationPath {return false}
    if lhs._anonymizedID != rhs._anonymizedID {return false}
    if lhs._encryptionPublicKey != rhs._encryptionPublicKey {return false}
    if lhs._withdrawalPublicKey != rhs._withdrawalPublicKey {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Account._UserState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Account.protoMessageName + "._UserState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "order"),
    2: .same(proto: "name"),
    3: .same(proto: "isHidden"),
    4: .standard(proto: "deprecated_nftHidden"),
    5: .standard(proto: "deprecated_nftFavorite"),
    6: .same(proto: "nftHidden"),
    7: .same(proto: "nftFavorite"),
    8: .same(proto: "tokenHidden"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.order) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.isHidden) }()
      case 4: try { try decoder.decodeRepeatedStringField(value: &self.deprecatedNftHidden) }()
      case 5: try { try decoder.decodeRepeatedStringField(value: &self.deprecatedNftFavorite) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.nftHidden) }()
      case 7: try { try decoder.decodeRepeatedMessageField(value: &self.nftFavorite) }()
      case 8: try { try decoder.decodeRepeatedMessageField(value: &self.tokenHidden) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.order != 0 {
      try visitor.visitSingularUInt32Field(value: self.order, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.isHidden != false {
      try visitor.visitSingularBoolField(value: self.isHidden, fieldNumber: 3)
    }
    if !self.deprecatedNftHidden.isEmpty {
      try visitor.visitRepeatedStringField(value: self.deprecatedNftHidden, fieldNumber: 4)
    }
    if !self.deprecatedNftFavorite.isEmpty {
      try visitor.visitRepeatedStringField(value: self.deprecatedNftFavorite, fieldNumber: 5)
    }
    if !self.nftHidden.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.nftHidden, fieldNumber: 6)
    }
    if !self.nftFavorite.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.nftFavorite, fieldNumber: 7)
    }
    if !self.tokenHidden.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.tokenHidden, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Account._UserState, rhs: _Account._UserState) -> Bool {
    if lhs.order != rhs.order {return false}
    if lhs.name != rhs.name {return false}
    if lhs.isHidden != rhs.isHidden {return false}
    if lhs.deprecatedNftHidden != rhs.deprecatedNftHidden {return false}
    if lhs.deprecatedNftFavorite != rhs.deprecatedNftFavorite {return false}
    if lhs.nftHidden != rhs.nftHidden {return false}
    if lhs.nftFavorite != rhs.nftFavorite {return false}
    if lhs.tokenHidden != rhs.tokenHidden {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Account._UserState._NFT: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Account._UserState.protoMessageName + "._NFT"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "key"),
    2: .same(proto: "timestamp"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.key) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.key.isEmpty {
      try visitor.visitSingularStringField(value: self.key, fieldNumber: 1)
    }
    try { if let v = self._timestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Account._UserState._NFT, rhs: _Account._UserState._NFT) -> Bool {
    if lhs.key != rhs.key {return false}
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Account._UserState._Token: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Account._UserState.protoMessageName + "._Token"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "contract_address"),
    2: .same(proto: "locked"),
    3: .same(proto: "timestamp"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.contractAddress) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.locked) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.contractAddress.isEmpty {
      try visitor.visitSingularStringField(value: self.contractAddress, fieldNumber: 1)
    }
    if self.locked != false {
      try visitor.visitSingularBoolField(value: self.locked, fieldNumber: 2)
    }
    try { if let v = self._timestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Account._UserState._Token, rhs: _Account._UserState._Token) -> Bool {
    if lhs.contractAddress != rhs.contractAddress {return false}
    if lhs.locked != rhs.locked {return false}
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
