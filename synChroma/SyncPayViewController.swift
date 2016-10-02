//
//  SyncPayViewController.swift
//  synChroma
//
//  Created by Wilson Ding on 10/2/16.
//  Copyright © 2016 Wilson Ding. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SyncPayViewController: UIViewController {
    
    var ref: FIRDatabaseReference!

    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var myview: UIView!
    
    let v = "54510212510202"
    var currentInt = 0
    var cost : Double = 0.0
    
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func syncPayButtonPressed(_ sender: AnyObject) {
        cost = Double(textField.text!)!
        myview.isHidden = false;
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(SyncRouteViewController.color), userInfo: nil, repeats: true)
        var closerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(SyncRouteViewController.stopTimer), userInfo: nil, repeats: false)
    }

    func stopTimer() {
        timer.invalidate();
        myview.isHidden = true;
        sendToFB()
        recieveFromFB()
    }
    
    func color(){
        if (currentInt >= v.characters.count) {
            currentInt = 0;
        } else {
            let temp = v[v.index(v.startIndex, offsetBy: currentInt)];
            
            if (currentInt > v.characters.count) {
                timer.invalidate();
            }
            
            currentInt+=1;
            if (temp == "5") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
            } else if (temp == "4") {
                myview.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            }
            else if (temp == "2") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 255.0/255, alpha: 1.0)
            }
            else if (temp == "1") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 255.0/255, blue: 0.0/255, alpha: 1.0)
            }
            else if (temp == "0") {
                myview.backgroundColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
            }
            print("howdy")
        }
    }
    
    func sendToFB() {
        let post = ["data": "test"]
        let childUpdates = ["posts/": cost]
        ref.updateChildValues(childUpdates)
    }

    func recieveFromFB() {
        var refHandle = ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as! [String : AnyObject]
            print (postDict["posts"]!["data"]!!)
        })
    }
}
