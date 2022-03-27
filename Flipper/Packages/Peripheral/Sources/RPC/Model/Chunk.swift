extension RandomAccessCollection where Index == Int {
    func chunk(maxCount: Int) -> [[Element]] {
        var result = [[Element]]()

        let elementCount = (self.count - 1) / maxCount + 1
        for index in 0..<elementCount {
            let startIndex = index * maxCount
            let endIndex = Swift.min(startIndex + maxCount, self.count)
            let nextChunk = [Element](self[startIndex..<endIndex])
            result.append(nextChunk)
        }

        return result
    }
}
