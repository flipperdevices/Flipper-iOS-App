import QuickLook

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(
        for request: QLFilePreviewRequest
    ) async throws -> QLPreviewReply {
        let reply = QLPreviewReply(
            dataOfContentType: .plainText,
            contentSize: CGSize.init(width: 800, height: 800)
        ) { (replyToUpdate: QLPreviewReply) in
            return try Data(contentsOf: request.fileURL)
        }
        return reply
    }
}
