//
//  LMBUIWindowExt.swift
//  faceitforme
//
//  Created by Gökhan Mandacı on 20/03/2017.
//  Copyright © 2017 gokhanmandaci. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    override open func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            captureScreen()
        }
    }
}
