//
//  iPhoneSessionDelegate.swift
//  VibMusic
//
//  Created by Gwendal on 12/02/2023.
//

import Foundation
import WatchConnectivity

class iPhoneSessionDelegate: NSObject,  WCSessionDelegate, ObservableObject {
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
    
    func sendAmbiancesToWatchApp(ambiances: [Ambiance]) {
        if session.isReachable {
            let encodedAmbiances = try! JSONEncoder().encode(ambiances)

            session.sendMessageData(encodedAmbiances, replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func sendCurrentAmbianceToWatchApp(_ ambiance: Ambiance?) {
        if session.isReachable {
            let encodedCurrentAmbiance = try! JSONEncoder().encode(ambiance)
         
            session.sendMessageData(encodedCurrentAmbiance, replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            self.currentAmbiance = try JSONDecoder().decode(Ambiance.self, from: messageData)
        } catch {
            print(error)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) { }
    #endif
    
}
