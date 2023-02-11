//
//  AmbiancesView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbiancesListView: View {
    @State private var showAddAmbianceSheet = false
    @State private var modifyAmbianceIsEnabled = false
    @State private var selectedAmbiance: Ambiance?
    
    @ObservedObject var viewModel = AmbiancesViewModel()

    var body: some View {
        List {
            Section {
                Button {
                    self.showAddAmbianceSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Ajouter une ambiance")
                    }
                }
                .sheet(isPresented: self.$showAddAmbianceSheet) {
                    List {
                        AddAmbianceSheetView(viewModel: self.viewModel)
                    }
                }
                
                Button(role: .destructive) {
                    withAnimation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                        self.modifyAmbianceIsEnabled.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Modifier une ambiance")
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 150)
            
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                ForEach(self.viewModel.ambiances, id: \.id) { ambiance in
                    NavigationLink(destination: self.modifyAmbianceIsEnabled ? AmbianceView(ambiance: ambiance, viewModel: self.viewModel) : nil) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 100)
                                .foregroundColor(Color(hue: Double(ambiance.lightHue)/360, saturation: Double(ambiance.lightSaturation)/100, brightness: Double(ambiance.lightBrightness)/100, opacity: 1.0))
                            VStack {
                                Text(ambiance.name)
                                    .font(.title)
                                    .padding(2)
                                HStack {
                                    Image(systemName: ambiance.lightBrightness < 50 ? "light.min" : "light.max")
                                    Text("\(ambiance.lightBrightness)%")
                                }
                            }
                        }
                        .rotationEffect(.degrees(self.modifyAmbianceIsEnabled ? 0 : 0))
                        .overlay(alignment: .topTrailing) {
                            if self.selectedAmbiance == ambiance {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 5)
                            } else {
                                Button(action: {
                                    
                                }, label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                })
                                .opacity(self.modifyAmbianceIsEnabled ? 1 : 0)
                                .animation(nil)
                            }
                        }
                        .padding(10)
                    }
                    .disabled(!self.modifyAmbianceIsEnabled)
                    .simultaneousGesture(TapGesture().onEnded {
                        if !self.modifyAmbianceIsEnabled {
                            self.selectedAmbiance = ambiance
                            self.viewModel.storeCurrentAmbiance(ambiance)
                        }
                    })
                    .foregroundColor(.white)
                    .onAppear {
                        self.selectedAmbiance = self.viewModel.currentAmbiance
                    }
                }
            }
            .padding(10)
        }
        .listRowBackground(Color.clear)
        .navigationTitle("Mes ambiances")
        .scrollIndicators(.hidden)
    }
}
