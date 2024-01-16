import Foundation

/// Check if provided string literal is a valid URL and produce a non-optional
/// URL value. Emit error otherwise.
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL =
    #externalMacro(module: "MacroPlugin", type: "URLMacro")
