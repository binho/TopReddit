//
//  InternetManager.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/19/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import UIKit
import SystemConfiguration

class InternetManager {
    
    static func isConnected() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        let connected = (isReachable && !needsConnection)
        print("Connection status: \(connected ? "online" : "offline")")
        
        return connected
    }
    
    static func showInternetRequiredMessageInViewController(_ viewController: UIViewController?) {
        let alert = UIAlertController(title: "No Internet", message: "Please check your internet connection status and try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let navigationController = viewController?.navigationController {
            navigationController.present(alert, animated: true)
        } else {
            viewController?.present(alert, animated: true)
        }
    }
    
}
