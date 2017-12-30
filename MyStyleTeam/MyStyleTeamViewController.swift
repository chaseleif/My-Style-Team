//
//  ViewController.swift
//  MyStyleTeam
//
//  Created by Chase Phelps on 25/12/17.
//  Copyright © 2017 Chase Phelps. All rights reserved.
//

import UIKit

class MyStyleTeamViewController: UIViewController {
    
    @IBOutlet weak var bottomLabelTop: UILabel!
    @IBOutlet weak var bottomLabelBottom: UILabel!
    //Text or call "(512) 867-5309"
    //Serving "this area"
    /****This is required information for the home display****/
    
    
    //unwind for segues returning to main screen
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        bottomLabelTop.text = "Text or call \(ContactNumberAndServiceArea.phoneNumber() ?? "Phone number missing")"
        bottomLabelBottom.text = "Serving \(ContactNumberAndServiceArea.serviceArea() ?? "Service area missing")"
    }

}

