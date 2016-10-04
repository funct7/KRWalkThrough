//
//  PresentedViewController.swift
//  KRWalkThrough
//
//  Created by Joshua Park on 6/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KRWalkThrough

class PresentedViewController: UIViewController, UITextFieldDelegate {
    var isFirstLogin: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.isFirstLogin)
    }
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        if isFirstLogin {
            setUpWalkThrough()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLogin {
            TutorialManager.sharedManager().showTutorialWithIdentifier("3")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text ?? "").isEmpty { return false }
        
        if textField === textFieldName {
            textFieldEmail.becomeFirstResponder()
            
            if isFirstLogin { TutorialManager.sharedManager().showTutorialWithIdentifier("4") }
        } else {
            textFieldEmail.resignFirstResponder()
            
            if isFirstLogin { TutorialManager.sharedManager().showTutorialWithIdentifier("5") }
        }
        
        return true
    }
    
    // MARK: - Tutorial
    
    private func setUpWalkThrough() {
        let view3 = TutorialView(frame: Screen.bounds)
        view3.makeAvailable(textFieldName, insets: UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0), cornerRadius: 6.0)
        
        let item3 = TutorialItem(view: view3, identifier: "3")
        TutorialManager.sharedManager().registerItem(item3)
        
        let view4 = TutorialView(frame: Screen.bounds)
        view4.makeAvailable(textFieldEmail, insets: UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0), cornerRadius: 6.0)
        
        let item4 = TutorialItem(view: view4, identifier: "4")
        TutorialManager.sharedManager().registerItem(item4)
        
        let doneX: CGFloat = Screen.bounds.width - 85.0
        let doneY: CGFloat = -10.0
        
        let doneRect = CGRect(x: doneX, y: doneY, width: 100.0, height: 100.0)
        let view5 = TutorialView(frame: Screen.bounds)
        view5.makeAvailable(doneRect, cornerRadius: 50.0)
        let item5 = TutorialItem(view: view5, identifier: "5")
        
        TutorialManager.sharedManager().registerItem(item5)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
