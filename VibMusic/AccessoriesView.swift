//
//  AccessoriesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    var home: HMHome
    @ObservedObject var model: HomeStore

    var body: some View {
        List {
            Button {
                model.addAccessory(to: home)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Ajouter un accessoire pour \(home.name)")
                }
            }
            
            Section(header: HStack {
                Text("Mes accessoires pour \(home.name)")
            }) {
                ForEach(model.accessories, id: \.uniqueIdentifier) { accessory in
                    NavigationLink(destination: ServicesView(accessory: accessory, model: self.model)) {
                        Text(accessory.name)
                    }
                }
            }
        }
        .navigationTitle("Mes accessoires")
        .onAppear(){
            model.findAccessories(from: self.home)
        }

    }
}
