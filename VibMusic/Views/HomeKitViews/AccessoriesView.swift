//
//  AccessoriesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct AccessoriesView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var homeStoreViewModel: HomeStore
    
    @State var home: HMHome
    @State var room: HMRoom
    @State var searchCount = 0
    @State var isSearchingForNewAccessories = false

    var body: some View {
        List {
            if !self.homeStoreViewModel.accessories.isEmpty {
                Section(header: HStack {
                    Text("Mes ampoules dans \(self.room.name)")
                }) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                        ForEach(self.homeStoreViewModel.accessories, id: \.uniqueIdentifier) { accessory in
                            ZStack {
                                if let lightbulbService = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }) {
                                    NavigationLink(destination: CharacteristicsView(service: lightbulbService)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                               
                                    AccessoryView(accessory: accessory)
                                    .padding(10)
                                }
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
                            self.homeStoreViewModel.addAccessory(accessory, to: self.home, in: self.room)
                            self.searchCount = 0
                        } label: {
                            Text(accessory.name)
                                .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            
            if (self.homeStoreViewModel.discoveredAccessories.isEmpty && self.searchCount > 0 && !self.isSearchingForNewAccessories) || self.homeStoreViewModel.accessories.isEmpty {
                VStack(alignment: .center) {
                    Text("Aucune ampoule trouvée")
                        .font(.title)
                    LottieView(filename: "NoLightbulbFound")
                }
                .frame(width: 300, height: 300, alignment: .center)
                .padding()
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("\(self.room.name) \(self.homeStoreViewModel.currentStoredRooms.contains(self.room) ? "(active)" : "")")
        .onAppear {
            self.homeStoreViewModel.getAccessories(from: self.room)
        }
    }
}
