import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        URLMacro.self
    ]
}
