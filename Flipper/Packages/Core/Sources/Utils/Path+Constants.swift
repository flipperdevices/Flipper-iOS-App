import Peripheral

extension Path {
    public static var update: Path {
        "/ext/update"
    }
    public static var manifest: Path {
        "/ext/Manifest"
    }
    public static var mfKey32Log: Path {
        "/ext/nfc/.mfkey32.log"
    }
    public static var mfClassicDict: Path {
        "/ext/nfc/assets/mf_classic_dict.nfc"
    }
    public static var mfClassicDictUser: Path {
        "/ext/nfc/assets/mf_classic_dict_user.nfc"
    }
}
