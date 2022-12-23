//
//  ServicesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct ServicesView: View {
    
    var accessoryId: UUID
    var homeId: UUID
    @ObservedObject var model: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
                Text("Mes services pour \(model.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.name ?? "l'accessoire")")
            }) {
                ForEach(model.services, id: \.uniqueIdentifier) { service in
                    NavigationLink(value: service){
                        Text("\(service.name)")
                    }.navigationDestination(for: HMService.self) {
                        CharacteristicsView(serviceId: $0.uniqueIdentifier, accessoryId: self.accessoryId, homeId: self.homeId, model: self.model)
                    }
                }
            }
        }.onAppear(){
            model.findServices(accessoryId: self.accessoryId, homeId: self.homeId)
        }
    }
}
