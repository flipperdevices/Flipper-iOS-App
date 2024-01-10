import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is
// not available when cross-compiling. Cross-compiled tests may still make
// use of the macro itself in end-to-end tests.
#if canImport(MacroPlugin)
import MacroPlugin

let urlMacros: [String: Macro.Type] = [
    "URL": URLMacro.self
]
#endif

final class URLMacroTests: XCTestCase {
    func testExpansionWithMalformedURLEmitsError() {
        assertMacroExpansion(
            """
            let invalid = #URL("https://not a url.com")
            """,
            expandedSource: """
            let invalid = #URL("https://not a url.com")
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: #"malformed url: "https://not a url.com""#,
                    line: 1,
                    column: 15,
                    severity: .error)
            ],
            macros: urlMacros,
            indentationWidth: .spaces(2)
        )
    }

    func testExpansionWithStringInterpolationEmitsError() {
        assertMacroExpansion(
            #"""
            #URL("https://\(domain)/api/path")
            """#,
            expandedSource: #"""
            #URL("https://\(domain)/api/path")
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "#URL requires a static string literal",
                    line: 1,
                    column: 1,
                    severity: .error)
            ],
            macros: urlMacros,
            indentationWidth: .spaces(2)
        )
    }

    func testExpansionWithValidURL() {
        assertMacroExpansion(
            """
            let valid = #URL("https://swift.org/")
            """,
            expandedSource: """
            let valid = URL(string: "https://swift.org/")!
            """,
            macros: urlMacros,
            indentationWidth: .spaces(2)
        )
    }
}
