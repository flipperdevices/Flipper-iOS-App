//
//  HomeView.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/19/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: ObservableResolver
    @State private var displayingConnections = false

    var body: some View {
        VStack {
            Text("Hello, Flipper users!")
                .padding()
            Button("Connect your device") {
                self.displayingConnections = true
            }
                .sheet(isPresented: self.$displayingConnections) {
                    ConnectionsView(viewModel: ConnectionsViewModel(self.container))
                    #if os(macOS)
                    HStack {
                        Spacer()
                        Button("Close") {
                            self.displayingConnections = false
                        }
                            .padding(.all)
                    }
                    #endif
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
            HomeView().body.font(.custom(.boldPixel, size: 50))
            HomeView().body.font(.custom(.regularPixel))
            HomeView().body.font(.regularPixel())
            HomeView().body.font(.regularRoboto())
        }
    }
}
