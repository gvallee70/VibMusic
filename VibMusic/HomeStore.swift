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
    
    func addAccessory(to homeId: UUID) {
        self.selectedHome = homes.first(where: {$0.uniqueIdentifier == homeId})
        
        self.accessoryBrowser = .init()
        self.accessoryBrowser.delegate = self
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    
    
    func findAccessories(homeId: UUID) {
        guard let home = homes.first(where: {$0.uniqueIdentifier == homeId}) else {
                print("ERROR: No Accessory not found!")
                return
            }
        self.selectedHome = home
        accessories = home.accessories
        }
    
    func findServices(accessoryId: UUID, homeId: UUID){
            guard let accessoryServices = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.services else {
                print("ERROR: No Services found!")
                return
            }
            services = accessoryServices
        }
    
    func findCharacteristics(serviceId: UUID, accessoryId: UUID, homeId: UUID){
           guard let serviceCharacteristics = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories.first(where: {$0.uniqueIdentifier == accessoryId})?.services.first(where: {$0.uniqueIdentifier == serviceId})?.characteristics else {
               print("ERROR: No Services found!")
               return
           }
           characteristics = serviceCharacteristics
       }
    
    func readCharacteristicValues(serviceId: UUID){
           guard let characteristicsToRead = services.first(where: {$0.uniqueIdentifier == serviceId})?.characteristics else {
               print("ERROR: Characteristic not found!")
               return
           }
          readingData = true
           for characteristic in characteristicsToRead {
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
    
    func setCharacteristicValue(characteristicID: UUID?, value: Any) {
            guard let characteristicToWrite = characteristics.first(where: {$0.uniqueIdentifier == characteristicID}) else {
                print("ERROR: Characteristic not found!")
                return
            }
            characteristicToWrite.writeValue(value, completionHandler: {_ in
                self.readCharacteristicValue(characteristicID: characteristicToWrite.uniqueIdentifier)
            })
        }
        
    func readCharacteristicValue(characteristicID: UUID?){
        guard let characteristicToRead = characteristics.first(where: {$0.uniqueIdentifier == characteristicID}) else {
            print("ERROR: Characteristic not found!")
            return
        }
        readingData = true
        characteristicToRead.readValue(completionHandler: {_ in
            if characteristicToRead.localizedDescription == "Power State" {
                self.powerState = characteristicToRead.value as? Bool
            }
            if characteristicToRead.localizedDescription == "Hue" {
                self.hueValue = characteristicToRead.value as? Int
            }
            if characteristicToRead.localizedDescription == "Brightness" {
                self.brightnessValue = characteristicToRead.value as? Int
            }
            self.readingData = false
        })
    }
    

}
