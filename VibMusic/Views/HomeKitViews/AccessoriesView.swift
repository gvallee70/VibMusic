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

    var home: HMHome
    @State var searchCount = 0
    @State var isSearchingForNewAccessories = false
    @StateObject var model: HomeStore

    var body: some View {
        List {
            if !self.model.accessories.isEmpty {
                Section(header: HStack {
                    Text("Mes ampoules pour \(home.name)")
                }) {
                    ForEach(self.model.accessories, id: \.uniqueIdentifier) { accessory in
                        NavigationLink(destination: ServicesView(accessory: accessory, model: self.model)) {
                            Text(accessory.name)
                        }
                    }
                }
            }
            
            if !self.isSearchingForNewAccessories || self.model.discoveredAccessories.isEmpty {
                Button {
                    self.model.findNewAccessories()
                    self.searchCount += 1
                    self.isSearchingForNewAccessories = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSearchingForNewAccessories = false
                        self.model.stopFindNewAccessories()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if self.isSearchingForNewAccessories {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                       
                        Text(self.model.discoveredAccessories.isEmpty && self.isSearchingForNewAccessories ? "Recherche en cours..." : "Rechercher nouvelles ampoules")
                    }
                }
            }
            
            if !self.model.discoveredAccessories.isEmpty {
                Section(header: HStack {
                    Text("Ajouter une ampoule à \(self.home.name)")
                    Spacer()
                    ProgressView()
                        .opacity(self.isSearchingForNewAccessories ? 1 : 0)
                }) {
                    ForEach(self.model.discoveredAccessories, id: \.uniqueIdentifier) { accessory in
                        Button {
                            self.model.addAccessory(accessory, to: self.home)
                            self.searchCount = 0
                        } label: {
                            Text(accessory.name)
                                .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            
            if (self.model.discoveredAccessories.isEmpty && self.searchCount > 0 && !self.isSearchingForNewAccessories) || self.model.accessories.isEmpty {
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
        .navigationTitle(self.home.name)
        .onAppear {
            self.model.getAccessories(from: self.home)
        }
    }
}
