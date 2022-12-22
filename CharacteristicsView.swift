//
//  CharacteristicsView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//
import SwiftUI
import HomeKit

struct CharacteristicsView: View {
    
    var serviceId: UUID
    var accessoryId: UUID
    var homeId: UUID
    @ObservedObject var model: HomeStore
    
    var body: some View {
        List {
            Section(header: HStack {
                Text("\(model.services.first(where: {$0.uniqueIdentifier == serviceId})?.name ?? "No Service Name Found") Characteristics")
            }) {
                ForEach(model.characteristics, id: \.uniqueIdentifier) { characteristic in
                    NavigationLink(value: characteristic){
                        Text("\(characteristic.localizedDescription)")
                    }.navigationDestination(for: HMCharacteristic.self) {
                        Text($0.metadata?.description ?? "No metadata found")
                    }
                }
            }
        }.onAppear(){
            model.findCharacteristics(serviceId: serviceId, accessoryId: accessoryId, homeId: homeId)
        }
    }
}
