//
//  HomesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct HomesView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
            }) {
                ForEach(self.homeStoreViewModel.homes, id: \.uniqueIdentifier) { home in
                    NavigationLink(destination: AccessoriesView(home: home)) {
                        Text(home.name)
                    }
                }
            }
        }
        .navigationTitle("Mes maisons")
    }
}
