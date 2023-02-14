//
//  RoomsView.swift
//  VibMusic
//
//  Created by Gwendal on 13/02/2023.
//

import SwiftUI
import HomeKit

struct RoomsView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore

    @State var home: HMHome
    @State private var showAddRoomAlert = false
    @State private var showRoomActionDialog = false
    @State private var roomName = ""
    @State private var selectedRoom: HMRoom?

    var body: some View {
        List {
            Button {
                self.showAddRoomAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Ajouter une pièce à \(self.home.name)")
                }
            }
            .alert("Ajouter une pièce", isPresented: self.$showAddRoomAlert) {
                TextField("Nom", text: self.$roomName)
                
                Button("Ajouter", action: {
                    if self.roomName.isNotEmpty {
                        self.homeStoreViewModel.addRoom(self.roomName, to: self.home)
                        self.roomName = ""
                    }
                })
                
                Button("Non", role: .cancel, action: {                     self.showAddRoomAlert.toggle()
                })
            }
            
            Section(header: HStack {
            }) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    ForEach(self.homeStoreViewModel.rooms, id: \.uniqueIdentifier) { room in
                        RoomView(room: room)
                            .padding(10)
                            .onTapGesture {
                                self.selectedRoom = room
                                self.showRoomActionDialog = true
                            }
                    }
                }
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                    VStack(alignment: .leading) {
                        Text("Cliquez sur une pièce pour choisir une action.")
                            .padding(.bottom, 2)
                        Text("Si aucune pièce n'est ajouter aux pièces courantes, toutes les pièces de \(self.home.name) sont considérés comme courante.")
                    }
                    .font(.footnote)
                }
            }
            
        }
        .navigationTitle("Mes pièces")
        .confirmationDialog("Ma pièce", isPresented: self.$showRoomActionDialog) {
            if let selectedRoom = self.selectedRoom {
                NavigationLink(destination: AccessoriesView(home: self.home, room: selectedRoom)) {
                    Text("Voir les détails")
                }
                if self.homeStoreViewModel.currentStoredRooms.contains(selectedRoom) {
                    Button("Retirer des pièces courantes", role: .destructive) {
                        self.homeStoreViewModel.removeFromCurrentRooms(selectedRoom)
                    }
                } else {
                    if self.homeStoreViewModel.currentStoredHome == self.home {
                        Button("Ajouter aux pièces courantes") {
                            self.homeStoreViewModel.addCurrentRoom(selectedRoom)
                        }
                    }
                }
                
                Button("Annuler", role: .cancel) { }
            }
        } message: {
            Text("Choisir une action pour \(self.selectedRoom?.name ?? "cette pièce")")
        }
        .onAppear {
            self.homeStoreViewModel.getRooms(from: self.home)
            self.homeStoreViewModel.getCurrentRooms()
        }
        
    }
}
