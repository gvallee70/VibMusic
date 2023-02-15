//
//  AccessoriesListScreen.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct AccessoriesListScreen: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel
    
    @State var home: HMHome
    @State var room: HMRoom
    @State private var searchCount = 0
    @State private var isSearchingForNewAccessories = false
    @State private var showAccessoryActionDialog = false
    @State private var selectedAccessory: HMAccessory?

    var body: some View {
        List {
            if !self.homeStoreViewModel.accessories.isEmpty {
                Section(header: HStack {
                    Text("Mes ampoules dans \(self.room.name)")
                }) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                        ForEach(self.homeStoreViewModel.roomAccessories, id: \.uniqueIdentifier) { accessory in
                            AccessoryView(accessory: accessory)
                            .padding(10)
                            .onTapGesture {
                                self.selectedAccessory = accessory
                                self.showAccessoryActionDialog.toggle()
                            }
                        }
                    }
                }
            }
            
            if !self.isSearchingForNewAccessories || self.homeStoreViewModel.discoveredAccessories.isEmpty {
                Button {
                    self.homeStoreViewModel.findNewAccessories()
                    self.searchCount += 1
                    self.isSearchingForNewAccessories = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSearchingForNewAccessories = false
                        self.homeStoreViewModel.stopFindNewAccessories()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if self.isSearchingForNewAccessories {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                       
                        Text(self.homeStoreViewModel.discoveredAccessories.isEmpty && self.isSearchingForNewAccessories ? "Recherche en cours..." : "Rechercher nouvelles ampoules")
                    }
                }
            }
            
            if !self.homeStoreViewModel.discoveredAccessories.isEmpty {
                Section(header: HStack {
                    Text("Ajouter une ampoule à \(self.room.name)")
                    Spacer()
                    ProgressView()
                        .opacity(self.isSearchingForNewAccessories ? 1 : 0)
                }) {
                    ForEach(self.homeStoreViewModel.discoveredAccessories, id: \.uniqueIdentifier) { accessory in
                        Button {
                            self.searchCount = 0
                            self.homeStoreViewModel.addAccessory(accessory, to: self.home, in: self.room)
                        } label: {
                            Text(accessory.name)
                                .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            
            if (self.homeStoreViewModel.discoveredAccessories.isEmpty && self.searchCount > 0 && !self.isSearchingForNewAccessories) || self.homeStoreViewModel.roomAccessories.isEmpty {
                VStack(alignment: .center) {
                    Text("Aucune ampoule \(self.homeStoreViewModel.roomAccessories.isEmpty ?  "pour \(self.room.name)" : "trouvé")")
                        .font(.title)
                    LottieView(filename: "NoLightbulbFound")
                }
                .frame(width: 300, height: 300, alignment: .center)
                .padding()
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("\(self.room.name) \(self.homeStoreViewModel.currentStoredRooms.contains(self.room) ? "(active)" : "")")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .confirmationDialog("Mon ampoule", isPresented: self.$showAccessoryActionDialog) {
            if let selectedAccessory = self.selectedAccessory {
                if let lightbulbService = selectedAccessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }) {
                    NavigationLink(destination: ManageCharacteristicsScreen(service: lightbulbService)) {
                        Text("Modifier les caractéristiques")
                    }
                }
                
                if self.homeStoreViewModel.currentStoredAccessories.contains(selectedAccessory) {
                    Button("Retirer des ampoules actives", role: .destructive) {
                        self.homeStoreViewModel.removeFromCurrentAccessories(selectedAccessory, home: self.home)
                    }
                } else {
                    if self.homeStoreViewModel.currentStoredRooms.contains(self.room) {
                        Button("Ajouter aux ampoules actives") {
                            self.homeStoreViewModel.addCurrentAccessory(selectedAccessory, home: self.home)
                        }
                    }
                    Button("Supprimer \(selectedAccessory.name) de \(self.home.name)", role: .destructive) {
                        self.homeStoreViewModel.deleteAccessory(selectedAccessory, home: self.home, room: self.room)
                    }
                }
                
                Button("Annuler", role: .cancel) { }
            }
        } message: {
            Text("Choisir une action pour \(self.selectedAccessory?.name ?? "cette ampoule")")
        }
        .onAppear {
            self.homeStoreViewModel.getAccessories(from: self.room)
            self.homeStoreViewModel.getCurrentAccessories()
        }
    }
}
