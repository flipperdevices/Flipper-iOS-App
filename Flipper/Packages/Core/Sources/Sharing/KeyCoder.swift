enum KeyCoder {
    static func encode(query: String) -> String? {
        query
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: " ", with: "+")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func decode(query: String) -> String? {
        query
            .removingPercentEncoding?
            .replacingOccurrences(of: "+", with: " ")
    }
}
