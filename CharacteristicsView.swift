//
//  CharacteristicsView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//
import SwiftUI
import HomeKit
import AudioKitUI

struct CharacteristicsView: View {
    
    var service: HMService
   
    @ObservedObject var model: HomeStore
    @StateObject var audioKitViewModel = TunerConductor()

    @State private var hueSlider: Float = 0
    @State private var saturationSlider: Float = 0
    @State private var brightnessSlider: Float = 0
    @State private var powerStateIsOn: Bool = true
    @State private var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")

    var body: some View {
        List {
//            Section(header: HStack {
//                Text("\(model.services.first(where: {$0.uniqueIdentifier == serviceId})?.name ?? "No Service Name Found") Characteristics")
//            }) {
//                ForEach(model.characteristics, id: \.uniqueIdentifier) { characteristic in
//                    NavigationLink(value: characteristic){
//                        Text("\(characteristic.localizedDescription)")
//                    }.navigationDestination(for: HMCharacteristic.self) {
//                        Text($0.metadata?.description ?? "No metadata found")
//                    }
//                }
//
//            }
            Section(header: HStack {
                Text("Contrôle des paramètres pour \(service.name)")
            }) {
                Toggle("Power", isOn: $powerStateIsOn)
                    .onChange(of: powerStateIsOn) { value in
                        model.setCharacteristicValue(characteristic: self.model.characteristics.first(where: {$0.localizedDescription == "Power State"}), value: value)
                    }
                
                VStack {
                    Text("HUE")
                    Slider(value: $hueSlider, in: 0...360, step: 1.0) {
                        Text("Hue slider")
                    } minimumValueLabel: {
                        Text("\(Int(hueSlider))")
                    } maximumValueLabel: {
                        Text("360")
                    } onEditingChanged: { _ in
                        model.setCharacteristicValue(characteristic: self.model.characteristics.first(where: {$0.localizedDescription == "Hue"}), value: Int(hueSlider))
                    }
                }
                
                VStack {
                    Text("Saturation")
                    Slider(value: $saturationSlider, in: 0...100, step: 1.0) {
                        Text("Saturation slider")
                    } minimumValueLabel: {
                        Text("\(Int(saturationSlider))")
                    } maximumValueLabel: {
                        Text("100")
                    } onEditingChanged: { _ in
                        model.setCharacteristicValue(characteristic: self.model.characteristics.first(where: {$0.localizedDescription == "Saturation"}), value: Int(saturationSlider))
                    }
                }
            
                VStack {
                    Text("Brightness")
                    Slider(value: $brightnessSlider, in: 0...100, step: 1.0) {
                        Text("Brightness slider")
                    } minimumValueLabel: {
                        Text("\(Int(brightnessSlider))")
                    } maximumValueLabel: {
                        Text("100")
                    } onEditingChanged: { _ in
                        let brightnessCharacteristic = model.characteristics.first(where: {$0.localizedDescription == "Brightness"})
                        
                        model.setCharacteristicValue(characteristic: brightnessCharacteristic, value: Int(brightnessSlider))
                    
                    }
                }
            }
            .disabled(self.soundDetectionIsOn)
            
            Button(role: self.soundDetectionIsOn ? .cancel : .destructive) {
                self.soundDetectionIsOn.toggle()
                UserDefaults.standard.set(self.soundDetectionIsOn, forKey: "soundDetectionIsOn")
            } label: {
                Text(self.soundDetectionIsOn ? "Modifier manuellement" : "Arrêter modification manuelle")
            }
            
            AmplitudeSection(audioKitViewModel: self.audioKitViewModel)
                .onAppear {
                    self.audioKitViewModel.homeViewModel = self.model
                    self.audioKitViewModel.start()
                }
        }
        .navigationTitle("Paramètres du service")
        .onAppear {
            self.model.findCharacteristics(from: self.service)
            self.model.readCharacteristicValues(service: self.service)
            
            if let powerState = model.powerState, let brightness = model.brightnessValue, let hue = model.hueValue, let saturation = model.saturationValue {
                self.powerStateIsOn = powerState
                self.brightnessSlider = Float(brightness)
                self.hueSlider = Float(hue)
                self.saturationSlider = Float(saturation)
            }
            
        }
        .onChange(of: audioKitViewModel.data.amplitude) { newValue in
            if self.soundDetectionIsOn {
                brightnessSlider = Float(audioKitViewModel.brightnessRegressionDict[round(newValue * 10) / 10.0] ?? 0)
                
                model.setCharacteristicValue(characteristic: model.characteristics.first(where: {$0.localizedDescription == "Brightness"}), value:  brightnessSlider)
            }
        }
    }
}
