import Core
import SwiftUI

struct ReportBugView: View {
    @Environment(\.dismiss) private var dismiss

    @State var status: Status = .edit

    var feedback: Feedback = .init(
        loggerStorage: Dependencies.shared.loggerStorage
    )

    struct Report {
        let title: String
        let description: String
        let attachLogs: Bool
    }

    enum Status {
        case edit
        case submit
        case success(String)
        case failure
    }

    var body: some View {
        Group {
            switch status {
            case .edit:
                EditorView(onSubmit: sendReport)
            case .submit:
                SubmitView()
            case .success(let id):
                SuccessView(id: id)
            case .failure:
                FailureView()
            }
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Report Bug")
            }
        }
    }

    func sendReport(_ report: Report) {
        Task {
            do {
                status = .submit
                let id = try await feedback.reportBug(
                    subject: report.title,
                    message: report.description,
                    attachLogs: report.attachLogs)
                status = .success(id)
            } catch {
                status = .failure
            }
        }
    }
}
