//
//  LoginViewController.swift
//  synChroma
//
//  Created by Wilson Ding on 10/2/16.
//  Copyright © 2016 Wilson Ding. All rights reserved.
//

import UIKit
import SwiftVideoBackground

class LoginViewController: UIViewController {
    
    @IBOutlet weak var backgroundVideo: BackgroundVideo!
    
    let backgroundVideoAlpha: CGFloat = 0.5
    let backgroundVideoTitle = "Background"
    let parallaxMotionEffect = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundVideo.createBackgroundVideo(name: backgroundVideoTitle, type: "mp4", alpha: backgroundVideoAlpha)
        
        addParallax(motion: parallaxMotionEffect)
    }
    
    func addParallax(motion: Int) {
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = parallaxMotionEffect * -1
        verticalMotionEffect.maximumRelativeValue = parallaxMotionEffect
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = parallaxMotionEffect * -1
        horizontalMotionEffect.maximumRelativeValue = parallaxMotionEffect
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        view.addMotionEffect(group)
    }
    
}
