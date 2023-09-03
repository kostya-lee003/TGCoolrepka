//
//  Extensions.swift
//  Telegram-iOS
//
//  Created by Kostya Lee on 03/09/23.
//

import Foundation
import UIKit

extension UIDevice {
    static func vibrate() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
}

extension UIView {
    
    func rotate(down: Bool) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        if down {
            rotation.fromValue = NSNumber(value: 0)
            rotation.toValue = NSNumber(value: Double.pi)
        } else {
            rotation.fromValue = NSNumber(value: Double.pi)
            rotation.toValue = NSNumber(value: 0)
        }
        rotation.duration = 0.15
        rotation.isCumulative = true
        rotation.repeatCount = 1
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
