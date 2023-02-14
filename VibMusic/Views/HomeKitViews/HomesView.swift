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

    @State private var showHomeActionDialog = false
    @State private var selectedHome: HMHome?

    var body: some View {
        List {
            Section(header: HStack {
            }) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    ForEach(self.homeStoreViewModel.homes, id: \.uniqueIdentifier) { home in
                        HomeView(home: home)
                            .padding(10)
                            .onTapGesture {
                                self.selectedHome = home
                                self.showHomeActionDialog = true
                            }
                    }
                }
                HStack {
                    Image(systemName: "info.circle")
                    Text("Cliquez sur une maison pour choisir une action.")
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Mes maisons")
        .confirmationDialog("Mon domicile", isPresented: self.$showHomeActionDialog) {
            if let selectedHome = self.selectedHome {
                NavigationLink(destination: RoomsView(home: selectedHome)) {
                    Text("Voir les détails")
                }
                if self.selectedHome != self.homeStoreViewModel.currentStoredHome {
                    Button("Ajouter comme domicile courant") {
                        self.homeStoreViewModel.setCurrentHome(selectedHome)
                    }
                }
                
                Button("Annuler", role: .cancel) { }
            }
        } message: {
            Text("Choisir une action pour \(self.selectedHome?.name ?? "ce domicile")")
        }
        .onAppear {
            self.homeStoreViewModel.getCurrentHome()
        }
    }
}
