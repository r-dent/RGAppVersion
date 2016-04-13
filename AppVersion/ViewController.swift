//
//  ViewController.swift
//  AppVersion
//
//  Created by Roman Gille on 13.04.16.
//  Copyright © 2016 Roman Gille. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var currentVersionLabel: UILabel!
    @IBOutlet weak var lastVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentVersionLabel.text = "Current App Version: \(RGAppVersion.currentVersion().combinedVersion)"
        
        if let lastVersion = RGAppVersion.lastVersion() {
            lastVersionLabel.text = "Last App Version: \(lastVersion.combinedVersion)"
        }
        else {
            lastVersionLabel.text = "App is fresh installed"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

