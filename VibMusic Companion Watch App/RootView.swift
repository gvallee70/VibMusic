//
//  ContentView.swift
//  VibMusic Companion Watch App
//
//  Created by Gwendal on 12/02/2023.
//

import SwiftUI
import WatchConnectivity

struct RootView: View {    
    @ObservedObject var watchSessionDelegate = WatchSessionDelegate()
    @State private var selectedAmbiance: Ambiance?
    @ObservedObject var ambiancesStoreViewModel = AmbiancesViewModel()
    
    var body: some View {
        VStack {
            if self.watchSessionDelegate.ambiances.isEmpty {
                Text("Ouvrez l'application Vib'Music sur iOS pour accéder à la liste des ambiances")
            } else {
                Text("Choisissez une ambiance")
                    .font(.footnote)
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(self.$watchSessionDelegate.ambiances, id: \.id) { ambiance in
                                AmbianceView(ambiance: ambiance)
                                    .id(ambiance.wrappedValue.id)
                                    .overlay(alignment: .topTrailing) {
                                        if self.selectedAmbiance == ambiance.wrappedValue {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green, lineWidth: 5)
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        self.selectedAmbiance = ambiance.wrappedValue
                                        self.watchSessionDelegate.sendCurrentAmbianceToIOSApp(ambiance.wrappedValue)
                                    })
                                    .padding(5)
                                    .foregroundColor(.white)
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    proxy.scrollTo(self.selectedAmbiance?.id)
                                }
                            }
                            self.selectedAmbiance = self.watchSessionDelegate.currentAmbiance
                        }
                        .onChange(of: self.watchSessionDelegate.currentAmbiance) { newCurrentAmbiance in
                            self.selectedAmbiance = newCurrentAmbiance

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    proxy.scrollTo(newCurrentAmbiance?.id)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
