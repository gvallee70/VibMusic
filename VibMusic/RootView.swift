//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import AudioKit

struct RootView: View {
    @State var deviceToUse: Device
    
    @ObservedObject var model: HomeStore
    @ObservedObject var audioKitViewModel: TunerConductor

    @State private var path = NavigationPath()
    
    @State var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
  
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: HStack {
                    Text("Gestion")
                }) {
                    NavigationLink(value: "HomeView"){
                        Text("Mon HomeKit")
                    }
                    .navigationDestination(for: String.self) {_ in
                        HomeView(model: self.model)
                    }
                }
                Section(header: HStack {
                    Text("Paramètres de Vib'Music")
                }) {
                    VStack(alignment: .leading) {
                        Text("Microphone")
                            .font(.subheadline)
                        Picker("Microphone", selection: $deviceToUse) {
                            ForEach(audioKitViewModel.getDevices(), id: \.self) {
                                Text("Micro \(String($0.deviceID.split(separator: " ")[2]))").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: deviceToUse) { newValue in
                            audioKitViewModel.setInputDevice(to: newValue)
                        }
                    }
                    .padding(.vertical, 5)
                
                    Toggle(isOn: $soundDetectionIsOn) {
                        Text("Utiliser la détection du son automatique")
                    }
                    .onAppear {
                        self.soundDetectionIsOn = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
                    }
                    .onChange(of: soundDetectionIsOn) { newValue in
                        UserDefaults.standard.set(soundDetectionIsOn, forKey: "soundDetectionIsOn")
                    }
                }
                
                AmplitudeSection(audioKitViewModel: self.audioKitViewModel)
                    .onAppear {
                        self.audioKitViewModel.homeViewModel = self.model
                        self.audioKitViewModel.start()
                    }
            }
            .navigationTitle("Vib'Music")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(deviceToUse: TunerConductor().initialDevice, model: HomeStore(), audioKitViewModel: TunerConductor())
    }
}
