enum KeyCoder {
    static func encode<Query: StringProtocol>(query: Query) -> String? {
        var query = query
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: " ", with: "+")

        if query.last == "?" {
            query += "+"
        }

        return query
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func decode<Query: StringProtocol>(query: Query) -> String? {
        query
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding
    }
}
