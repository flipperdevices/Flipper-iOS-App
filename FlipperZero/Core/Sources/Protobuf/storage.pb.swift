// swiftlint:disable type_name
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: storage.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
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

struct PBStorage_Element {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var type: PBStorage_Element.FileType = .file

  var name: String = String()

  var size: UInt32 = 0

  var data: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum FileType: SwiftProtobuf.Enum {
    typealias RawValue = Int

    /// default value
    case file // = 0
    case dir // = 1
    case UNRECOGNIZED(Int)

    init() {
      self = .file
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .file
      case 1: self = .dir
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .file: return 0
      case .dir: return 1
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

#if swift(>=4.2)

extension PBStorage_Element.FileType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [PBStorage_Element.FileType] = [
    .file,
    .dir,
  ]
}

#endif  // swift(>=4.2)

struct PBStorage_ListRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var path: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct PBStorage_ListResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var storageElement: [PBStorage_Element] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct PBStorage_ReadRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var filepath: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct PBStorage_ReadResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var storageElement: PBStorage_Element {
    get {return _storageElement ?? PBStorage_Element()}
    set {_storageElement = newValue}
  }
  /// Returns true if `storageElement` has been explicitly set.
  var hasStorageElement: Bool {return self._storageElement != nil}
  /// Clears the value of `storageElement`. Subsequent reads from it will return its default value.
  mutating func clearStorageElement() {self._storageElement = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storageElement: PBStorage_Element? = nil
}

struct PBStorage_WriteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var path: String = String()

  var storageElement: PBStorage_Element {
    get {return _storageElement ?? PBStorage_Element()}
    set {_storageElement = newValue}
  }
  /// Returns true if `storageElement` has been explicitly set.
  var hasStorageElement: Bool {return self._storageElement != nil}
  /// Clears the value of `storageElement`. Subsequent reads from it will return its default value.
  mutating func clearStorageElement() {self._storageElement = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storageElement: PBStorage_Element? = nil
}

struct PBStorage_DeleteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var filename: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "PB_Storage"

extension PBStorage_Element: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Element"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "name"),
    3: .same(proto: "size"),
    4: .same(proto: "data"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularUInt32Field(value: &self.size) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.type != .file {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.size != 0 {
      try visitor.visitSingularUInt32Field(value: self.size, fieldNumber: 3)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_Element, rhs: PBStorage_Element) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.name != rhs.name {return false}
    if lhs.size != rhs.size {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_Element.FileType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "FILE"),
    1: .same(proto: "DIR"),
  ]
}

extension PBStorage_ListRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ListRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "path"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.path) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.path.isEmpty {
      try visitor.visitSingularStringField(value: self.path, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_ListRequest, rhs: PBStorage_ListRequest) -> Bool {
    if lhs.path != rhs.path {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_ListResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ListResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "storage_element"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.storageElement) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.storageElement.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.storageElement, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_ListResponse, rhs: PBStorage_ListResponse) -> Bool {
    if lhs.storageElement != rhs.storageElement {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_ReadRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ReadRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "filepath"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.filepath) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.filepath.isEmpty {
      try visitor.visitSingularStringField(value: self.filepath, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_ReadRequest, rhs: PBStorage_ReadRequest) -> Bool {
    if lhs.filepath != rhs.filepath {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_ReadResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ReadResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "storage_element"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._storageElement) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._storageElement {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_ReadResponse, rhs: PBStorage_ReadResponse) -> Bool {
    if lhs._storageElement != rhs._storageElement {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_WriteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".WriteRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "path"),
    2: .standard(proto: "storage_element"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.path) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._storageElement) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.path.isEmpty {
      try visitor.visitSingularStringField(value: self.path, fieldNumber: 1)
    }
    if let v = self._storageElement {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_WriteRequest, rhs: PBStorage_WriteRequest) -> Bool {
    if lhs.path != rhs.path {return false}
    if lhs._storageElement != rhs._storageElement {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PBStorage_DeleteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".DeleteRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "filename"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.filename) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.filename.isEmpty {
      try visitor.visitSingularStringField(value: self.filename, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PBStorage_DeleteRequest, rhs: PBStorage_DeleteRequest) -> Bool {
    if lhs.filename != rhs.filename {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
