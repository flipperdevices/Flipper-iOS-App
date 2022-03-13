import Core
import SwiftUI

struct CategoryView: View {
    @StateObject var viewModel: CategoryViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            CategoryList(items: viewModel.items) { item in
                viewModel.onItemSelected(item: item)
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text(viewModel.name)
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .sheet(isPresented: $viewModel.showInfoView) {
            InfoView(viewModel: .init(item: viewModel.selectedItem))
        }
    }
}
