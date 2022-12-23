//
//  AmbiancesViewModel.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

class AmbiancesViewModel: ObservableObject {
    
    @Published var ambiances: [Ambiance] = []
    @Published var storedAmbiances: [Ambiance] = []
    
    init() {
        self.getAmbiances()
    }

    func store(_ ambiance: Ambiance) {
        do {
            self.storedAmbiances.append(ambiance)
            let encodedAmbiances = try JSONEncoder().encode(self.storedAmbiances)
            
            UserDefaults.standard.set(encodedAmbiances, forKey: "ambiances")
        } catch {
            print("Unable to store ambiance (\(error))")
        }
    }
    
    func getAmbiances() {
        self.getStoredAmbiances()
        self.getBasicAmbiances()
    }
    
    private func getBasicAmbiances() {
        self.ambiances += [
            Ambiance(name: "Jazz", lightHue: 5, lightSaturation: 50, lightBrightness: 30),
            Ambiance(name: "Relax", lightHue: 160, lightSaturation: 50, lightBrightness: 50),
            Ambiance(name: "Metal", lightHue: 150, lightSaturation: 20, lightBrightness: 70)
        ]
    }
    
    private func getStoredAmbiances() {
        guard let data = UserDefaults.standard.data(forKey: "ambiances") else { return }
        
        do {
            self.storedAmbiances = try JSONDecoder().decode([Ambiance].self, from: data)
            self.ambiances += self.storedAmbiances
        } catch {
            print("Unable to retrieve ambiances (\(error))")
        }
    }

}
