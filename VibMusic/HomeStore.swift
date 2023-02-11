//
//  HomeStore.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import HomeKit
import Combine

class HomeStore: NSObject, ObservableObject {
    
    
    @Published var homes: [HMHome] = []
    @Published var selectedHome: HMHome?

    @Published var accessories: [HMAccessory] = []
    @Published var discoveredAccessories: [HMAccessory] = []
    @Published var accessoryToAdd: HMAccessory?
    
    @Published var services: [HMService] = []
    @Published var characteristics: [HMCharacteristic] = []

    private var manager: HMHomeManager!
    private var accessoryBrowser: HMAccessoryBrowser!
    
    @Published var readingData: Bool = false
       
    @Published var powerState: Bool = false
    @Published var hueValue: Int = 0
    @Published var saturationValue: Int = 0
    @Published var brightnessValue: Int = 0

    override init(){
        super.init()
        
        self.initHomeManager()
    }
    
    func initHomeManager() {
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
    }
    
    
    func addAccessory(_ accessory: HMAccessory, to home: HMHome) {
        self.selectedHome = home
        self.accessoryToAdd = accessory
        
        self.discoveredAccessories.removeAll()
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    
    func findNewAccessories() {
        self.discoveredAccessories.removeAll()
        
        self.accessoryBrowser = .init()
        self.accessoryBrowser.delegate = self
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    
    func stopFindNewAccessories() {
        self.accessoryBrowser.stopSearchingForNewAccessories()
    }
    
    
    func getAccessories(from home: HMHome) {
        self.accessories = home.accessories.filter({
            $0.category.categoryType == HMAccessoryCategoryTypeLightbulb
        })
    }
    
    func getServices(from accessory: HMAccessory) {
        self.services = accessory.services.filter({
            $0.serviceType == HMServiceTypeLightbulb
        })
    }
    
    func getCharacteristics(from service: HMService) {
        self.characteristics = service.characteristics
    }
    
    func setCharacteristicValue(characteristic: HMCharacteristic?, value: Any) {
        guard let characteristic = characteristic else { return }
        
        characteristic.writeValue(value, completionHandler: {_ in
            self.readCharacteristicValue(characteristic: characteristic)
        })
    }
       
    func readCharacteristicValues() {
        readingData = true
        
        self.characteristics.forEach { characteristic in
            self.readCharacteristicValue(characteristic: characteristic)
        }
    }
    
    func readCharacteristicValue(characteristic: HMCharacteristic?){
        guard let characteristic = characteristic else { return }
    
        readingData = true
    
        characteristic.readValue(completionHandler: {_ in
            print("DEBUG: reading characteristic value: \(characteristic.localizedDescription)")
            if characteristic.characteristicType == HMCharacteristicTypePowerState {
                self.powerState = characteristic.value as? Bool ?? false
            }
            if characteristic.characteristicType == HMCharacteristicTypeHue {
                self.hueValue = characteristic.value as? Int ?? 0
            }
            if characteristic.characteristicType == HMCharacteristicTypeSaturation {
                self.saturationValue = characteristic.value as? Int ?? 0
            }
            if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                self.brightnessValue = characteristic.value as? Int ?? 0
            }
            self.readingData = false
        })
    }
    

}


extension HomeStore: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("DEBUG: Updated Homes!")
        self.homes = self.manager.homes
    }
}

extension HomeStore: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        
        if accessory.category.categoryType == HMAccessoryCategoryTypeLightbulb {
            self.discoveredAccessories.append(accessory)
        }
    
        if self.accessoryToAdd?.uniqueIdentifier == accessory.uniqueIdentifier {
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
                    self.accessories.append(accessory)
                    self.discoveredAccessories.removeAll(where: {$0.uniqueIdentifier == accessory.uniqueIdentifier})
                    browser.stopSearchingForNewAccessories()
                }
            }
        }
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        print("DID REMOVE")
        print(accessory)
    }
}
