enum QueryCoder {
    static func encode<T: StringProtocol>(_ string: T) -> String? {
        var string = string
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: " ", with: "+")

        if string.last == "?" {
            string += "+"
        }

        return string
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func decode<T: StringProtocol>(_ string: T) -> String? {
        string
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding
    }
}
