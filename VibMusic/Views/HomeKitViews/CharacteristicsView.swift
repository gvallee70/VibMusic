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
    @Environment(\.scenePhase) var scenePhase

    var service: HMService
   
    @EnvironmentObject var homeStoreViewModel: HomeStore
    @EnvironmentObject var audioKitViewModel: TunerConductor

    @State private var hueSlider: Float = 0
    @State private var saturationSlider: Float = 0
    @State private var brightnessSlider: Float = 0
    @State private var powerStateIsOn: Bool = true
    @State private var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")

    var body: some View {
        List {
            VStack {
                Group {
                    if self.powerStateIsOn && self.brightnessSlider > 70 {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 50, toFrame: 80)
                    } else if self.powerStateIsOn && (5...70).contains(self.brightnessSlider)  {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 30, toFrame: 40)
                    } else {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 0, toFrame: 5)
                    }
                }
                .frame(width: 300, height: 200)
        
                if self.soundDetectionIsOn {
                    LottieView(filename: "MicOn")
                        .frame(width: 200, height: 100)
                }
            }
            .listRowBackground(Color.clear)
            
            
            Button(role: .cancel) {
                self.soundDetectionIsOn.toggle()
                UserDefaults.standard.set(self.soundDetectionIsOn, forKey: "soundDetectionIsOn")
            } label: {
                HStack {
                    Image(systemName: self.soundDetectionIsOn ? "slider.horizontal.3" : "waveform.and.mic")
                    Text("Basculer vers modification \(self.soundDetectionIsOn ? "manuelle" : "automatique")")
                }
            }
           
            
            Section(header: HStack {
                Text("Contrôle des paramètres pour \(service.name)")
            }) {
                Toggle("Power", isOn: $powerStateIsOn)
                    .onChange(of: powerStateIsOn) { value in
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.localizedDescription == "Power State"}), value: value)
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
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.localizedDescription == "Hue"}), value: Int(hueSlider))
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
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.localizedDescription == "Saturation"}), value: Int(saturationSlider))
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
                        let brightnessCharacteristic = homeStoreViewModel.characteristics.first(where: {$0.localizedDescription == "Brightness"})
                        
                        homeStoreViewModel.setCharacteristicValue(characteristic: brightnessCharacteristic, value: Int(brightnessSlider))
                    
                    }
                }
            }
            .disabled(self.soundDetectionIsOn)
            
            AmplitudeSection(audioKitViewModel: self.audioKitViewModel)
                .onAppear {
                    self.audioKitViewModel.homeViewModel = self.homeStoreViewModel
                    self.audioKitViewModel.start()
                }
        }
        .navigationTitle("Paramètres du service")
        .onAppear {
            self.homeStoreViewModel.getCharacteristics(from: self.service)
            self.homeStoreViewModel.readCharacteristicValues(service: self.service)
            
            if let powerState = homeStoreViewModel.powerState, let brightness = homeStoreViewModel.brightnessValue, let hue = homeStoreViewModel.hueValue, let saturation = homeStoreViewModel.saturationValue {
                self.powerStateIsOn = powerState
                self.brightnessSlider = Float(brightness)
                self.hueSlider = Float(hue)
                self.saturationSlider = Float(saturation)
            }
            
        }
        .onChange(of: audioKitViewModel.data.amplitude) { newValue in
            if scenePhase == .active || scenePhase == .background || scenePhase == .inactive {
                if self.soundDetectionIsOn {
                    print(self.brightnessSlider)

                    brightnessSlider = Float(audioKitViewModel.brightnessRegressionDict[round(newValue * 10) / 10.0] ?? 0)
                    
                    homeStoreViewModel.setCharacteristicValue(characteristic: homeStoreViewModel.characteristics.first(where: {$0.localizedDescription == "Brightness"}), value:  brightnessSlider)
                }
            }
        }
    }
}
