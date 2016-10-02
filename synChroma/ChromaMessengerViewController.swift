//
//  ChromaMessengerViewController.swift
//  synChroma
//
//  Created by Wilson Ding on 10/1/16.
//  Copyright © 2016 Wilson Ding. All rights reserved.
//

import UIKit
import GPUImage

class ChromaMessengerViewController: UIViewController {
    
    var videoCamera: GPUImageVideoCamera?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
    }
    
    func setupCamera() {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .back)
        videoCamera!.outputImageOrientation = .portrait
        
        let cropFilter = GPUImageCropFilter()
        cropFilter.cropRegion = CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3)
        
        let medianFilter = GPUImageMedianFilter()
        
        cropFilter.addTarget(medianFilter)
        
        let averageColorFilter = GPUImageAverageColor()
        
        medianFilter.addTarget(averageColorFilter)
        
        averageColorFilter.colorAverageProcessingFinishedBlock = {(redComponent, greenComponent, blueComponent, alphaComponent, frameTime) in

            print("Average color: \(redComponent*255), \(greenComponent*255), \(blueComponent*255), \(alphaComponent)")
        }
        
        videoCamera?.addTarget(averageColorFilter)
        averageColorFilter.addTarget(self.view as! GPUImageView)
        videoCamera?.startCapture()
    }

}
