//
//  Tuner.swift
//  VibMusic
//
//  Created by Gwendal on 21/12/2022.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI
import HomeKit

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
}

class TunerConductor: ObservableObject, HasAudioEngine {
    @Published var data = TunerData()
    @Published var homeViewModel: HomeStore?
    
    let engine = AudioEngine()
    let initialDevice: Device?

    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader

    var tracker: PitchTap!
    
    var brightnessRegressionDict: [Float:Int] = [
        0:0, 0.1:90, 0.2:80, 0.3:70, 0.4:60, 0.5:50, 0.6:40, 0.7:30, 0.8:20, 0.9: 10, 1:10
    ]

    init() {
        guard let input = engine.input else { fatalError() }

        initialDevice = engine.inputDevice

        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence

        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }

    func getDevices() -> [Device] {
        AudioEngine.inputDevices.compactMap { $0 }
    }

    func setInputDevice(to device: Device) {
        do {
            try AudioEngine.setInputDevice(device)
        } catch let err {
            print(err)
        }
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.1 else { return }

        data.pitch = pitch
        data.amplitude = amp
        
        guard let homeViewModel = self.homeViewModel else {
            return
        }
        
        if let currentStoredHome = homeViewModel.currentStoredHome {
            if homeViewModel.currentStoredRooms.isEmpty {
                homeViewModel.getAllLightbulbsServicesForAllRooms(from: currentStoredHome)
            } else if homeViewModel.currentStoredAccessories.isEmpty {
                homeViewModel.getAllLightbulbsServices(from: homeViewModel.currentStoredRooms)
            } else {
                homeViewModel.getAllLightbulbsServices(from: homeViewModel.currentStoredAccessories)
            }
            
            homeViewModel.lightbulbsServices.forEach({ service in
                service.characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                        homeViewModel.setCharacteristicValue(characteristic: characteristic, value: Float(self.brightnessRegressionDict[round(data.amplitude * 10) / 10.0] ?? 0))
                    }
                }
            })
        }
        print(data.amplitude)
    }
}
