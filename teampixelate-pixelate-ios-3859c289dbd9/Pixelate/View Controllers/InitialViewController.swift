//
//  InitialViewController.swift
//  Pixelate
//
//  Created by Taneja-Mac on 26/02/19.
//  Copyright © 2019 Taneja-Mac. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let segueId = MyDevice.userLoggedIn() ? "InitialToCamView" : "InitialToLoginView"
        self.performSegue(withIdentifier: segueId, sender: self)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
