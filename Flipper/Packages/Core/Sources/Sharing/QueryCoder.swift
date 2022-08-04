enum KeyCoder {
    static func encode(query: String) -> String? {
        var query = query
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: " ", with: "+")

        if query.last == "?" {
            query += "+"
        }

        return query
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func decode(query: String) -> String? {
        query
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding
    }
}
