//
//  ViewController.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/14/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let isoMessage5 = ISOMessage(isoMessage: "0000001100000000000010000000000000000000000000000000000000000000")
        isoMessage5?.useCustomConfigurationFiles(customConfigurationFileName: "customisoconfig", customMTIFileName: "customisoMTI")
        
//        isoMessage5?.setMTI(mti: "0127")
        isoMessage5?.addDataElement(elementName: "DE07", value: "501")
        isoMessage5?.addDataElement(elementName: "DE08", value: "1")
        isoMessage5?.addDataElement(elementName: "DE021", value: "1")
        
        
        
        print("Hex bitmap 1: \(isoMessage5!.getHexBitmap1()!)")
        print("Bin bitmap 1: \(isoMessage5!.getBinaryBitmap1()!)")
        print("Hex bitmap 2: \(isoMessage5!.getHexBitmap2())")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func goToWebsite(sender: AnyObject) {
        if let jorgeURL = URL(string: "http://jorgetapia.net") {
            UIApplication.shared.openURL(jorgeURL)
        }
    }
    
    @IBAction func goToRepoWebsite(sender: AnyObject) {
        if let repoURL = URL(string: "https://github.com/georgetapia/Swift-ISO8583") {
            UIApplication.shared.openURL(repoURL)
        }
    }
}

