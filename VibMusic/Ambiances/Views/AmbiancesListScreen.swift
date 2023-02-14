//
//  AmbiancesListScreen.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbiancesListScreen: View {
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
                                            self.ambianceToModify = ambiance.wrappedValue
                                            self.showManageAmbianceSheet = true
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
                            .onTapGesture {
                                if self.isModifyMode && self.selectedAmbiance != ambiance.wrappedValue && self.ambiancesStoreViewModel.storedAmbiances.contains(ambiance.wrappedValue) {
                                    self.ambianceToModify = ambiance.wrappedValue
                                    self.showManageAmbianceSheet.toggle()
                                } else {
                                    self.selectedAmbiance = ambiance.wrappedValue
                                    self.ambiancesStoreViewModel.storeCurrentAmbiance(ambiance.wrappedValue)
                                    withAnimation {
                                        proxy.scrollTo(self.selectedAmbiance?.id)
                                    }
                                }
                            }
                    }
                    
                }
                .padding(10)
                .onReceive(self.ambiancesStoreViewModel.$currentAmbiance) { newAmbiance in
                    self.selectedAmbiance = newAmbiance
                    withAnimation {
                        proxy.scrollTo(newAmbiance?.id)
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationTitle("Mes ambiances")
        .scrollIndicators(.hidden)
        .sheet(isPresented: self.$showManageAmbianceSheet, content: {
            ManageAmbianceView(ambiance: self.$ambianceToModify)
        })
        .onAppear {
            self.selectedAmbiance = self.ambiancesStoreViewModel.currentAmbiance
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
