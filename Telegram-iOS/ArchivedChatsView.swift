//
//  ArchivedChatsView.swift
//  Telegram-iOS
//
//  Created by Kostya Lee on 01/09/23.
//

import Foundation
import UIKit
import CoreGraphics
import AVFoundation

class ArchivedChatsView: UIView {
    
    // MARK: Active state
    private let titleView = UIView()
    private let subtitleView = UIView()
    private let timeView = UIView()
    

    // MARK: Disabled/enabled state
    private let arrowTraceBackground = UIView()
    private let arrowImageBackground = UIView()
    private let arrowImageView = UIImageView()
    
    private let enabledLabel = UILabel()
    private let disabledLabel = UILabel()
    
    private var up = false
    private var down = false
    
    private var archiveHidden = true
    private var animationEnded = true

    private let circleView = Gradient()
    private let gradientBackground = CAGradientLayer()
    
    private let imageSize = UIDevice().userInterfaceIdiom == .pad ? 30.0 : 20.0
    private let labelHeight = 15.0
    private let padding = 16.0
    private var increasedCircle = false
    
    var didEndDragging: ((_ scrollView: UIScrollView) -> Void)?

    func initViews() {
        [titleView,
        subtitleView,
        timeView].forEach { view in
            view.backgroundColor = .systemBlue
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 3
            view.isHidden = true
        }
        
        circleView.frame = CGRect(
            x: 34,
            y: arrowImageBackground.frame.origin.y + 8,
            width: 0,
            height: 0
        )
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = imageSize/2
        circleView.horizontalMode = true
        circleView.startLocation = 0.2
        circleView.endLocation = 0.8
        circleView.startColor = UIColor(red: 2/255, green: 100/255, blue: 207/255, alpha: 1)
        circleView.endColor = UIColor(red: 160/255, green: 195/255, blue: 245/255, alpha: 1)
        self.addSubview(circleView)
        
        enabledLabel.text = "Release for archive"
        enabledLabel.font = .systemFont(ofSize: UIDevice().userInterfaceIdiom == .pad ? 22 : 18, weight: .medium)
        enabledLabel.textColor = .white
        self.addSubview(enabledLabel)
        enabledLabel.alpha = 0
        
        disabledLabel.text = "Swipe down for archive"
        disabledLabel.font = .systemFont(ofSize: UIDevice().userInterfaceIdiom == .pad ? 22 : 18, weight: .medium)
        disabledLabel.textColor = .white
        self.addSubview(disabledLabel)
        
        enabledLabel.frame = CGRect(
            x: self.frame.width/2 + 120,
            y: self.frame.height - 22 - 10,
            width: UIDevice().userInterfaceIdiom == .pad ? 210 : 180,
            height: 22
        )
        let disabledX = UIDevice().userInterfaceIdiom == .pad ? self.frame.width/2 + 390 : self.frame.width/2 + 130
        disabledLabel.frame = CGRect(
            x: disabledX,
            y: self.frame.height - 22 - 10,
            width: UIDevice().userInterfaceIdiom == .pad ? 260 : 220,
            height: 22
        )
        
        let height = self.frame.size.height - 20
        arrowTraceBackground.backgroundColor = .white.withAlphaComponent(0.7)
        arrowTraceBackground.frame = CGRect(
            x: 34,
            y: 10,
            width: imageSize,
            height: height < 0 ? 0 : height
        )
        arrowTraceBackground.layer.masksToBounds = true
        arrowTraceBackground.layer.cornerRadius = imageSize/2
        self.addSubview(arrowTraceBackground)
        
        arrowImageBackground.frame = CGRect(
            x: 34,
            y: arrowTraceBackground.frame.height - imageSize + 10,
            width: imageSize,
            height: imageSize
        )
        arrowImageBackground.layer.masksToBounds = true
        arrowImageBackground.layer.cornerRadius = imageSize/2
        arrowImageBackground.backgroundColor = .white
        self.addSubview(arrowImageBackground)
        
        arrowImageView.image = UIImage(systemName: "arrow.down")
        arrowImageView.frame = CGRect(
            x: 2,
            y: 2,
            width: imageSize - 4,
            height: imageSize - 4
        )
        arrowImageView.tintColor = .systemGray2
        self.arrowImageBackground.addSubview(arrowImageView)
        
        self.layer.masksToBounds = true
        
        addOffsetObserver()
        setGradientBackground()
        
        self.didEndDragging = { scrollView in
            if self.archiveHidden {
                self.animateAppearArchive()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientBackground.frame = self.bounds
        CATransaction.commit()
        
        let height = self.frame.size.height - 20
        arrowTraceBackground.frame.size.height = height < 0 ? 0 : height
        
        enabledLabel.frame.origin.y = self.frame.size.height - 22 - 10
        disabledLabel.frame.origin.y = self.frame.size.height - 22 - 10
        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        basicLayer.frame = CGRect(x: self.frame.width/2, y: self.frame.height/2, width: 17, height: 17)
//        CATransaction.commit()
        
        arrowImageBackground.frame.origin.y = arrowTraceBackground.frame.height - imageSize + 10

        if !archiveHidden && animationEnded {
            circleView.frame.origin.y = self.frame.size.height - 50 - 15
        } else if !archiveHidden {
            let constantY = UIDevice().userInterfaceIdiom == .pad ? 2.0 : 12.0
            circleView.frame.origin.y = arrowImageBackground.frame.origin.y - circleView.frame.height/2 - constantY
        }
        
        let h = self.frame.size.height - 20
        if h < imageSize {
            arrowImageBackground.frame.size = CGSize(width: h < 0 ? 0 : h, height: h < 0 ? 0 : h)
            arrowImageView.frame = CGRect(
                x: 2,
                y: 2,
                width: h < 0 ? 0 : h - 4,
                height: h < 0 ? 0 : h - 4
            )
            UIView.animate(withDuration: 0.2) {
                self.arrowImageBackground.alpha = 0
                self.arrowImageView.alpha = 0
            }
        } else {
            arrowImageBackground.frame.size = CGSize(width: imageSize, height: imageSize)
            arrowImageView.frame.size = CGSize(width: imageSize - 4, height: imageSize - 4)
            if archiveHidden {
                UIView.animate(withDuration: 0.2) {
                    self.arrowImageBackground.alpha = 1
                    self.arrowImageView.alpha = 1
                }
            }
        }
        
        if archiveHidden {
            self.animationEnded = false
            let size = UIDevice().userInterfaceIdiom == .pad ? 2500.0 : 1000.0
            if up {
                UIView.animate(withDuration: 0.2) {
                    self.circleView.frame = CGRect(
                        x: self.arrowImageBackground.frame.origin.x - size/2 - self.imageSize/2,
                        y: self.arrowImageBackground.frame.origin.y - size/2,
                        width: size,
                        height: size
                    )
                    self.circleView.layer.cornerRadius = self.circleView.frame.height/2
                } completion: { completed in
                    if completed {
                        self.up = false
                        self.animationEnded = true
                    }
                }
            }
            if down {
                UIView.animate(withDuration: 0.2) {
                    self.circleView.frame = CGRect(
                        x: self.arrowImageBackground.frame.origin.x + 20,
                        y: self.arrowImageBackground.frame.origin.y,
                        width: 0,
                        height: 0
                    )
                    self.circleView.layer.cornerRadius = self.circleView.frame.height/2
                } completion: { completed in
                    if completed {
                        self.down = false
                        self.animationEnded = true
                    }
                }
            }
        }
        
        subtitleView.frame = CGRect(
            x: titleView.frame.origin.x,
            y: self.frame.height - labelHeight - 18,
            width: 120,
            height: labelHeight
        )
        titleView.frame = CGRect(
            x: 50 + padding*2,
            y: subtitleView.frame.origin.y - labelHeight - 10,
            width: 80,
            height: labelHeight
        )
        timeView.frame = CGRect(
            x: self.frame.width - padding - 60,
            y: titleView.frame.origin.y,
            width: 60,
            height: labelHeight
        )
    }
    
    private func addOffsetObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self._move(_:)), name: NSNotification.Name(rawValue: "DidScrollToTop"), object: nil)
    }
    
    @objc func _move(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let offset = dict["offset"] as? CGFloat {
                if offset < -rowHeight {
                    if !increasedCircle && archiveHidden {
                        increasedCircle = true
                        animateScaleUp()
                        UIDevice.vibrate()
                        animateArchiveLabel(enabled: true)
                    } else {
                        layoutSubviews()
                    }
                    print("Enabled")
                } else if offset > 0 {
                    if !archiveHidden {
                        hideArchive()
                    }
                    print("Hidden")
                } else {
                    if increasedCircle {
                        increasedCircle = false
                        animateScaleDown()
                        animateArchiveLabel(enabled: false)
                    }
                    print("Disabled")
                }
            }
        }
    }
    
