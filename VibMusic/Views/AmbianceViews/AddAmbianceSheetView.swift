//
//  AddAmbianceSheetView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AddAmbianceSheetView: View {
    @Environment(\.dismiss) var dismiss

    @State private var nameTextFieldValue = ""
    @State private var hueSliderValue = 0.0
    @State private var saturationSliderValue = 50.0
    @State private var brightnessSliderValue = 50.0
    
    @ObservedObject var viewModel: AmbiancesViewModel
    
    var body: some View {
        VStack {
            Text("Ajouter une ambiance")
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
            

            Button("Ajouter une ambiance") {
                let ambiance = Ambiance(id: self.viewModel.ambiances.count + 1, name: nameTextFieldValue, lightHue: Int(hueSliderValue), lightSaturation: Int(saturationSliderValue), lightBrightness: Int(brightnessSliderValue))
        
                self.viewModel.store(ambiance)
                self.dismiss()
            }
            .disabled(nameTextFieldValue.isEmpty)
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

struct AddAmbianceSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddAmbianceSheetView(viewModel: AmbiancesViewModel())
    }
}
