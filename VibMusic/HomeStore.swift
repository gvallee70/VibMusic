//
//  HomeStore.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import Foundation
import HomeKit
import Combine

class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate, HMAccessoryBrowserDelegate {
    
    
    @Published var homes: [HMHome] = []
    @Published var selectedHome: HMHome?

    @Published var accessories: [HMAccessory] = []
    @Published var services: [HMService] = []
    @Published var characteristics: [HMCharacteristic] = []

    private var manager: HMHomeManager!
    private var accessoryBrowser: HMAccessoryBrowser!
    
    @Published var readingData: Bool = false
       
    @Published var powerState: Bool?
    @Published var hueValue: Int?
    @Published var brightnessValue: Int?

    override init(){
        super.init()
        load()
    }
    
    func load() {
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
    }
    

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("DEBUG: Updated Homes!")
        self.homes = self.manager.homes
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        guard let selectedHome = self.selectedHome else {
            print("ERROR: No selected home!")
            return
        }
        
        selectedHome.addAccessory(accessory) { err in
            guard err == nil else {
                print("ERROR: Can not add accessory!")
                print(err!.localizedDescription)
                return
            }

            selectedHome.assignAccessory(accessory, to: selectedHome.roomForEntireHome()) { err in
                guard err == nil else {
                    print("ERROR: Can not assign accessory \(accessory.name)!")
                    print(err!.localizedDescription)
                    return
                }
                browser.stopSearchingForNewAccessories()
                //self.findAccessories(homeId: selectedHome.uniqueIdentifier)
            }

        }
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        print("DID REMOVE")
        print(accessory)
    }
    
    func addAccessory(to home: HMHome) {
        self.selectedHome = home
        
        self.accessoryBrowser = .init()
        self.accessoryBrowser.delegate = self
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    
    
    func findAccessories(from home: HMHome) {
        self.selectedHome = home
        self.accessories = home.accessories
    }
    
    func findServices(from accessory: HMAccessory) {
        self.services = accessory.services
    }
    
    func findCharacteristics(from service: HMService) {
        self.characteristics = service.characteristics
    }
    
    func readCharacteristicValues(service: HMService){
        readingData = true
        for characteristic in service.characteristics {
           characteristic.readValue(completionHandler: {_ in
               print("DEBUG: reading characteristic value: \(characteristic.localizedDescription)")
               if characteristic.localizedDescription == "Power State" {
                   self.powerState = characteristic.value as? Bool
               }
               if characteristic.localizedDescription == "Hue" {
                   self.hueValue = characteristic.value as? Int
               }
               if characteristic.localizedDescription == "Brightness" {
                   self.brightnessValue = characteristic.value as? Int
               }
               self.readingData = false
           })
           }
       }
    
    func setCharacteristicValue(characteristic: HMCharacteristic?, value: Any) {
        guard let characteristic = characteristic else { return }
        
        characteristic.writeValue(value, completionHandler: {_ in
            self.readCharacteristicValue(characteristic: characteristic)
        })
    }
        
    func readCharacteristicValue(characteristic: HMCharacteristic?){
        guard let characteristic = characteristic else { return }
    
        readingData = true
    
        characteristic.readValue(completionHandler: {_ in
            if characteristic.localizedDescription == "Power State" {
                self.powerState = characteristic.value as? Bool
            }
            if characteristic.localizedDescription == "Hue" {
                self.hueValue = characteristic.value as? Int
            }
            if characteristic.localizedDescription == "Brightness" {
                self.brightnessValue = characteristic.value as? Int
            }
            self.readingData = false
        })
    }
    

}
