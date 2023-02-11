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
    @Published var currentAmbiance: Ambiance?
    
    init() {
        self.getAmbiances()
        self.getCurrentAmbiance()
    }

    func store(_ ambiance: Ambiance) {
        do {
            self.storedAmbiances.removeAll(where: { $0.id == ambiance.id })
            self.storedAmbiances.append(ambiance)
            
            let encodedAmbiances = try JSONEncoder().encode(self.storedAmbiances)
            
            UserDefaults.standard.set(encodedAmbiances, forKey: "ambiances")
            self.getAmbiances()
        } catch {
            print("Unable to store ambiance (\(error))")
        }
    }
    
    func storeCurrentAmbiance(_ ambiance: Ambiance) {
        do {
            let encodedAmbiance = try JSONEncoder().encode(ambiance)
            
            UserDefaults.standard.set(encodedAmbiance, forKey: "currentAmbiance")
            self.getCurrentAmbiance()
        } catch {
            print("Unable to store current ambiance (\(error))")
        }
    }
    
    func delete(_ ambiance: Ambiance) {
        do {
            if let indexToRemove = self.storedAmbiances.firstIndex(of: ambiance) {
                self.storedAmbiances.remove(at: indexToRemove)
            }

            let encodedAmbiances = try JSONEncoder().encode(self.storedAmbiances)
            
            UserDefaults.standard.set(encodedAmbiances, forKey: "ambiances")
            self.getAmbiances()
        } catch {
            print("Unable to delete ambiance (\(error))")
        }
    }
    
    
    func getAmbiances() {
        self.ambiances.removeAll()

        self.getCurrentAmbiance()
        
        if let currentAmbiance = self.currentAmbiance {
            self.ambiances.append(currentAmbiance)
        }
        
        self.getStoredAmbiances()
        self.getBasicAmbiances()
    }
    
    func getCurrentAmbiance() {
        guard let data = UserDefaults.standard.data(forKey: "currentAmbiance") else { return }
        
        do {
            self.currentAmbiance = try JSONDecoder().decode(Ambiance.self, from: data)
            
        } catch {
            print("Unable to retrieve current ambiance (\(error))")
        }
    }
    
    private func getBasicAmbiances() {
        let ambiances = [
            Ambiance(id: 1, name: "Jazz", lightHue: 5, lightSaturation: 50, lightBrightness: 30),
            Ambiance(id: 2, name: "Relax", lightHue: 160, lightSaturation: 50, lightBrightness: 50),
            Ambiance(id: 3, name: "Metal", lightHue: 200, lightSaturation: 13, lightBrightness: 60)
        ]
        
        ambiances.forEach { ambiance in
            if !self.ambiances.contains(ambiance) {
                self.ambiances.append(ambiance)
            }
        }
    }
    
    private func getStoredAmbiances() {
        guard let data = UserDefaults.standard.data(forKey: "ambiances") else { return }
        
        do {
            let storedAmbiances = try JSONDecoder().decode([Ambiance].self, from: data)
            
            storedAmbiances.forEach { ambiance in
                if !self.storedAmbiances.contains(ambiance) {
                    self.storedAmbiances.append(ambiance)
                }
                
                if !self.ambiances.contains(ambiance) {
                    self.ambiances.append(ambiance)
                }
            }
        } catch {
            print("Unable to retrieve ambiances (\(error))")
        }
    }

}
