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
    
    var myCurrentTranscribed : String = ""
    var lastUniqueValue : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
    }
    
    func setupCamera() {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .back)
        videoCamera!.outputImageOrientation = .portrait
        
        do {
            try videoCamera!.inputCamera.lockForConfiguration()
            
            videoCamera!.inputCamera.focusMode = .locked
            videoCamera!.inputCamera.exposureMode = .locked
            
            videoCamera!.inputCamera.unlockForConfiguration()
        }
        catch {
            // just ignore
        }
        
        let cropFilter = GPUImageCropFilter()
        cropFilter.cropRegion = CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3)
        
        let medianFilter = GPUImageMedianFilter()
        
        cropFilter.addTarget(medianFilter)
        
        let averageColorFilter = GPUImageAverageColor()
        
        medianFilter.addTarget(averageColorFilter)
        
        averageColorFilter.colorAverageProcessingFinishedBlock = {(redComponent, greenComponent, blueComponent, alphaComponent, frameTime) in

            print("Average color: \(redComponent*255), \(greenComponent*255), \(blueComponent*255), \(alphaComponent)")
            
            
            self.convertRGB(red: Float(redComponent*255), green: Float(greenComponent*255), blue: Float(blueComponent*255))
            
            print(self.myCurrentTranscribed + "\n")
            
            let array = self.myCurrentTranscribed.components(separatedBy: "545")
            
            if array.count == 3 {
                print(self.convertBaseThreeToText(str: self.myCurrentTranscribed))
                self.myCurrentTranscribed = ""
            }
        }
        
        videoCamera?.addTarget(averageColorFilter)
        averageColorFilter.addTarget(self.view as! GPUImageView)
        videoCamera?.startCapture()
    }

    func isUpdated(red: Float, green: Float, blue: Float) -> Bool {
        //        print(red-lastUniqueValue[0]);
        if (blue < 100.0 && green < 100.0 && red < 100.0 && lastUniqueValue != "black") {
            return true
        } else if (blue > 200.00 && green > 200.00 && red > 200.00 && lastUniqueValue != "white") {
            return true
        } else if (red > green && red > blue && lastUniqueValue != "red") {
            return true
        } else if (green > red && green > blue && lastUniqueValue != "green") {
            return true
        } else if (blue > green && blue > red && lastUniqueValue != "blue") {
            return true
        }
        return false;
    }
    
    func isNew(red: Float, green: Float, blue: Float) -> Bool {
        var tempString : String = "";
        if (blue < 100.0 && green < 100.0 && red < 100.0) {
            tempString = "black"
        } else if (blue > 200.00 && green > 200.00 && red > 200.00) {
            tempString = "white"
        } else if (red > green && red > blue) {
            tempString = "red"
        } else if (green > red && green > blue) {
            tempString = "green"
        } else if (blue > green && blue > red) {
            tempString = "blue"
        }
        if (lastUniqueValue == tempString) {
            return false;
        }
        return true;
    }
    
    func convertRGB(red: Float, green: Float, blue: Float) {
        let tempUpdated = isNew(red: red, green: green, blue: blue)
        if (tempUpdated) {
            if (blue < 125.0 && green < 125.0 && red < 125.0) {
                myCurrentTranscribed = myCurrentTranscribed + "5"
                lastUniqueValue = "black"
            } else if (blue > 175.00 && green > 175.00 && red > 175.00) {
                myCurrentTranscribed = myCurrentTranscribed + "4"
                lastUniqueValue = "white"
            } else if (red > green && red > blue) {
                myCurrentTranscribed = myCurrentTranscribed + "0"
                lastUniqueValue = "red"
            } else if (green > red && green > blue) {
                myCurrentTranscribed = myCurrentTranscribed + "1"
                lastUniqueValue = "green"
            } else if (blue > green && blue > red) {
                myCurrentTranscribed = myCurrentTranscribed + "2"
                lastUniqueValue = "blue"
            }
        }
    }
    
    func convertBaseThreeToText(str: String) -> String {
        let myArray = str.components(separatedBy: "5");
        print(myArray);
        var endString : String = "";
        for i in (0...myArray.count-1) {
            let number = Int(strtoul(myArray[i], nil, 3))
            let u = UnicodeScalar(number)
            endString = endString + String(u!);
        }
        
        return (endString)
    }

}
