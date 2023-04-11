import SwiftUI

struct ReportBugView: View {
    @Environment(\.dismiss) private var dismiss

    @State var status: Status = .edit

    struct Report {
        let title: String
        let description: String
        let includeLogs: Bool
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
            case .success(let uuid):
                SuccessView(uuid: uuid)
            case .failure:
                FailureView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Report Bug")
            }
        }
    }

    func sendReport(_ report: Report) {
        Task {
            status = .submit
            try await Task.sleep(seconds: 2)
            status = .success("39fa428faf1f401895a3085d3c73be6")
        }
    }
}
