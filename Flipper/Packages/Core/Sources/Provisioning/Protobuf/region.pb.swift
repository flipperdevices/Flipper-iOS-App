import Foundation
import SwiftProtobuf

// swiftlint:disable identifier_name
// swiftlint:disable type_name
// swiftlint:disable private_over_fileprivate
// swiftlint:disable operator_whitespace
// swiftlint:disable trailing_comma
// swiftlint:disable line_length
// swiftlint:disable nesting
// swiftlint:disable closure_spacing
// swiftlint:disable indentation_width
// swiftlint:disable redundant_type_annotation

struct PB_Region {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var countryCode: Data = Data()

  var bands: [PB_Region.Band] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  struct Band {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var start: UInt32 = 0

    var end: UInt32 = 0

    var powerLimit: Int32 = 0

    var dutyCycle: UInt32 = 0

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

extension PB_Region: @unchecked Sendable {}
extension PB_Region.Band: @unchecked Sendable {}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "PB"

extension PB_Region: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Region"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "country_code"),
    2: .same(proto: "bands"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.countryCode) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.bands) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.countryCode.isEmpty {
      try visitor.visitSingularBytesField(value: self.countryCode, fieldNumber: 1)
    }
    if !self.bands.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.bands, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PB_Region, rhs: PB_Region) -> Bool {
    if lhs.countryCode != rhs.countryCode {return false}
    if lhs.bands != rhs.bands {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PB_Region.Band: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = PB_Region.protoMessageName + ".Band"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "start"),
    2: .same(proto: "end"),
    3: .standard(proto: "power_limit"),
    4: .standard(proto: "duty_cycle"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.start) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.end) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.powerLimit) }()
      case 4: try { try decoder.decodeSingularUInt32Field(value: &self.dutyCycle) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.start != 0 {
      try visitor.visitSingularUInt32Field(value: self.start, fieldNumber: 1)
    }
    if self.end != 0 {
      try visitor.visitSingularUInt32Field(value: self.end, fieldNumber: 2)
    }
    if self.powerLimit != 0 {
      try visitor.visitSingularInt32Field(value: self.powerLimit, fieldNumber: 3)
    }
    if self.dutyCycle != 0 {
      try visitor.visitSingularUInt32Field(value: self.dutyCycle, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PB_Region.Band, rhs: PB_Region.Band) -> Bool {
    if lhs.start != rhs.start {return false}
    if lhs.end != rhs.end {return false}
    if lhs.powerLimit != rhs.powerLimit {return false}
    if lhs.dutyCycle != rhs.dutyCycle {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
