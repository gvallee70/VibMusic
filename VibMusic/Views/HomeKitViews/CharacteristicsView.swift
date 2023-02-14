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

    @EnvironmentObject var homeStoreViewModel: HomeStore
    @EnvironmentObject var audioKitViewModel: TunerConductor
    
    @State var service: HMService

    @State private var hueSlider: Float = 0
    @State private var saturationSlider: Float = 0
    @State private var brightnessSlider: Float = 0
    @State private var powerStateIsOn: Bool = true
    @State private var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")

    var body: some View {
        List {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    if self.powerStateIsOn {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 60, toFrame: 80)
                        Text("ON")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(hue: Double(self.hueSlider)/360, saturation: Double(self.saturationSlider)/100, brightness: Double(self.brightnessSlider)/100))
                    } else {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 0, toFrame: 5)
                        Text("OFF")
                            .font(.title2)
                            .bold()
                    }
                }
                .frame(width: 300, height: 200, alignment: .center)

                if self.soundDetectionIsOn {
                    LottieView(filename: "MicOn", fromFrame: 20, toFrame: 100)
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
            .disabled(!self.powerStateIsOn)
           
            
            Section(header: HStack {
                Text("Contrôle des paramètres pour \(service.name)")
            }) {
                Toggle("Power", isOn: $powerStateIsOn)
                    .onChange(of: powerStateIsOn) { value in
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypePowerState}), value: value)
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
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeHue}), value: Int(hueSlider))
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
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeSaturation}), value: Int(saturationSlider))
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
                        let brightnessCharacteristic = homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeBrightness})
                        
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
            self.homeStoreViewModel.readCharacteristicValues()
           
            self.powerStateIsOn = homeStoreViewModel.powerState
            self.brightnessSlider = Float(homeStoreViewModel.brightnessValue)
            self.hueSlider = Float(homeStoreViewModel.hueValue)
            self.saturationSlider = Float(homeStoreViewModel.saturationValue)
            
            if !self.powerStateIsOn {
                self.soundDetectionIsOn = false
            }
        }
        .onChange(of: audioKitViewModel.data.amplitude) { newValue in
            if scenePhase == .active || scenePhase == .background || scenePhase == .inactive {
                if self.soundDetectionIsOn {
                    print(self.brightnessSlider)

                    brightnessSlider = Float(audioKitViewModel.brightnessRegressionDict[round(newValue * 10) / 10.0] ?? 0)
                    
                    homeStoreViewModel.setCharacteristicValue(characteristic: homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeBrightness}), value:  brightnessSlider)
                }
            }
        }
    }
}
