//
//  HomeKitTabView.swift
//  VibMusic
//
//  Created by Gwendal on 14/02/2023.
//

import SwiftUI
import HomeKit

struct HomeKitTabView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore
    
    @State private var showRoomActionDialog = false
    @State private var showAccessoryActionDialog = false
    @State private var selectedRoom: HMRoom?
    @State private var selectedAccessory: HMAccessory?

    
    var body: some View {
        List {
            if let currentStoredHome = self.homeStoreViewModel.currentStoredHome {
                Section("Mon domicile actif") {
                    HomeView(home: currentStoredHome)
                }
                
                Section("Mes pièces actives dans \(currentStoredHome.name)") {
                    if self.homeStoreViewModel.currentStoredRooms.isEmpty {
                        Text("Aucune pièce n'a été ajouté comme active. Toutes les pièces de \(currentStoredHome.name) sont donc actives par défaut.")
                    } else {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(self.homeStoreViewModel.currentStoredRooms, id: \.uniqueIdentifier) { room in
                                RoomView(room: room)
                                    .padding(10)
                                    .onTapGesture {
                                        self.selectedRoom = room
                                        self.showRoomActionDialog = true
                                    }
                            }
                        }
                    }
                    
                    NavigationLink(destination: RoomsView(home: currentStoredHome)) {
                        Button {} label: {
                            Text("Gérer les pièces pour \(currentStoredHome.name)")
                        }
                    }
                }
                
                Section("Mes ampoules actives dans \(currentStoredHome.name)") {
                    if self.homeStoreViewModel.currentStoredAccessories.isEmpty {
                        Text("Aucune ampoule n'a été ajouté comme active. Toutes les ampoules des pièces actives sont donc actives par défaut.")
                    } else {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(self.homeStoreViewModel.currentStoredAccessories, id: \.uniqueIdentifier) { accessory in
                                AccessoryView(accessory: accessory)
                                    .padding(10)
                                    .onTapGesture {
                                        self.selectedAccessory = accessory
                                        self.showAccessoryActionDialog = true
                                    }
                            }
                        }
                    }
                }
            } else {
                Text("Vous n'avez pas de domicile actif.")
                    .font(.title)
                NavigationLink(destination: HomesView()) {
                    Button {} label: {
                        Text("Gérer mes domiciles")
                    }
                }
            }
        }
        .confirmationDialog("Ma pièce", isPresented: self.$showRoomActionDialog) {
            if let selectedRoom = self.selectedRoom {
                if self.homeStoreViewModel.currentStoredRooms.contains(selectedRoom) {
                    Button("Retirer des pièces actives", role: .destructive) {
                        self.homeStoreViewModel.removeFromCurrentRooms(selectedRoom)
                    }
                }
                Button("Annuler", role: .cancel) { }
            }
        } message: {
            Text("Choisir une action pour \(self.selectedRoom?.name ?? "cette pièce")")
        }
        .confirmationDialog("Mon ampoule", isPresented: self.$showAccessoryActionDialog) {
            if let selectedAccessory = self.selectedAccessory {
                if self.homeStoreViewModel.currentStoredAccessories.contains(selectedAccessory) {
                    Button("Retirer des ampoules actives", role: .destructive) {
                        self.homeStoreViewModel.removeFromCurrentAccessories(selectedAccessory)
                    }
                }
                Button("Annuler", role: .cancel) { }
            }
        } message: {
            Text("Choisir une action pour \(self.selectedAccessory?.name ?? "cette ampoule")")
        }
    }
}

struct HomeKitTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeKitTabView()
    }
}
