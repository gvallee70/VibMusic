//
//  AmbiancesViewModel.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI
import HomeKit

class AmbiancesViewModel: ObservableObject {
    
    @Published var ambiances: [Ambiance] = []
    @Published var storedAmbiances: [Ambiance] = []
    @Published var currentAmbiance: Ambiance?
    
    @Published var homeStoreViewModel: HomeStoreViewModel?

    init() {
        self.getAmbiances()
        self.getCurrentAmbiance()
    }

    func store(_ ambiance: Ambiance) {
        do {
            if let indexToUpdate = self.storedAmbiances.firstIndex(of: ambiance) {
                self.storedAmbiances.insert(ambiance, at: indexToUpdate)
            } else {
                self.storedAmbiances.append(ambiance)
            }
            
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
            self.getAmbiances()
            
            guard let homeStoreViewModel = self.homeStoreViewModel else {
                return
            }
            
            if let currentStoredHome = homeStoreViewModel.currentStoredHome {
                self.homeStoreViewModel?.getLightbulbsServicesToUpdate(from: currentStoredHome)
                
                homeStoreViewModel.lightbulbsServices.forEach({ service in
                    service.characteristics.forEach { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                            homeStoreViewModel.setCharacteristicValue(characteristic: characteristic, value: ambiance.lightBrightness)
                        }
                        
                        if characteristic.characteristicType == HMCharacteristicTypeHue {
                            homeStoreViewModel.setCharacteristicValue(characteristic: characteristic, value: ambiance.lightHue)
                        }
                        
                        if characteristic.characteristicType == HMCharacteristicTypeSaturation {
                            homeStoreViewModel.setCharacteristicValue(characteristic: characteristic, value: ambiance.lightSaturation)
                        }
                    }
                })
            }

        } catch {
            print("Unable to store current ambiance (\(error))")
        }
    }
    
    func delete(_ ambiance: Ambiance) {
        do {
            self.storedAmbiances.removeAll(where: { $0.id == ambiance.id })

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
        
        if let currentAmbiance = self.currentAmbiance {
            if let indexToUpdate = self.ambiances.firstIndex(of: currentAmbiance) {
                self.ambiances.remove(at: indexToUpdate)
            }
        }

        
        self.ambiances = self.ambiances.sorted { $0.name < $1.name }
        
        if let currentAmbiance = self.currentAmbiance {
            self.ambiances.insert(currentAmbiance, at: 0)
        }
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
