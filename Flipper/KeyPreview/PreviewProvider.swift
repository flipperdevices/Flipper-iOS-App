import QuickLook

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(
        for request: QLFilePreviewRequest
    ) async throws -> QLPreviewReply {
        QLPreviewReply(
            dataOfContentType: .plainText,
            contentSize: .init(width: 800, height: 800)
        ) { (_: QLPreviewReply) in
            try Data(contentsOf: request.fileURL)
        }
    }
}
