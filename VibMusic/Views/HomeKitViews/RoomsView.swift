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
    @State var showAddRoomAlert = false
    @State var roomName = ""

    var body: some View {
        List {
            Button {
                self.showAddRoomAlert.toggle()
            } label: {
                HStack(spacing: 10) {
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
                ForEach(self.homeStoreViewModel.rooms, id: \.uniqueIdentifier) { room in
                    NavigationLink(destination: AccessoriesView(home: self.home, room: room)) {
                        Text(room.name)
                    }
                }
            }
        }
        .navigationTitle("Mes pièces")
        .onAppear {
            self.homeStoreViewModel.getRooms(from: self.home)
        }
        
    }
}
