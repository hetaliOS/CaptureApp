//
//  RechabilityManager.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
import Reachability

class RechabilityManager: NSObject {
    
    private let reachability = Reachability()!
    private var isFirstTimeSetupDone:Bool = false
    private var callCounter:Int = 0
    
    // MARK: - SHARED MANAGER
    static let shared: RechabilityManager = RechabilityManager()
    
    
    //MARK:- ALL NETWORK CHECK
    func isInternetAvailableForAllNetworks() -> Bool {
        if(!self.isFirstTimeSetupDone){
            self.isFirstTimeSetupDone = true
            doSetupReachability()
        }
        return reachability.connection != .none || reachability.connection == .wifi || reachability.connection == .cellular
    }
    
    
    //MARK:- SETUP
    private func doSetupReachability() {
        
        reachability.whenReachable = { [weak self]reachability in
            DispatchQueue.main.async {
                self?.postIntenetReachabilityDidChangeNotification(isInternetAvailable: true)
            }
        }
        reachability.whenUnreachable = { [weak self]reachability in
            DispatchQueue.main.async {
                self?.postIntenetReachabilityDidChangeNotification(isInternetAvailable: false)
            }
        }
        do{
            try reachability.startNotifier()
        }catch{
        }
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: nil)
    }
    
    
    
    //MARK:- NOTIFICATION
    private func postIntenetReachabilityDidChangeNotification(isInternetAvailable isAvailable:Bool){
        DispatchQueue.main.async {
            NotificationCenter.default.post(NSNotification(name: Notification.Name.reachabilityChanged, object: nil) as Notification)
            
        }
        
    }
}
