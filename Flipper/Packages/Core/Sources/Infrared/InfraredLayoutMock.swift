// swiftlint:disable line_length
import Foundation

extension KeyID {
    static let mock = KeyID(
        type: "SHA_256",
        keyName: "power",
        sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
    )
}

extension TextButtonData {
    public static let mock = TextButtonData(
        keyId: KeyID(
            type: "SHA_256",
            keyName: "power",
            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
        ),
        text: "PWR"
    )
}

extension InfraredLayout {
    static let mock = InfraredLayout(pages: [.mock])
}

extension InfraredPageLayout {
    public static let mock = InfraredPageLayout(
        buttons: [
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "power",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .power
                    )
                ),
                position: InfraredButtonPosition(
                    y: 0,
                    x: 1,
                    alignment: .bottomLeft,
                    zIndex: 10,
                    containerWidth: 2,
                    containerHeight: 1,
                    contentWidth: 2,
                    contentHeight: 1
                )
            ),
            InfraredButton(
                data: .text(
                    TextButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "power",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        text: "PWR"
                    )
                ),
                position: InfraredButtonPosition(
                    y: 0,
                    x: 0
                )
            ),
            InfraredButton(
                data: .text(
                    TextButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "menu",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        text: "MENU"
                    )
                ),
                position: InfraredButtonPosition(
                    y: 0,
                    x: 2
                )
            ),
            InfraredButton(
                data: .base64Image(
                    Base64ImageButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "power",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        pngBase64: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAACYktHRAD/h4/MvwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB+gGBwkJFOCdqu0AAAH5SURBVEjHxdVPSBRhGMfxz65jEJYG2haFVJQQ5KGCIiqITl26RHWQpEsJ/QFFwkuQRJc6dOnSoWNkRnSoU5cuHrI/XiMqlQI7FOuGmrAq604HIXdnZ3b3VM97mXmfZ748v9887wz/O1J17oX1ArYZ0BpTN+mebBwgiNx3uixnpgwc2my9HfpM15Z00oIrWmVK1kYPhEJDcb0FMZBZuchO3i+vnEVvNBcHSMXsLLpl0kAlIg4Qb/a8QVwT6itF1Ato1CHwxE7nhPpX7awPUNDqqYJQI7p9cyMJkIoFDFvQKCWNJl12SSvGAwpYrgCMGft7vdFxJZOZrijtM1JVTrq8y9IOjjohtOxSgpCUKQ+jpyIoSfc4X8PMrJHoOJcCAoSy5q3T5ocGzeZk/JS1wVZpKQ1RZqWJ13221gWPLLrquYsGrbHbTS1xTVXOwbQeH70wI+e9rJe2uG1RU5Kn0QgNGbVfkwPeYl67N/rN1Aso2uOObksOmTSnwzvjpizFA4IK4CkHdco77Zi8tDPyJnRprvGGpD0W1lg5ndqMG16dlNUOiiZkFRWlEgfpq9lorlTCXUMCLeYUEgC/fbepupC9RhypWpHxJV7CSrQ7bJ9Pid+Jokx5LqgoSBvUm+DCyhPbjSYDPrivrbpKrz1bPZP1/trKI6xZ8Q/jD2AukeSMMfJ/AAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI0LTA2LTA3VDA5OjA5OjExKzAwOjAwIUUsnAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNC0wNi0wN1QwOTowOToxMSswMDowMFAYlCAAAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjQtMDYtMDdUMDk6MDk6MjArMDA6MDAv9bmoAAAAAElFTkSuQmCC"
                    )
                ),
                position: InfraredButtonPosition(
                    y: 2,
                    x: 0,
                    zIndex: 10
                )
            ),
            InfraredButton(
                data: .text(
                    TextButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "tv_av",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        text: "TV/AV"
                    )
                ),
                position: InfraredButtonPosition(
                    y: 0,
                    x: 4
                )
            ),
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "info",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .info
                    )
                ),
                position: InfraredButtonPosition(
                    y: 1,
                    x: 0
                )
            ),
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "hm",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .home
                    )
                ),
                position: InfraredButtonPosition(
                    y: 1,
                    x: 1
                )
            ),
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "back",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .back
                    )
                ),
                position: InfraredButtonPosition(
                    y: 1,
                    x: 3
                )
            ),
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "more",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .more
                    )
                ),
                position: InfraredButtonPosition(
                    y: 1,
                    x: 4
                )
            ),
            InfraredButton(
                data: .navigation(
                    NavigationButtonData(
                        upKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "up",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        leftKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "left",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        downKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "down",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        rightKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "right",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        okKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "apply",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        )
                    )
                ),
                position: InfraredButtonPosition(
                    y: 3,
                    x: 1
                )
            ),
            InfraredButton(
                data: .channel(
                    ChannelButtonData(
                        addKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "ch+",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        reduceKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "ch-",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        )
                    )
                ),
                position: InfraredButtonPosition(
                    y: 7,
                    x: 0
                )
            ),
            InfraredButton(
                data: .volume(
                    VolumeButtonData(
                        addKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "v+",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        reduceKeyId: KeyID(
                            type: "SHA_256",
                            keyName: "v-",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        )
                    )
                ),
                position: InfraredButtonPosition(
                    y: 7,
                    x: 4
                )
            ),
            InfraredButton(
                data: .text(
                    TextButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "123",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        text: "123"
                    )
                ),
                position: InfraredButtonPosition(
                    y: 10,
                    x: 0
                )
            ),
            InfraredButton(
                data: .icon(
                    IconButtonData(
                        keyId: KeyID(
                            type: "SHA_256",
                            keyName: "sound_toggle",
                            sha256String: "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                        ),
                        icon: .mute
                    )
                ),
                position: InfraredButtonPosition(
                    y: 10,
                    x: 4
                )
            )
        ]
    )
}

