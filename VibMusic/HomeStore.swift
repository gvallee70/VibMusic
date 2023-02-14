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
    @Published var currentStoredHome: HMHome?

    @Published var rooms: [HMRoom] = []
    @Published var selectedRoom: HMRoom?
    @Published var currentStoredRooms: [HMRoom] = []
    
    @Published var roomAccessories: [HMAccessory] = []
    @Published var accessories: [HMAccessory] = []
    @Published var discoveredAccessories: [HMAccessory] = []
    @Published var accessoryToAdd: HMAccessory?
    @Published var currentStoredAccessories: [HMAccessory] = []
    
    @Published var lightbulbsServices: [HMService] = []
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
    
    
    func addHome(_ name: String) {
        self.manager.addHome(withName: name) { home, error in
            if let error = error {
                print("Can't add home : \(error.localizedDescription)")
            } else {
                self.homes = self.manager.homes
            }
        }
    }
    
    func addRoom(_ name: String, to home: HMHome) {
        self.selectedHome = home
        self.selectedHome?.addRoom(withName: name) { room, error in
            if let error = error {
                print("Can't add room : \(error.localizedDescription)")
            } else {
                self.rooms.append(room!)
                print("Room \(room!.name) added to \(self.selectedHome!.name)")
            }
        }
    }
    
    func addAccessory(_ accessory: HMAccessory, to home: HMHome, in room: HMRoom?) {
        Task {
            self.selectedHome = home
            
            if let room = room {
                self.selectedRoom = room
            }
            
            self.accessoryToAdd = accessory
        }
        
        self.discoveredAccessories.removeAll()
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    
    
    func deleteRoom(_ room: HMRoom, from home: HMHome) {
        home.removeRoom(room) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.getRooms(from: home)
            }
        }
    }
    
    func deleteHome(_ home: HMHome) {
        self.manager.removeHome(home) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.homes = self.manager.homes
            }
        }
    }
    
    func deleteAccessory(_ accessory: HMAccessory, home: HMHome, room: HMRoom) {
        home.removeAccessory(accessory) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.getAccessories(from: room)
            }
        }
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
    
    
    func getRoomsWithLightbulb(from home: HMHome) {
        self.rooms = home.rooms.filter({
            $0.accessories.contains(where: {
                $0.category.categoryType == HMAccessoryCategoryTypeLightbulb
            })
        })
    }
    
    func getRooms(from home: HMHome) {
        self.rooms = home.rooms
    }
    
    func getAccessories(from room: HMRoom) {
        self.roomAccessories.removeAll()
        
        self.roomAccessories = room.accessories.filter({
            $0.category.categoryType == HMAccessoryCategoryTypeLightbulb
        })
    }
    
    func getAllLightbulbsServicesForAllRooms(from home: HMHome) {
        self.lightbulbsServices.removeAll()

        home.rooms.forEach { room in
            room.accessories.forEach { accessory in
                if let lightbulbService = accessory.services.first(where: {$0.serviceType == HMServiceTypeLightbulb}) {
                    self.lightbulbsServices.append(lightbulbService)
                }
            }
        }
    }
    
    func getAllLightbulbsServices(from rooms: [HMRoom]) {
        self.lightbulbsServices.removeAll()
        
        rooms.forEach { room in
            room.accessories.forEach { accessory in
                if let lightbulbService = accessory.services.first(where: {$0.serviceType == HMServiceTypeLightbulb}) {
                    self.lightbulbsServices.append(lightbulbService)
                }
            }
        }
    }
    
    func getAllLightbulbsServices(from accessories: [HMAccessory]) {
        self.lightbulbsServices.removeAll()
        
        accessories.forEach { accessory in
            if let lightbulbService = accessory.services.first(where: {$0.serviceType == HMServiceTypeLightbulb}) {
                self.lightbulbsServices.append(lightbulbService)
            }
        }
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
    
    
    
    func setCurrentHome(_ home: HMHome) {
        self.resetCurrentRoomsFromStorage()
        self.resetCurrentAccessoriesFromStorage()
        self.storeCurrentHome(home)
        self.getCurrentHome()
    }
    
    func addCurrentRoom(_ room: HMRoom, home: HMHome) {
        self.storeCurrentRoom(room)
        room.accessories.forEach { accessory in
            if accessory.category.categoryType == HMAccessoryCategoryTypeLightbulb {
                print(accessory.name)
                self.storeCurrentAccessory(accessory)
            }
        }
        self.getCurrentRooms(from: home)
    }
    
    func removeFromCurrentRooms(_ room: HMRoom, home: HMHome) {
        self.removeCurrentRoomFromStorage(room)
        self.removeCurrentAccessoriesOfaRoomFromStorage(from: room)
        self.getCurrentRooms(from: home)
    }
    
    func addCurrentAccessory(_ accessory: HMAccessory, home: HMHome) {
        self.storeCurrentAccessory(accessory)
        self.getCurrentAccessories()
    }
    
    func removeFromCurrentAccessories(_ accessory: HMAccessory, home: HMHome) {
        self.removeCurrentAccessoryFromStorage(accessory)
        self.getCurrentAccessories()
    }
    

    
    //---------------- STORAGE ------------------
    
    private func storeCurrentHome(_ home: HMHome) {
        UserDefaults.standard.set(home.uniqueIdentifier.uuidString, forKey: "currentHomeUUID")
    }
    
    func getCurrentHome() {
        guard let currentHomeUUIDstring = UserDefaults.standard.string(forKey: "currentHomeUUID") else { return
        }
        self.homes = self.manager.homes
        self.currentStoredHome = self.homes.first(where: { $0.uniqueIdentifier == UUID(uuidString: currentHomeUUIDstring) })
    }
    
    private func storeCurrentRoom(_ room: HMRoom) {
        self.currentStoredRooms.append(room)
        
        UserDefaults.standard.set(self.currentStoredRooms.map({ $0.uniqueIdentifier.uuidString }), forKey: "currentRoomsUUIDstring")
    }
    
    private func removeCurrentRoomFromStorage(_ room: HMRoom) {
        self.currentStoredRooms.removeAll(where: { $0.uniqueIdentifier == room.uniqueIdentifier })
        
        UserDefaults.standard.set(self.currentStoredRooms.map({ $0.uniqueIdentifier.uuidString }), forKey: "currentRoomsUUIDstring")
    }
    
    private func resetCurrentRoomsFromStorage() {
        self.currentStoredRooms.removeAll()
        UserDefaults.standard.removeObject(forKey: "currentRoomsUUIDstring")
    }
    
    func getCurrentRooms(from home: HMHome) {
        guard let currentRoomsUUIDstring = UserDefaults.standard.stringArray(forKey: "currentRoomsUUIDstring") else { return
        }
        self.rooms = home.rooms
        self.accessories = home.accessories
        self.currentStoredRooms = self.rooms.filter({
            currentRoomsUUIDstring.contains($0.uniqueIdentifier.uuidString)
        })
    }
    
    private func storeCurrentAccessory(_ accessory: HMAccessory) {
        if !currentStoredAccessories.contains(accessory) {
            self.currentStoredAccessories.append(accessory)
        }
        
        UserDefaults.standard.set(self.currentStoredAccessories.map({ $0.uniqueIdentifier.uuidString }), forKey: "currentAccessoriesUUIDstring")
    }
    
    private func removeCurrentAccessoryFromStorage(_ accessory: HMAccessory) {
        self.currentStoredAccessories.removeAll(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier })
        
        UserDefaults.standard.set(self.currentStoredAccessories.map({ $0.uniqueIdentifier.uuidString }), forKey: "currentAccessoriesUUIDstring")
    }
    
    private func removeCurrentAccessoriesOfaRoomFromStorage(from room: HMRoom) {
        self.currentStoredAccessories.removeAll(where: { $0.room == room })
        
        UserDefaults.standard.set(self.currentStoredAccessories.map({ $0.uniqueIdentifier.uuidString }), forKey: "currentAccessoriesUUIDstring")
    }
    
    private func resetCurrentAccessoriesFromStorage() {
        self.currentStoredAccessories.removeAll()
        UserDefaults.standard.removeObject(forKey: "currentAccessoriesUUIDstring")
    }
    
    func getCurrentAccessories() {
        guard let currentAccessoriesUUIDstring = UserDefaults.standard.stringArray(forKey: "currentAccessoriesUUIDstring") else { return
        }
        
        self.currentStoredAccessories = self.accessories.filter({
            currentAccessoriesUUIDstring.contains($0.uniqueIdentifier.uuidString)
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
                
                selectedHome.assignAccessory(accessory, to: self.selectedRoom ?? selectedHome.roomForEntireHome()) { err in
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
