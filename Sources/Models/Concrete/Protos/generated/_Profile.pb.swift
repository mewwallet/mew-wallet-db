// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: _Profile.proto
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

struct _Profile: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Stores settings object
  var settings: _Profile._Settings {
    get {return _storage._settings ?? _Profile._Settings()}
    set {_uniqueStorage()._settings = newValue}
  }
  /// Returns true if `settings` has been explicitly set.
  var hasSettings: Bool {return _storage._settings != nil}
  /// Clears the value of `settings`. Subsequent reads from it will return its default value.
  mutating func clearSettings() {_uniqueStorage()._settings = nil}

  /// Stores status object
  var status: _Profile._Status {
    get {return _storage._status ?? _Profile._Status()}
    set {_uniqueStorage()._status = newValue}
  }
  /// Returns true if `status` has been explicitly set.
  var hasStatus: Bool {return _storage._status != nil}
  /// Clears the value of `status`. Subsequent reads from it will return its default value.
  mutating func clearStatus() {_uniqueStorage()._status = nil}

  /// Stores share code
  var shareCode: String {
    get {return _storage._shareCode ?? String()}
    set {_uniqueStorage()._shareCode = newValue}
  }
  /// Returns true if `shareCode` has been explicitly set.
  var hasShareCode: Bool {return _storage._shareCode != nil}
  /// Clears the value of `shareCode`. Subsequent reads from it will return its default value.
  mutating func clearShareCode() {_uniqueStorage()._shareCode = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// Represents Profile settings section
  struct _Settings: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Stores array of addresses associated with profile
    var addresses: [_Profile._Settings._Address] = []

    /// Stores user's timezone name
    var timezone: String = String()

    /// Stores Portfolio tracker settings
    var portfolioTracker: _Profile._Settings._PortfolioTracker {
      get {return _portfolioTracker ?? _Profile._Settings._PortfolioTracker()}
      set {_portfolioTracker = newValue}
    }
    /// Returns true if `portfolioTracker` has been explicitly set.
    var hasPortfolioTracker: Bool {return self._portfolioTracker != nil}
    /// Clears the value of `portfolioTracker`. Subsequent reads from it will return its default value.
    mutating func clearPortfolioTracker() {self._portfolioTracker = nil}

    /// Stores user's timezone gmt offset
    var gmtOffset: Int64 = 0

    /// Stores user's push token
    var pushToken: String = String()

    /// Stores user's platform (iOS, Android)
    var platform: String = String()

    /// Stores notifications settings flags
    var notifications: UInt32 = 0

    /// Stores structure of multichain addresses associated with the profile
    var multichainAddresses: _Profile._Settings._Multichain {
      get {return _multichainAddresses ?? _Profile._Settings._Multichain()}
      set {_multichainAddresses = newValue}
    }
    /// Returns true if `multichainAddresses` has been explicitly set.
    var hasMultichainAddresses: Bool {return self._multichainAddresses != nil}
    /// Clears the value of `multichainAddresses`. Subsequent reads from it will return its default value.
    mutating func clearMultichainAddresses() {self._multichainAddresses = nil}

    var unknownFields = SwiftProtobuf.UnknownStorage()

    /// Represents notifications settings
    enum _Notifications: SwiftProtobuf.Enum, Swift.CaseIterable {
      typealias RawValue = Int

      /// Disable all push notifications
      case disabled // = 0

      /// 'outgoing transaction notification' flag
      case outgoingTx // = 1

      /// 'incoming transaction notification' flag
      case incomingTx // = 2

      /// 'Global announcement notification' flag
      case announcements // = 4

      /// 'Security updates notification' flag
      case security // = 8

      /// 'Big movers notification' flag
      case bigMovers // = 16

      /// 'Season start announcement'
      case energySeasonStart // = 32

      /// 'Season end announcement'
      case energySeasonEnd // = 64
      case UNRECOGNIZED(Int)

      init() {
        self = .disabled
      }

      init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .disabled
        case 1: self = .outgoingTx
        case 2: self = .incomingTx
        case 4: self = .announcements
        case 8: self = .security
        case 16: self = .bigMovers
        case 32: self = .energySeasonStart
        case 64: self = .energySeasonEnd
        default: self = .UNRECOGNIZED(rawValue)
        }
      }

      var rawValue: Int {
        switch self {
        case .disabled: return 0
        case .outgoingTx: return 1
        case .incomingTx: return 2
        case .announcements: return 4
        case .security: return 8
        case .bigMovers: return 16
        case .energySeasonStart: return 32
        case .energySeasonEnd: return 64
        case .UNRECOGNIZED(let i): return i
        }
      }

      // The compiler won't synthesize support with the UNRECOGNIZED case.
      static let allCases: [_Profile._Settings._Notifications] = [
        .disabled,
        .outgoingTx,
        .incomingTx,
        .announcements,
        .security,
        .bigMovers,
        .energySeasonStart,
        .energySeasonEnd,
      ]

    }

    /// Represents Profile associated addresses
    struct _Address: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Store address
      var address: String = String()

      /// Stores address's flags
      var flags: UInt32 = 0

      var unknownFields = SwiftProtobuf.UnknownStorage()

      /// Possible flags for each address
      enum _AddressFlags: SwiftProtobuf.Enum, Swift.CaseIterable {
        typealias RawValue = Int

        /// All disabled
        case disabled // = 0

        /// Address must be included in weekly portfolio tracker
        case includeInWeeklyPortfolioTracker // = 1

        /// Address must be included in daily portfolio tracker
        case includeInDailyPortfolioTracker // = 2

        /// Type of address is watch-only
        case typeWatchOnly // = 64

        /// Type of address is internal
        case typeInternal // = 128
        case UNRECOGNIZED(Int)

        init() {
          self = .disabled
        }

        init?(rawValue: Int) {
          switch rawValue {
          case 0: self = .disabled
          case 1: self = .includeInWeeklyPortfolioTracker
          case 2: self = .includeInDailyPortfolioTracker
          case 64: self = .typeWatchOnly
          case 128: self = .typeInternal
          default: self = .UNRECOGNIZED(rawValue)
          }
        }

        var rawValue: Int {
          switch self {
          case .disabled: return 0
          case .includeInWeeklyPortfolioTracker: return 1
          case .includeInDailyPortfolioTracker: return 2
          case .typeWatchOnly: return 64
          case .typeInternal: return 128
          case .UNRECOGNIZED(let i): return i
          }
        }

        // The compiler won't synthesize support with the UNRECOGNIZED case.
        static let allCases: [_Profile._Settings._Address._AddressFlags] = [
          .disabled,
          .includeInWeeklyPortfolioTracker,
          .includeInDailyPortfolioTracker,
          .typeWatchOnly,
          .typeInternal,
        ]

      }

      init() {}
    }

    /// Represents Portfolio tracker
    struct _PortfolioTracker: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Stores Weekly Portfolio tracker settings
      var weekly: _Profile._Settings._PortfolioTracker._TrackerTime {
        get {return _weekly ?? _Profile._Settings._PortfolioTracker._TrackerTime()}
        set {_weekly = newValue}
      }
      /// Returns true if `weekly` has been explicitly set.
      var hasWeekly: Bool {return self._weekly != nil}
      /// Clears the value of `weekly`. Subsequent reads from it will return its default value.
      mutating func clearWeekly() {self._weekly = nil}

      /// Stores Daily Portfolio tracker settings
      var daily: _Profile._Settings._PortfolioTracker._TrackerTime {
        get {return _daily ?? _Profile._Settings._PortfolioTracker._TrackerTime()}
        set {_daily = newValue}
      }
      /// Returns true if `daily` has been explicitly set.
      var hasDaily: Bool {return self._daily != nil}
      /// Clears the value of `daily`. Subsequent reads from it will return its default value.
      mutating func clearDaily() {self._daily = nil}

      var unknownFields = SwiftProtobuf.UnknownStorage()

      /// Represents Portfolio tracker settings (daily/weekly)
      struct _TrackerTime: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        var enabled: Bool = false

        var timestamp: String = String()

        var unknownFields = SwiftProtobuf.UnknownStorage()

        init() {}
      }

      init() {}

      fileprivate var _weekly: _Profile._Settings._PortfolioTracker._TrackerTime? = nil
      fileprivate var _daily: _Profile._Settings._PortfolioTracker._TrackerTime? = nil
    }

    struct _Multichain: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Stores array of evm addresses associated with profile
      var evm: [_Profile._Settings._Address] = []

      /// Stores array of bitcoin addresses associated with profile
      var btc: [_Profile._Settings._Address] = []

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}
    }

    init() {}

    fileprivate var _portfolioTracker: _Profile._Settings._PortfolioTracker? = nil
    fileprivate var _multichainAddresses: _Profile._Settings._Multichain? = nil
  }

  /// Represents status of Profile
  struct _Status: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Represents array of products with trial eligibility
    var products: [_Profile._Status._Product] = []

    /// Stores last updated timestamp
    var lastUpdate: SwiftProtobuf.Google_Protobuf_Timestamp {
      get {return _lastUpdate ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
      set {_lastUpdate = newValue}
    }
    /// Returns true if `lastUpdate` has been explicitly set.
    var hasLastUpdate: Bool {return self._lastUpdate != nil}
    /// Clears the value of `lastUpdate`. Subsequent reads from it will return its default value.
    mutating func clearLastUpdate() {self._lastUpdate = nil}

    /// Represents latest active product_id
    var productID: String {
      get {return _productID ?? String()}
      set {_productID = newValue}
    }
    /// Returns true if `productID` has been explicitly set.
    var hasProductID: Bool {return self._productID != nil}
    /// Clears the value of `productID`. Subsequent reads from it will return its default value.
    mutating func clearProductID() {self._productID = nil}

    /// Represents latest start date
    var start: SwiftProtobuf.Google_Protobuf_Timestamp {
      get {return _start ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
      set {_start = newValue}
    }
    /// Returns true if `start` has been explicitly set.
    var hasStart: Bool {return self._start != nil}
    /// Clears the value of `start`. Subsequent reads from it will return its default value.
    mutating func clearStart() {self._start = nil}

    /// Represents expiration date
    var expiration: SwiftProtobuf.Google_Protobuf_Timestamp {
      get {return _expiration ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
      set {_expiration = newValue}
    }
    /// Returns true if `expiration` has been explicitly set.
    var hasExpiration: Bool {return self._expiration != nil}
    /// Clears the value of `expiration`. Subsequent reads from it will return its default value.
    mutating func clearExpiration() {self._expiration = nil}

    /// Represents status of subscription
    /// Enum of TRIAL | PAID | EXPIRED | INACTIVE
    var status: String = String()

    /// Checksum
    /// if subscription is inactive (EXPIRED || INACTIVE): sha3_256(last_update + status)
    /// if subscription is active (TRIAL || PAID):         sha3_256(last_update + status + product_id + expiration)
    var checksum: String = String()

    var unknownFields = SwiftProtobuf.UnknownStorage()

    /// Represents product and trial eligibility
    struct _Product: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// Stores product_id
      var productID: String = String()

      /// Represents trial eligibility
      var trial: Bool = false

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}
    }

    init() {}

    fileprivate var _lastUpdate: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
    fileprivate var _productID: String? = nil
    fileprivate var _start: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
    fileprivate var _expiration: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  }

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension _Profile: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "_Profile"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "settings"),
    2: .same(proto: "status"),
    3: .standard(proto: "share_code"),
  ]

  fileprivate class _StorageClass {
    var _settings: _Profile._Settings? = nil
    var _status: _Profile._Status? = nil
    var _shareCode: String? = nil

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
      _settings = source._settings
      _status = source._status
      _shareCode = source._shareCode
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
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._settings) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._status) }()
        case 3: try { try decoder.decodeSingularStringField(value: &_storage._shareCode) }()
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
      try { if let v = _storage._settings {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      try { if let v = _storage._status {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      try { if let v = _storage._shareCode {
        try visitor.visitSingularStringField(value: v, fieldNumber: 3)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile, rhs: _Profile) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._settings != rhs_storage._settings {return false}
        if _storage._status != rhs_storage._status {return false}
        if _storage._shareCode != rhs_storage._shareCode {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Settings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile.protoMessageName + "._Settings"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "addresses"),
    2: .same(proto: "timezone"),
    3: .standard(proto: "portfolio_tracker"),
    5: .standard(proto: "gmt_offset"),
    6: .standard(proto: "push_token"),
    7: .same(proto: "platform"),
    8: .same(proto: "notifications"),
    9: .standard(proto: "multichain_addresses"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.addresses) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.timezone) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._portfolioTracker) }()
      case 5: try { try decoder.decodeSingularInt64Field(value: &self.gmtOffset) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.pushToken) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.platform) }()
      case 8: try { try decoder.decodeSingularUInt32Field(value: &self.notifications) }()
      case 9: try { try decoder.decodeSingularMessageField(value: &self._multichainAddresses) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.addresses.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.addresses, fieldNumber: 1)
    }
    if !self.timezone.isEmpty {
      try visitor.visitSingularStringField(value: self.timezone, fieldNumber: 2)
    }
    try { if let v = self._portfolioTracker {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.gmtOffset != 0 {
      try visitor.visitSingularInt64Field(value: self.gmtOffset, fieldNumber: 5)
    }
    if !self.pushToken.isEmpty {
      try visitor.visitSingularStringField(value: self.pushToken, fieldNumber: 6)
    }
    if !self.platform.isEmpty {
      try visitor.visitSingularStringField(value: self.platform, fieldNumber: 7)
    }
    if self.notifications != 0 {
      try visitor.visitSingularUInt32Field(value: self.notifications, fieldNumber: 8)
    }
    try { if let v = self._multichainAddresses {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Settings, rhs: _Profile._Settings) -> Bool {
    if lhs.addresses != rhs.addresses {return false}
    if lhs.timezone != rhs.timezone {return false}
    if lhs._portfolioTracker != rhs._portfolioTracker {return false}
    if lhs.gmtOffset != rhs.gmtOffset {return false}
    if lhs.pushToken != rhs.pushToken {return false}
    if lhs.platform != rhs.platform {return false}
    if lhs.notifications != rhs.notifications {return false}
    if lhs._multichainAddresses != rhs._multichainAddresses {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Settings._Notifications: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DISABLED"),
    1: .same(proto: "OUTGOING_TX"),
    2: .same(proto: "INCOMING_TX"),
    4: .same(proto: "ANNOUNCEMENTS"),
    8: .same(proto: "SECURITY"),
    16: .same(proto: "BIG_MOVERS"),
    32: .same(proto: "ENERGY_SEASON_START"),
    64: .same(proto: "ENERGY_SEASON_END"),
  ]
}

extension _Profile._Settings._Address: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile._Settings.protoMessageName + "._Address"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "flags"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.address) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.flags) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 1)
    }
    if self.flags != 0 {
      try visitor.visitSingularUInt32Field(value: self.flags, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Settings._Address, rhs: _Profile._Settings._Address) -> Bool {
    if lhs.address != rhs.address {return false}
    if lhs.flags != rhs.flags {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Settings._Address._AddressFlags: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DISABLED"),
    1: .same(proto: "INCLUDE_IN_WEEKLY_PORTFOLIO_TRACKER"),
    2: .same(proto: "INCLUDE_IN_DAILY_PORTFOLIO_TRACKER"),
    64: .same(proto: "TYPE_WATCH_ONLY"),
    128: .same(proto: "TYPE_INTERNAL"),
  ]
}

extension _Profile._Settings._PortfolioTracker: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile._Settings.protoMessageName + "._PortfolioTracker"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "weekly"),
    2: .same(proto: "daily"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._weekly) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._daily) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._weekly {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._daily {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Settings._PortfolioTracker, rhs: _Profile._Settings._PortfolioTracker) -> Bool {
    if lhs._weekly != rhs._weekly {return false}
    if lhs._daily != rhs._daily {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Settings._PortfolioTracker._TrackerTime: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile._Settings._PortfolioTracker.protoMessageName + "._TrackerTime"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "enabled"),
    2: .same(proto: "timestamp"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.enabled) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.timestamp) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.enabled != false {
      try visitor.visitSingularBoolField(value: self.enabled, fieldNumber: 1)
    }
    if !self.timestamp.isEmpty {
      try visitor.visitSingularStringField(value: self.timestamp, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Settings._PortfolioTracker._TrackerTime, rhs: _Profile._Settings._PortfolioTracker._TrackerTime) -> Bool {
    if lhs.enabled != rhs.enabled {return false}
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Settings._Multichain: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile._Settings.protoMessageName + "._Multichain"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "evm"),
    2: .same(proto: "btc"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.evm) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.btc) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.evm.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.evm, fieldNumber: 1)
    }
    if !self.btc.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.btc, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Settings._Multichain, rhs: _Profile._Settings._Multichain) -> Bool {
    if lhs.evm != rhs.evm {return false}
    if lhs.btc != rhs.btc {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Status: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile.protoMessageName + "._Status"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "products"),
    2: .standard(proto: "last_update"),
    3: .standard(proto: "product_id"),
    4: .same(proto: "start"),
    5: .same(proto: "expiration"),
    6: .same(proto: "status"),
    7: .same(proto: "checksum"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.products) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._lastUpdate) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self._productID) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._start) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._expiration) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.status) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.checksum) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.products.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.products, fieldNumber: 1)
    }
    try { if let v = self._lastUpdate {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._productID {
      try visitor.visitSingularStringField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._start {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try { if let v = self._expiration {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    if !self.status.isEmpty {
      try visitor.visitSingularStringField(value: self.status, fieldNumber: 6)
    }
    if !self.checksum.isEmpty {
      try visitor.visitSingularStringField(value: self.checksum, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Status, rhs: _Profile._Status) -> Bool {
    if lhs.products != rhs.products {return false}
    if lhs._lastUpdate != rhs._lastUpdate {return false}
    if lhs._productID != rhs._productID {return false}
    if lhs._start != rhs._start {return false}
    if lhs._expiration != rhs._expiration {return false}
    if lhs.status != rhs.status {return false}
    if lhs.checksum != rhs.checksum {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension _Profile._Status._Product: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _Profile._Status.protoMessageName + "._Product"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "product_id"),
    2: .same(proto: "trial"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.productID) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.trial) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.productID.isEmpty {
      try visitor.visitSingularStringField(value: self.productID, fieldNumber: 1)
    }
    if self.trial != false {
      try visitor.visitSingularBoolField(value: self.trial, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: _Profile._Status._Product, rhs: _Profile._Status._Product) -> Bool {
    if lhs.productID != rhs.productID {return false}
    if lhs.trial != rhs.trial {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
