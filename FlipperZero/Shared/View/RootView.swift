//
//  RootView.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/19/20.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
          HomeView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
