//
//  HomeStore.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import Foundation
import HomeKit
import Combine

class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    
    @Published var homes: [HMHome] = []
    @Published var accessories: [HMAccessory] = []
    @Published var services: [HMService] = []
    @Published var characteristics: [HMCharacteristic] = []
    
    private var manager: HMHomeManager!

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
    
    func findAccessories(homeId: UUID) {
            guard let devices = homes.first(where: {$0.uniqueIdentifier == homeId})?.accessories else {
                print("ERROR: No Accessory not found!")
                return
            }
            accessories = devices
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
}
