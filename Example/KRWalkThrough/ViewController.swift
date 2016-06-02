//
//  ViewController.swift
//  KRWalkThrough
//
//  Created by Joshua Park on 06/02/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRWalkThrough

class ViewController: UIViewController {
    var isFirstLogin: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.isFirstLogin)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFirstLogin {
            setUpWalkThrough()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    private func setUpWalkThrough() {
        // 1. Show welcome page with button
        // 2. Focus + button in the middle
        // 3. Modally present a view with text fields. Focus first text field
        // 4. Focus next text field
        // 5. Focus `Done` button on upper-right corner
        // 6. Show finish button
    }

}

