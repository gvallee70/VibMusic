//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI

struct RootView: View {
    @State private var path = NavigationPath()
    @ObservedObject var model: HomeStore
    
    var body: some View {
        NavigationStack(path: $path) {
            Button(action: {
                path.append("HomeView")
            }, label: {
                Text("Mon HomeKit")
            })
            .controlSize(.large)
            .buttonStyle(.bordered)
            .navigationDestination(for: String.self) {
                if $0 == "HomeView" {
                    HomeView(model: model)
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(model: HomeStore())
    }
}
