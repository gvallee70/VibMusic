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

    @EnvironmentObject var homeStoreViewModel: HomeStore

    var body: some View {
        List {
            Section(header: HStack {
                Text("Mes services pour \(accessory.name)")
            }) {
                ForEach(self.homeStoreViewModel.services, id: \.uniqueIdentifier) { service in
                    NavigationLink(destination: CharacteristicsView(service: service)) {
                        Text(service.name)
                    }
                }
            }
        }
        .navigationTitle("Services")
        .onAppear(){
            self.homeStoreViewModel.getServices(from: self.accessory)
        }
    }
}
