//
//  AddAmbianceSheetView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct ManageAmbianceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var ambiancesStoreViewModel: AmbiancesViewModel

    @Binding var ambiance: Ambiance?
    @State private var nameTextFieldValue = ""
    @State private var hueSliderValue = 0.0
    @State private var saturationSliderValue = 50.0
    @State private var brightnessSliderValue = 50.0
    
    var body: some View {
        VStack {
            Text(self.ambiance == nil ? "Ajouter une ambiance" : "Modifier \(self.ambiance?.name ?? "")")
                .font(.title)
                .padding()
            Divider()
            TextField("Nom", text: $nameTextFieldValue)
                .font(.title3)
                .padding(.vertical, 5)
                      
            Image(systemName: "lightbulb.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(Color(hue: hueSliderValue/360, saturation: saturationSliderValue/100, brightness: brightnessSliderValue/100))
                .padding()
            
            Group {
                Text("HUE")
                Slider(value: $hueSliderValue, in: 0...360, step: 1.0) {
                } minimumValueLabel: {
                    Text("\(Int(hueSliderValue))")
                } maximumValueLabel: {
                    Text("360")
                }
            }
            .padding(.vertical, 5)
            
            Divider()

            Group {
                Text("Saturation")
                Slider(value: $saturationSliderValue, in: 0...100, step: 1.0) {
                } minimumValueLabel: {
                    Text("\(Int(saturationSliderValue))")
                } maximumValueLabel: {
                    Text("100")
                }
            }
            .padding(.vertical, 5)
            
            Divider()

            Group {
                Text("Brightness")
                Slider(value: $brightnessSliderValue, in: 0...100, step: 1.0) {
                } minimumValueLabel: {
                    Text("\(Int(brightnessSliderValue))")
                } maximumValueLabel: {
                    Text("100")
                }
            }
            .padding(.vertical, 5)
            

            Button(self.ambiance == nil ? "Ajouter une ambiance" : "Modifier \(self.ambiance?.name ?? "")") {
            
                let ambiance = Ambiance(id: self.ambiance?.id ?? self.ambiancesStoreViewModel.ambiances.count + 1, name: nameTextFieldValue, lightHue: Int(hueSliderValue), lightSaturation: Int(saturationSliderValue), lightBrightness: Int(brightnessSliderValue))
        
                self.ambiancesStoreViewModel.store(ambiance)
                self.dismiss()
            }
            .disabled(nameTextFieldValue.isEmpty)
            .buttonStyle(.bordered)
            .padding()
        }
        .onAppear {
            if let ambiance = self.ambiance {
                self.nameTextFieldValue = ambiance.name
                self.hueSliderValue = Double(ambiance.lightHue)
                self.saturationSliderValue = Double(ambiance.lightSaturation)
                self.brightnessSliderValue = Double(ambiance.lightBrightness)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let ambiance = self.ambiance {
                    Button {
                        self.ambiancesStoreViewModel.delete(ambiance)
                        self.dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}
