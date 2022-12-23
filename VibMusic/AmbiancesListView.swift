//
//  AmbiancesView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbiancesListView: View {
    @State private var showAddAmbianceSheet = false
    @State private var nameTextFieldValue = ""
    @State private var hueSliderValue = 0.0
    @State private var saturationSliderValue = 50.0
    @State private var brightnessSliderValue = 50.0


    @ObservedObject var viewModel: AmbiancesViewModel

    var body: some View {
        List {
            Button {
                self.showAddAmbianceSheet.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Ajouter une ambiance")
                }
            }
            .sheet(isPresented: $showAddAmbianceSheet) {
                List {
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
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                }
            }
        }
        ScrollView {
           LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
               ForEach(self.viewModel.ambiances, id: \.id) { ambiance in
                   ZStack {
                       RoundedRectangle(cornerRadius: 12)
                           .frame(height: 100)
                           .foregroundColor(Color(hue: Double(ambiance.lightHue), saturation: Double(ambiance.lightSaturation), brightness: Double(ambiance.lightBrightness)))
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
                   .padding(10)
               }
           }
        }
        .padding()
        .navigationTitle("Mes ambiances")
    }
}

struct AmbiancesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("toto")
        //AmbiancesListView()
    }
}
