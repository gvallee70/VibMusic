//
//  WatchConnectivityViewModel.swift
//  VibMusic Companion Extension
//
//  Created by Gwendal on 12/02/2023.
//

import Foundation
import WatchConnectivity

class SessionDelegate: NSObject,  WCSessionDelegate{
    var session: WCSession
    init(session: WCSession = .default){
        self.session = session
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
    
