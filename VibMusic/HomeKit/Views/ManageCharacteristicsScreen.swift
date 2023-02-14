//
//  ManageCharacteristicsScreen.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//
import SwiftUI
import HomeKit
import AudioKitUI

struct ManageCharacteristicsScreen: View {
    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel
    @EnvironmentObject var audioKitViewModel: AudioKitViewModel
    
    @State var service: HMService

    @State private var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")

    var body: some View {
        List {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    if self.homeStoreViewModel.powerState {
                        LottieView(filename: "LightbulbOnOff", fromFrame: 60, toFrame: 80)
                        Text("ON")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(hue: self.homeStoreViewModel.hueValue/360, saturation: self.homeStoreViewModel.saturationValue/100, brightness: self.homeStoreViewModel.brightnessValue/100))
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
        
            
            Section(header: HStack {
                Text("Contrôle des paramètres pour \(service.name)")
            }) {
                Toggle("Power", isOn: self.$homeStoreViewModel.powerState)
                    .onChange(of: self.homeStoreViewModel.powerState) { value in
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypePowerState}), value: value)
                    }
                
                VStack {
                    Text("HUE")
                    Slider(value: self.$homeStoreViewModel.hueValue, in: 0...360, step: 1.0) {
                        Text("Hue slider")
                    } minimumValueLabel: {
                        Text("\(Int(self.homeStoreViewModel.hueValue))")
                    } maximumValueLabel: {
                        Text("360")
                    } onEditingChanged: { _ in
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeHue}), value: Int(self.homeStoreViewModel.hueValue))
                    }
                }
                
                VStack {
                    Text("Saturation")
                    Slider(value: self.$homeStoreViewModel.saturationValue, in: 0...100, step: 1.0) {
                        Text("Saturation slider")
                    } minimumValueLabel: {
                        Text("\(Int(self.homeStoreViewModel.saturationValue))")
                    } maximumValueLabel: {
                        Text("100")
                    } onEditingChanged: { _ in
                        homeStoreViewModel.setCharacteristicValue(characteristic: self.homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeSaturation}), value: Int(self.homeStoreViewModel.saturationValue))
                    }
                }
            
                VStack {
                    Text("Brightness")
                    Slider(value: self.$homeStoreViewModel.brightnessValue, in: 0...100, step: 1.0) {
                        Text("Brightness slider")
                    } minimumValueLabel: {
                        Text("\(Int(self.homeStoreViewModel.brightnessValue))")
                    } maximumValueLabel: {
                        Text("100")
                    } onEditingChanged: { _ in
                        let brightnessCharacteristic = homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeBrightness})
                        
                        homeStoreViewModel.setCharacteristicValue(characteristic: brightnessCharacteristic, value: Int(self.homeStoreViewModel.brightnessValue))
                    
                    }
                }
            }
            
            AmplitudeSectionView(audioKitViewModel: self.audioKitViewModel)
                .onAppear {
                    self.audioKitViewModel.homeStoreViewModel = self.homeStoreViewModel
                    self.audioKitViewModel.start()
                }
        }
        .navigationTitle("Paramètres du service")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            self.homeStoreViewModel.getCharacteristics(from: self.service)
            self.homeStoreViewModel.readCharacteristicValues()
           
            self.soundDetectionIsOn = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")

        }
        .onChange(of: audioKitViewModel.data.amplitude) { newValue in
            if scenePhase == .active || scenePhase == .background || scenePhase == .inactive {
                if self.soundDetectionIsOn {
                    self.homeStoreViewModel.brightnessValue = Double(audioKitViewModel.brightnessRegressionDict[round(newValue * 10) / 10.0] ?? 0)
                    
                    homeStoreViewModel.setCharacteristicValue(characteristic: homeStoreViewModel.characteristics.first(where: {$0.characteristicType == HMCharacteristicTypeBrightness}), value:  self.homeStoreViewModel.brightnessValue)
                }
            }
        }
    }
}
