//
//  AccessoriesView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    var homeId: UUID
    @ObservedObject var model: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
                Text("My Accessories")
            }) {
                ForEach(model.accessories, id: \.uniqueIdentifier) { accessory in
                    NavigationLink(value: accessory){
                        Text("\(accessory.name)")
                    }.navigationDestination(for: HMAccessory.self) {
                        ServicesView(accessoryId: $0.uniqueIdentifier, homeId: homeId, model: model)
                    }
                }
            }
        }.onAppear(){
            model.findAccessories(homeId: homeId)
        }
    }
}
