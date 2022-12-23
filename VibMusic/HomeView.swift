//
//  HomeView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct HomeView: View {
    
    @ObservedObject var model: HomeStore
    
    var body: some View {
        List {
            Section(header: HStack {
            }) {
                ForEach(model.homes, id: \.uniqueIdentifier) { home in
                    NavigationLink(value: home){
                        Text("\(home.name)")
                    }
                    .navigationDestination(for: HMHome.self){
                        AccessoriesView(homeId: $0.uniqueIdentifier, model: model)
                    }
                }
            }
        }
        .navigationTitle("Mes maisons")
    }
}
