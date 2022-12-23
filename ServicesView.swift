//
//  ServicesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct ServicesView: View {
    
    var accessory: HMAccessory

    @ObservedObject var model: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
                Text("Mes services pour \(accessory.name)")
            }) {
                ForEach(model.services, id: \.uniqueIdentifier) { service in
                    NavigationLink(destination: CharacteristicsView(service: service, model: self.model)) {
                        Text(service.name)
                    }
                }
            }
        }
        .navigationTitle("Services")
        .onAppear(){
            model.findServices(from: self.accessory)
        }
    }
}
