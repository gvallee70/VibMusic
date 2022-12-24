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
            TextField("Nom", text: $nameTextFieldValue)
            Slider(value: $hueSliderValue, in: 0...360, step: 1.0) {
                Text("Hue slider")
            } minimumValueLabel: {
                Text("\(Int(hueSliderValue))")
            } maximumValueLabel: {
                Text("360")
            }
            Slider(value: $saturationSliderValue, in: 0...100, step: 1.0) {
                Text("Saturation slider")
            } minimumValueLabel: {
                Text("\(Int(saturationSliderValue))")
            } maximumValueLabel: {
                Text("100")
            }
            Slider(value: $brightnessSliderValue, in: 0...100, step: 1.0) {
                Text("Brightness slider")
            } minimumValueLabel: {
                Text("\(Int(brightnessSliderValue))")
            } maximumValueLabel: {
                Text("100")
            }
            Button("Ajouter une ambiance") {
                let ambiance = Ambiance(name: nameTextFieldValue, lightHue: Int(hueSliderValue), lightSaturation: Int(saturationSliderValue), lightBrightness: Int(brightnessSliderValue))
        
                self.viewModel.store(ambiance)
                self.dismiss()
            }
            .disabled(nameTextFieldValue.isEmpty)
            .buttonStyle(.bordered)
        }
    }
}

struct AddAmbianceSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddAmbianceSheetView(viewModel: AmbiancesViewModel())
    }
}