extension Data {
    static let mockKitchenLayout =
    """
    {
        "pages": [
            {
                "buttons": [
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "power",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "POWER",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 0,
                            "x": 1,
                            "alignment": "BOTTOM_LEFT",
                            "z_index": 10,
                            "container_width": 2,
                            "container_height": 1,
                            "content_width": 2,
                            "content_height": 1
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "power",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "text": "PWR",
                            "type": "TEXT"
                        },
                        "position": {
                            "y": 0,
                            "x": 0
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "menu",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "text": "MENU",
                            "type": "TEXT"
                        },
                        "position": {
                            "y": 0,
                            "x": 2
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "power",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "png_base64": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAACYktHRAD/h4/MvwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB+gGBwkJFOCdqu0AAAH5SURBVEjHxdVPSBRhGMfxz65jEJYG2haFVJQQ5KGCIiqITl26RHWQpEsJ/QFFwkuQRJc6dOnSoWNkRnSoU5cuHrI/XiMqlQI7FOuGmrAq604HIXdnZ3b3VM97mXmfZ748v9887wz/O1J17oX1ArYZ0BpTN+mebBwgiNx3uixnpgwc2my9HfpM15Z00oIrWmVK1kYPhEJDcb0FMZBZuchO3i+vnEVvNBcHSMXsLLpl0kAlIg4Qb/a8QVwT6itF1Ato1CHwxE7nhPpX7awPUNDqqYJQI7p9cyMJkIoFDFvQKCWNJl12SSvGAwpYrgCMGft7vdFxJZOZrijtM1JVTrq8y9IOjjohtOxSgpCUKQ+jpyIoSfc4X8PMrJHoOJcCAoSy5q3T5ocGzeZk/JS1wVZpKQ1RZqWJ13221gWPLLrquYsGrbHbTS1xTVXOwbQeH70wI+e9rJe2uG1RU5Kn0QgNGbVfkwPeYl67N/rN1Aso2uOObksOmTSnwzvjpizFA4IK4CkHdco77Zi8tDPyJnRprvGGpD0W1lg5ndqMG16dlNUOiiZkFRWlEgfpq9lorlTCXUMCLeYUEgC/fbepupC9RhypWpHxJV7CSrQ7bJ9Pid+Jokx5LqgoSBvUm+DCyhPbjSYDPrivrbpKrz1bPZP1/trKI6xZ8Q/jD2AukeSMMfJ/AAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI0LTA2LTA3VDA5OjA5OjExKzAwOjAwIUUsnAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNC0wNi0wN1QwOTowOToxMSswMDowMFAYlCAAAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjQtMDYtMDdUMDk6MDk6MjArMDA6MDAv9bmoAAAAAElFTkSuQmCC",
                            "type": "BASE64_IMAGE"
                        },
                        "position": {
                            "y": 2,
                            "x": 0,
                            "z_index": 10
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "tv_av",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "text": "TV/AV",
                            "type": "TEXT"
                        },
                        "position": {
                            "y": 0,
                            "x": 4
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "info",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "INFO",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 1,
                            "x": 0
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "hm",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "HOME",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 1,
                            "x": 1
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "back",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "BACK",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 1,
                            "x": 3
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "more",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "MORE",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 1,
                            "x": 4
                        }
                    },
                    {
                        "data": {
                            "up_key_id": {
                                "type": "SHA_256",
                                "key_name": "up",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "left_key_id": {
                                "type": "SHA_256",
                                "key_name": "left",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "down_key_id": {
                                "type": "SHA_256",
                                "key_name": "down",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "right_key_id": {
                                "type": "SHA_256",
                                "key_name": "right",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "ok_key_id": {
                                "type": "SHA_256",
                                "key_name": "apply",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "type": "NAVIGATION"
                        },
                        "position": {
                            "y": 3,
                            "x": 1
                        }
                    },
                    {
                        "data": {
                            "add_key_id": {
                                "type": "SHA_256",
                                "key_name": "ch+",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "reduce_key_id": {
                                "type": "SHA_256",
                                "key_name": "ch-",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "type": "CHANNEL"
                        },
                        "position": {
                            "y": 7,
                            "x": 0
                        }
                    },
                    {
                        "data": {
                            "add_key_id": {
                                "type": "SHA_256",
                                "key_name": "v+",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "reduce_key_id": {
                                "type": "SHA_256",
                                "key_name": "v-",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "type": "VOLUME"
                        },
                        "position": {
                            "y": 7,
                            "x": 4
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "123",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "text": "123",
                            "type": "TEXT"
                        },
                        "position": {
                            "y": 10,
                            "x": 0
                        }
                    },
                    {
                        "data": {
                            "key_id": {
                                "type": "SHA_256",
                                "key_name": "sound_toggle",
                                "sha_256_string": "60d18bb96f05eee3bde60a0c3f87b13f74b0c4d3d934d659ef7738f415881740"
                            },
                            "icon_id": "MUTE",
                            "type": "ICON"
                        },
                        "position": {
                            "y": 10,
                            "x": 4
                        }
                    }
                ]
            }
        ]
    }
    """.data(using: .utf8)!
}
// swiftlint:enable line_length
