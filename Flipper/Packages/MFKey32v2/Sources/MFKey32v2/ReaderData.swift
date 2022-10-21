public struct ReaderData: Sendable {
    /// serial number
    public let uid: UInt32
    /// tag challenge first
    public let nt0: UInt32
    /// first encrypted reader challenge
    public let nr0: UInt32
    /// first encrypted reader response
    public let ar0: UInt32
    /// tag challenge second
    public let nt1: UInt32
    /// second encrypted reader challenge
    public let nr1: UInt32
    /// second encrypted reader response
    public let ar1: UInt32

    public init(
        uid: UInt32,
        nt0: UInt32,
        nr0: UInt32,
        ar0: UInt32,
        nt1: UInt32,
        nr1: UInt32,
        ar1: UInt32
    ) {
        self.uid = uid
        self.nt0 = nt0
        self.nr0 = nr0
        self.ar0 = ar0
        self.nt1 = nt1
        self.nr1 = nr1
        self.ar1 = ar1
    }
}
