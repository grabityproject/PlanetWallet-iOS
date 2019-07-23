//
//  BiometricManager.swift
//  PlanetWallet
//
//  Created by grabity on 23/07/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

protocol BiometricManagerDelegate {
    func didAuthenticated(success: Bool, key: String?, error: Error?)
}

class BiometricManager {
    let context = LAContext()
    var loginReason = "Logging in with Biometric ID"
    
    var delegate: BiometricManagerDelegate!
    
    init(_ delegate: BiometricManagerDelegate) {
        self.delegate = delegate
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .none
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser() {
        guard canEvaluatePolicy() else {
            delegate.didAuthenticated(success: false, key: nil, error: LAError.biometryNotAvailable as? Error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    let key = ""
                    self.delegate.didAuthenticated(success: true, key: key, error: nil)
                }
            } else {
                //                let message: String
                //
                //                switch evaluateError {
                //                case LAError.authenticationFailed?:
                //                    message = "There was a problem verifying your identity."
                //                case LAError.userCancel?:
                //                    message = "You pressed cancel."
                //                case LAError.userFallback?:
                //                    message = "You pressed password."
                //                case LAError.biometryNotAvailable?:
                //                    message = "Face ID/Touch ID is not available."
                //                case LAError.biometryNotEnrolled?:
                //                    message = "Face ID/Touch ID is not set up."
                //                case LAError.biometryLockout?:
                //                    message = "Face ID/Touch ID is locked."
                //                default:
                //                    message = "Face ID/Touch ID may not be configured"
                //                }
                self.delegate.didAuthenticated(success: false, key: nil, error: evaluateError)
            }
        }
    }
}

