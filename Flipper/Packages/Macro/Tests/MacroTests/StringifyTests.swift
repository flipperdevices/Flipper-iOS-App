import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is
// not available when cross-compiling. Cross-compiled tests may still make
// use of the macro itself in end-to-end tests.
#if canImport(MacroPlugin)
import MacroPlugin

let stringifyMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self
]
#endif

final class MacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MacroMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: stringifyMacros
        )
        #else
        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MacroMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: stringifyMacros
        )
        #else
        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )
        #endif
    }
}
