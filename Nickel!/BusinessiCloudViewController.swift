//
//  BusinessiCloudViewController.swift
//  Nickel!
//
//  Created by Matt Deuschle on 2/16/16.
//  Copyright © 2016 Andrew Palka. All rights reserved.
//

import UIKit

class BusinessiCloudViewController: SuperViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    var cloudHelper: CKHelper?
    var aUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudHelper = CKHelper()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.iCloudLoginAction()
        return resignFirstResponder()
    }
    // Action to be called when the user taps "login with iCloud"
    func iCloudLoginAction() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.iCloudLogin({ (success) -> () in
            if success {
                userDefaults.setBool( true, forKey: "Logged in")
                self.updateVCList()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("revCon") as! SWRevealViewController
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(viewController, animated: false, completion: nil)
                   UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            } else {
                // TODO error handling
            }
        })
    }
    
    // Nested CloudKit requests for permission; for getting user record and user information.
    private func iCloudLogin(completionHandler: (success: Bool) -> ()) {
        self.cloudHelper!.requestPermission { (granted) -> () in
            if !granted {
                let iCloudAlert = UIAlertController(title: "iCloud Error", message: "There was an error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                iCloudAlert.addAction(okAction)
                self.presentViewController(iCloudAlert, animated: true, completion: nil)
            } else {
                self.cloudHelper!.getUser({ (success, user) -> () in
                    if success {
                        print("\(user!.userRecordID)")
//                        userDefaults.setValue("\(user!.userRecordID)", forKey: "userRecordID")
                        self.aUser = user
                        print("\(self.aUser!.userRecordID)")

                        self.cloudHelper!.getUserInfo(self.aUser!, completionHandler: { (success, user) -> () in
                            if success {
                                completionHandler(success: true)
                            }
                        })
                    } else {
                        // TODO error handling
                    }
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
}
