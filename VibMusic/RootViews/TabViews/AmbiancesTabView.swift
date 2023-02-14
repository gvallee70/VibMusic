//
//  AmbiancesTabView.swift
//  VibMusic
//
//  Created by Gwendal on 14/02/2023.
//

import SwiftUI

struct AmbiancesTabView: View {
    @EnvironmentObject var ambiancesStoreViewModel: AmbiancesViewModel
    @EnvironmentObject var iphoneSessionDelegate: iPhoneSessionDelegate
    
    @State private var selectedAmbiance: Ambiance?

    var body: some View {
        List {
            Section("Mes ambiances") {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(self.$ambiancesStoreViewModel.ambiances, id: \.id) { ambiance in
                                AmbianceView(ambiance: ambiance)
                                    .id(ambiance.wrappedValue.id)
                                    .overlay {
                                        if self.selectedAmbiance == ambiance.wrappedValue {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green, lineWidth: 8)
                                        }
                                    }
                                    .padding(10)
                                    .onTapGesture {
                                        self.selectedAmbiance = ambiance.wrappedValue
                                        self.ambiancesStoreViewModel.storeCurrentAmbiance(ambiance.wrappedValue)
                                    }
                            }
                            .onChange(of: self.selectedAmbiance) { newCurrentAmbiance in
                                self.iphoneSessionDelegate.sendCurrentAmbianceToWatchApp(newCurrentAmbiance)
                                
                                withAnimation {
                                    proxy.scrollTo(newCurrentAmbiance?.id)
                                }
                            }
                            .onChange(of: self.iphoneSessionDelegate.currentAmbiance) { newCurrentAmbiance in
                                self.selectedAmbiance = newCurrentAmbiance
                                self.ambiancesStoreViewModel.storeCurrentAmbiance(newCurrentAmbiance!)
                                
                                withAnimation {
                                    proxy.scrollTo(newCurrentAmbiance?.id)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onReceive(self.ambiancesStoreViewModel.$currentAmbiance) { newValue in 
            self.selectedAmbiance = self.ambiancesStoreViewModel.currentAmbiance
        }
        .onChange(of: self.ambiancesStoreViewModel.ambiances) { _ in
            self.iphoneSessionDelegate.sendAmbiancesToWatchApp(ambiances: self.ambiancesStoreViewModel.ambiances)
        }
    }
}
