//
//  SSOLocalAuthentication.swift
//  SSOKit
//
//  Created by Abinaya Ravichandran on 2023-12-22.
//

import Foundation
import LocalAuthentication



@objc public enum SSOLocalAuthenticationStatus : Int {
    case allow, cancelled, fallback
}

@objcMembers
public class SSOLocalAuthentication : NSObject {
    
    
    
    @objc public class func showBiometricConfirmation(on viewController: Any, shouldAllowFallback: Bool = true, completion: @escaping (SSOLocalAuthenticationStatus)->()) {
            let context = LAContext()
            guard #available(iOS 9.0, *) else {
                return;
            }
            var policy : LAPolicy = .deviceOwnerAuthentication
            if !shouldAllowFallback {
                #if !os(watchOS)
                context.localizedFallbackTitle = ""
                policy = .deviceOwnerAuthenticationWithBiometrics
                #endif
            }
            var error: NSError?
            if context.canEvaluatePolicy(policy, error: &error) {
                let reason = "Authenticate"
                switchBackgroundInteraction(viewController, enable: false)
                context.evaluatePolicy(policy, localizedReason: reason ) { success, verificaionError in
                    switchBackgroundInteraction(viewController, enable: true)
                    if success {
                        
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async {
                            completion(.allow)
                            
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(.cancelled)
                        }
                    }
                }
            } else {
                if let err = error as? LAError {
                    
                    switch err.code {
                      
                    case .passcodeNotSet:
                        completion(.fallback)
                        
                    case .touchIDLockout, .touchIDNotAvailable, .touchIDNotEnrolled, .notInteractive, .userFallback:
                        completion(.fallback)
                    
                    case .authenticationFailed, .userCancel, .systemCancel, .appCancel, .invalidContext:
                        completion(.cancelled)
                        
                    @unknown default:
                        completion(.fallback)
                    }
                    
                } else {
                    completion(.fallback)
                }
            }
            
            
        }
    
    class func switchBackgroundInteraction(_ viewController: Any, enable: Bool) {
#if targetEnvironment(macCatalyst)
        guard let viewController = viewController as? UIViewController else {
            return
        }
        DispatchQueue.main.async {
            viewController.parent?.view.isUserInteractionEnabled = enable
            viewController.tabBarController?.view.isUserInteractionEnabled  = enable
        }
       
#endif
    }
}
