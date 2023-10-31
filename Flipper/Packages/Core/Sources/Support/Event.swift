import Analytics

import UIKit

extension Feedback {
    struct Event {
        let id: UUID
        let subject: String
        let message: String
        let attachments: [Attachment]

        init(subject: String, message: String, attachments: [Attachment]) {
            self.id = UUID()
            self.subject = subject
            self.message = message
            self.attachments = attachments
        }
    }

    struct Attachment {
        let filename: String
        let content: String
    }
}

extension Feedback.Event {
    // TODO: Add Flipper target & version

    func encode() -> String {
        var result = ""

        result += encodeHeader()
        result += encodeEvent()
        result += encodeAttachments()
        result += encodeFeedback()

        return result
    }
}

private extension Feedback.Event {
    var environment: String {
        #if DEBUG
        return "DEBUG"
        #else
        return Bundle.isAppStoreBuild ? "App Store" : "TestFlight"
        #endif
    }

    var systemNameVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    var appBundleVersionBuild: String {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        return "\(bundleID)@\(Bundle.releaseVersion)+\(Bundle.buildVersion)"
    }

    func encodeHeader() -> String {
        """
        {\
        "event_id":"\(id.compactUUID)",\
        "sent_at":"\(Date().iso8601String)"\
        }

        """
    }

    func encodeEvent() -> String {
        let content =
            """
            {\
            "message":{"formatted":"\(subject)"},\
            "timestamp":\(Date().timeIntervalSince1970),\
            "release":"\(appBundleVersionBuild)",\
            "tags":{"os":"\(systemNameVersion)"},\
            "level":"info",\
            "event_id":"\(id.compactUUID)",\
            "environment":"\(environment)",\
            "user":{"id":"\(DeviceID.uuidString)"}\
            }
            """

        let header =
            """
            {"type":"event","length":\(content.utf8.count)}
            """

        return
            """
            \(header)
            \(content)

            """
    }

    func encodeFeedback() -> String {
        let content =
            """
            {\
            "event_id":"\(id.compactUUID)",\
            "comments":"\(message)"\
            }
            """

        let header =
            """
            {"type":"user_report","length":\(content.utf8.count)}
            """

        return
            """
            \(header)
            \(content)

            """
    }

    func encodeAttachments() -> String {
        var result = ""
        for attachment in attachments {
            result += encodeAttachment(attachment)
        }
        return result
    }

    func encodeAttachment(_ attachment: Feedback.Attachment) -> String {
        let content = attachment
            .content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let header =
            """
            {\
            "filename":"\(attachment.filename)",\
            "length":\(content.utf8.count),\
            "type":"attachment",\
            "attachment_type":"event.attachment"\
            }
            """

        return
            """
            \(header)
            \(content)

            """
    }
}

private extension UUID {
    var compactUUID: String {
        uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    }
}

private extension Date {
    var iso8601String: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: self).appending("Z")
    }
}
