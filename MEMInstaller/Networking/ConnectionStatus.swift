//
//  ConnectionStatus.swift
//  WidgetExtension
//
//  Created by Nagarajan S on 07/07/20.
//  Copyright © 2020 Zoho Corporation. All rights reserved.
//

import Foundation
import Network

final public class ConnectionStatus {
    public static let shared = ConnectionStatus()
    
    private let monitor = NWPathMonitor()
    var isNetworkAvailable = true
    
    public var connectionStatusUpdated : ((Bool) -> Void)?
    
    private init() { startMonitoring() }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = {[weak self] path in
            if path.status == .satisfied {
                self?.connectionStatusUpdated?(true)
                self?.isNetworkAvailable = true
                ConnectionStatus.shared.isNetworkAvailable = true
            } else {
                self?.connectionStatusUpdated?(false)
                self?.isNetworkAvailable = false
                ConnectionStatus.shared.isNetworkAvailable = false
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    
    func currentNetworkInterfaceType() -> String {
        guard let networkInterface = monitor.currentPath.availableInterfaces.first else {
            return "Unknown"
        }
        
        switch networkInterface.type {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .loopback:
            return "Loopback"
        case .wiredEthernet:
            return "Wired Ethernet"
        default:
            return "Unknown"
        }
      
    }
    
    deinit {
        monitor.cancel()
    }
}