//    func animateScaleUp() {
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.25)
//        let clunk = CAMediaTimingFunction(name: .easeOut)
//        CATransaction.setAnimationTimingFunction(clunk)
//        basicView.layer.transform = CATransform3DMakeScale(20, 20, 1)
//        CATransaction.commit()
//    }

//    func animateScaleDown() {
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.25)
//        let clunk = CAMediaTimingFunction(name: .easeOut)
//        CATransaction.setAnimationTimingFunction(clunk)
//        basicView.layer.transform = CATransform3DMakeScale(1, 1, 1)
//        CATransaction.commit()
//    }
    
    func animateScaleUp() {
        up = true
        layoutSubviews()
        self.arrowImageView.rotate(down: true)
        arrowImageView.tintColor = UIColor(red: 21/255, green: 140/255, blue: 247/255, alpha: 1)
    }
    
    func animateScaleDown() {
        down = true
        layoutSubviews()
        self.arrowImageView.rotate(down: false)
        arrowImageView.tintColor = .systemGray2
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor.systemGray4.cgColor
        let colorBottom = UIColor.systemGray2.cgColor
                    
        gradientBackground.colors = [colorTop, colorBottom]
        gradientBackground.startPoint = CGPoint(x: 1, y: 0)
        gradientBackground.endPoint = CGPoint(x: 0, y: 0)
                
        self.layer.insertSublayer(gradientBackground, at:0)
    }
    
    func animateAppearArchive() {
        self.archiveHidden = false
        
        titleView.isHidden = false
        subtitleView.isHidden = false
        timeView.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.arrowImageView.alpha = 0
            self.arrowImageBackground.alpha = 0
            self.arrowTraceBackground.alpha = 0
            self.enabledLabel.alpha = 0
            self.disabledLabel.alpha = 0
        }
        self.layer.sublayers?.first?.removeFromSuperlayer()
        
        animationEnded = false
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.4,
            options: .curveEaseIn,
            animations: {
                self.circleView.frame = CGRect(
                    x: self.padding,
                    y: self.frame.height - 65.0,
                    width: 50,
                    height: 50
                )
                self.circleView.layer.cornerRadius = self.circleView.frame.height/2
            }) { completed in
                if completed {
                    self.down = false
                    self.animationEnded = true
                }
            }
        layoutSubviews()
    }
    
    func hideArchive() {
        self.archiveHidden = true
        
        titleView.isHidden = true
        subtitleView.isHidden = true
        timeView.isHidden = true
        
        self.arrowImageView.alpha = 1
        self.arrowImageBackground.alpha = 1
        self.arrowTraceBackground.alpha = 1
        self.enabledLabel.alpha = 0
        self.disabledLabel.alpha = 1
        
        self.circleView.frame = CGRect(
            x: self.arrowImageBackground.frame.minX + 8,
            y: self.arrowImageBackground.frame.minY + 8,
            width: 0,
            height: 0
        )
        self.circleView.layer.cornerRadius = self.circleView.frame.height/2
        
        setGradientBackground()
    }
    
    func animateArchiveLabel(enabled: Bool) {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.4,
            options: .curveEaseOut,
            animations: {
                if enabled {
                    self.enabledLabel.frame.origin.x = self.frame.width/2 - 80
                    self.disabledLabel.frame.origin.x = self.frame.width/2 - 170
                } else {
                    self.enabledLabel.frame.origin.x = self.frame.width/2 - 150
                    self.disabledLabel.frame.origin.x = self.frame.width/2 - 85
                }
            })
        if self.archiveHidden {
            UIView.animate(withDuration: 0.25) {
                if enabled {
                    self.enabledLabel.alpha = 1.0
                    self.disabledLabel.alpha = 0.0
                } else {
                    self.enabledLabel.alpha = 0.0
                    self.disabledLabel.alpha = 1.0
                }
            }
        }
    }
}
