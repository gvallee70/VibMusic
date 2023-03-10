//
//  HomesListScreen.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct HomesListScreen: View {
    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel

    @State private var showAddHomeAlert = false
    @State private var homeName = ""
    @State private var showHomeActionDialog = false
    @State private var selectedHome: HMHome?

    var body: some View {
        List {
            Button {
                self.showAddHomeAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Ajouter un domicile")
                }
            }
            .alert("Ajouter une maison", isPresented: self.$showAddHomeAlert) {
                TextField("Nom", text: self.$homeName)
                
                Button("Ajouter", action: {
                    if self.homeName.isNotEmpty {
                        self.homeStoreViewModel.addHome(self.homeName)
                        self.homeName = ""
                    }
                })
                
                Button("Non", role: .cancel, action: {                     self.showAddHomeAlert.toggle()
                })
            }
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
                    Text("Cliquez sur un domicile pour choisir une action.")
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Mes domiciles")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .confirmationDialog("Mon domicile", isPresented: self.$showHomeActionDialog) {
            if let selectedHome = self.selectedHome {
                NavigationLink(destination: RoomsListScreen(home: selectedHome)) {
                    Text("Voir le d??tails des pi??ces")
                }
                if self.selectedHome != self.homeStoreViewModel.currentStoredHome {
                    Button("D??finir comme domicile actif") {
                        self.homeStoreViewModel.setCurrentHome(selectedHome)
                    }
                    
                    Button("Supprimer \(selectedHome.name)", role: .destructive) {
                        self.homeStoreViewModel.deleteHome(selectedHome)
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
