import CCrapto1

public enum MFKey32v2 {
    public static func recover(from data: ReaderData) -> UInt64? {
        recover(
            uid: data.uid,
            nt0: data.nt0,
            nr0: data.nr0,
            ar0: data.ar0,
            nt1: data.nt1,
            nr1: data.nr1,
            ar1: data.ar1)
    }

    // ported from mfkey32v2.c

    // swiftlint:disable function_parameter_count identifier_name

    private static func recover(
        uid: UInt32,
        nt0: UInt32,
        nr0: UInt32,
        ar0: UInt32,
        nt1: UInt32,
        nr1: UInt32,
        ar1: UInt32
    ) -> UInt64? {
        // Generate lfsr successors of the tag challenge
        let p64 = prng_successor(nt0, 64)
        let p64b = prng_successor(nt1, 64)

        // Extract the keystream from the messages
        guard let s = lfsr_recovery32(ar0 ^ p64, 0) else { return nil }
        defer { free(s) }

        var t = s
        var key: UInt64 = 0

        while (t.pointee.odd | t.pointee.even) != 0 {
            lfsr_rollback_word(t, 0, 0)
            lfsr_rollback_word(t, nr0, 1)
            lfsr_rollback_word(t, uid ^ nt0, 0)
            crypto1_get_lfsr(t, &key)

            crypto1_word(t, uid ^ nt1, 0)
            crypto1_word(t, nr1, 1)
            if ar1 == (crypto1_word(t, 0, 0) ^ p64b) {
                return key
            }
            t = t.advanced(by: 1)
        }

        return nil
    }
}
