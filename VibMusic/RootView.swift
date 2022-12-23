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
            Button(action: {
                path.append("HomeView")
            }, label: {
                Text("Mon HomeKit")
            })
            .frame(width: 300, height: 100)
            .buttonStyle(.bordered)
            .navigationDestination(for: String.self) {
                if $0 == "HomeView" {
                    HomeView(model: model)
                }
            }
            
            Spacer()
            List {
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
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(deviceToUse: TunerConductor().initialDevice, model: HomeStore(), audioKitViewModel: TunerConductor())
    }
}
