//
//  OSType.swift
//  ZohoTower
//
//  Created by Nagarajan S on 23/11/21.
//

import Foundation
import UIKit


struct Device {

    // MARK: - Singletons
    static let current = UIDevice.current

    static let OSVersion = Float(UIDevice.current.systemVersion) ?? 14.0

    static let deviceHeight  = UIScreen.main.bounds.height
    
    

    // MARK: - Device Idiom Checks

    fileprivate  static var DEBUG_OR_RELEASE: String {
        #if DEBUG
            return "Debug"
        #else
            return "Release"
        #endif
    }

    static var SIMULATOR_OR_DEVICE: String {
        #if targetEnvironment(simulator)
            return "Simulator"
        #else
            return "Device"
        #endif
    }

    static var model: String {
        return current.model
    }

    public static let isIphone = UIDevice.current.userInterfaceIdiom == .phone

    public static let isIpad : Bool = {
        
        if #available(iOS 14.0, *) {
            return  (UIDevice.current.userInterfaceIdiom == .pad  || UIDevice.current.userInterfaceIdiom == .mac)
        } else {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
    }()

    public static let isMac: Bool  = {
    #if targetEnvironment(macCatalyst)
        return true
    #else
        return false
    #endif
    }()
    
    public static let isIOS14AndAbove: Bool  = {
        if #available(iOS 14, *){
            return true
        } else {
            return false
        }
    }()
    

    static func isDebug() -> Bool {
        return DEBUG_OR_RELEASE == "Debug"
    }

    static func isRelease() -> Bool {
        return DEBUG_OR_RELEASE == "Release"
    }

    static func isSimulator() -> Bool {
        return SIMULATOR_OR_DEVICE == "Simulator"
    }

    static func isDevice() -> Bool {
        return SIMULATOR_OR_DEVICE == "Device"
    }
    

    // MARK: - Device Version Checks
    enum Versions: Float {
        case ten = 10.0
        case eleven = 11.0
        case tweleve = 12.0
        case thirteen = 13.0
        case fourteen = 14.0
        case fifteen = 15.0
        case sixteen = 16.0
        case seventeen = 17.0
    }

    static func isVersion(_ version: Versions) -> Bool {
        return OSVersion >= version.rawValue && OSVersion < (version.rawValue + 1.0)
    }

    static func isVersionOrLater(_ version: Versions) -> Bool {
        return OSVersion >= version.rawValue
    }

    static func isVersionOrEarlier(_ version: Versions) -> Bool {
        return OSVersion < (version.rawValue + 1.0)
    }


    // MARK: iOS 5 Checks
    static func IS_OS_10() -> Bool {
        return isVersion(.ten)
    }

    static func IS_OS_10_OR_LATER() -> Bool {
        return isVersionOrLater(.ten)
    }

    static func IS_OS_10_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.ten)
    }

    // MARK: iOS 11 Checks
    static func IS_OS_11() -> Bool {
        return isVersion(.eleven)
    }

    static func IS_OS_11_OR_LATER() -> Bool {
        return isVersionOrLater(.eleven)
    }

    static func IS_OS_11_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.eleven)
    }

    // MARK: iOS 12 Checks
    static func IS_OS_12() -> Bool {
        return isVersion(.tweleve)
    }

    static func IS_OS_12_OR_LATER() -> Bool {
        return isVersionOrLater(.tweleve)
    }

    static func IS_OS_12_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.tweleve)
    }

    // MARK: iOS 13 Checks
    static func IS_OS_13() -> Bool {
        return isVersion(.thirteen)
    }

    static func IS_OS_13_OR_LATER() -> Bool {
        return isVersionOrLater(.thirteen)
    }

    static func IS_OS_13_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.thirteen)
    }

    // MARK: iOS 14 Checks
    static func IS_OS_14() -> Bool {
        return isVersion(.fourteen)
    }

    static func IS_OS_14_OR_LATER() -> Bool {
        return isVersionOrLater(.fourteen)
    }

    static func IS_OS_14_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.fourteen)
    }
    
    // MARK: iOS 15 Checks
    static func IS_OS_15() -> Bool {
        return isVersion(.fifteen)
    }

    static func IS_OS_15_OR_LATER() -> Bool {
        return isVersionOrLater(.fifteen)
    }

    static func IS_OS_15_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.fifteen)
    }

   

    // MARK: - International Checks
    static var CURRENT_REGION: String {
        return Locale.current.region?.identifier ?? "en"
    }
}
