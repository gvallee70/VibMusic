//
//  WatchSessionDelegate.swift
//  VibMusic Companion Watch App
//
//  Created by Gwendal on 12/02/2023.
//

import Foundation
import WatchConnectivity

class WatchSessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @Published var ambiances = [Ambiance]()
    @Published var currentAmbiance: Ambiance?
    
    private var session: WCSession = .default
        
    init(session: WCSession = .default) {
        self.session = session

        super.init()

        self.session.delegate = self
        self.connect()
    }
    
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        session.activate()
    }

    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            self.ambiances = try JSONDecoder().decode([Ambiance].self, from: messageData)
        } catch {
            print(error)
        }
        
        do {
            self.currentAmbiance = try JSONDecoder().decode(Ambiance.self, from: messageData)
        } catch {
            print(error)
        }
    }
    
   
    func sendCurrentAmbianceToIOSApp(_ ambiance: Ambiance?) {
        if session.isReachable {
            let encodedCurrentAmbiance = try! JSONEncoder().encode(ambiance)
            
            session.sendMessageData(encodedCurrentAmbiance, replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
        }
    }
 
}
