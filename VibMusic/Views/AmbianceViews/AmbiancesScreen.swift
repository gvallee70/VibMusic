//
//  AmbiancesView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbiancesScreen: View {
    @EnvironmentObject var ambiancesStoreViewModel: AmbiancesViewModel
    @EnvironmentObject var iphoneSessionDelegate: iPhoneSessionDelegate

    @State private var showManageAmbianceSheet = false
    @State private var isModifyMode = false
    @State private var selectedAmbiance: Ambiance?
    @State private var ambianceToModify: Ambiance?

    var body: some View {
        List {
            Section {
                Button {
                    self.showManageAmbianceSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Ajouter une ambiance")
                    }
                }
                
                if self.ambiancesStoreViewModel.storedAmbiances.isNotEmpty {
                    Button(role: .destructive) {
                        self.isModifyMode.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text(self.isModifyMode ? "Annuler modification" : "Modifier une ambiance")
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 120)
            
        ScrollView {
            ScrollViewReader { proxy in
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    ForEach(self.$ambiancesStoreViewModel.ambiances, id: \.id) { ambiance in
                        AmbianceView(ambiance: ambiance)
                            .id(ambiance.wrappedValue.id)
                            .overlay(alignment: .topTrailing) {
                                if self.selectedAmbiance == ambiance.wrappedValue {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green, lineWidth: 8)
                                } else {
                                    if self.ambiancesStoreViewModel.storedAmbiances.contains(ambiance.wrappedValue) {
                                        Button(action: {
                                            self.showManageAmbianceSheet.toggle()
                                        }, label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .padding(2)
                                        })
                                        .opacity(self.isModifyMode ? 1 : 0)
                                    }
                                }
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .simultaneousGesture(TapGesture().onEnded {
                                if self.isModifyMode && self.selectedAmbiance != ambiance.wrappedValue && self.ambiancesStoreViewModel.storedAmbiances.contains(ambiance.wrappedValue) {
                                    self.ambianceToModify = ambiance.wrappedValue
                                    self.showManageAmbianceSheet.toggle()
                                } else {
                                    self.selectedAmbiance = ambiance.wrappedValue
                                    self.ambiancesStoreViewModel.storeCurrentAmbiance(ambiance.wrappedValue)
                                }
                            })
                    }
                    
                }
                .padding(10)
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
        .listRowBackground(Color.clear)
        .navigationTitle("Mes ambiances")
        .scrollIndicators(.hidden)
        .sheet(isPresented: self.$showManageAmbianceSheet, content: {
            ManageAmbianceView(ambiance: self.$ambianceToModify)
        })
        .onAppear {
            self.selectedAmbiance = self.ambiancesStoreViewModel.currentAmbiance
        }
        .onChange(of: self.ambiancesStoreViewModel.ambiances) { _ in
            self.iphoneSessionDelegate.sendAmbiancesToWatchApp(ambiances: self.ambiancesStoreViewModel.ambiances)
        }
        .onChange(of: self.showManageAmbianceSheet) { toggleSheet in
            if !toggleSheet {
                self.ambianceToModify = nil
                self.isModifyMode = false
                self.iphoneSessionDelegate.sendAmbiancesToWatchApp(ambiances: self.ambiancesStoreViewModel.ambiances)
            }
        }
    }
}
