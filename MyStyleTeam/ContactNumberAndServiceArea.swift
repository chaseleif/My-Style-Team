//
//  ContactNumberAndServiceArea.swift
//  MyStyleTeam
//
//  Created by Chase Phelps on 30/12/17.
//  Copyright © 2017 Chase Phelps. All rights reserved.
//

import Foundation

/********
 The global storage for semi-permanent variables
 *******/

class ContactNumberAndServiceArea {
    
    //ContactViewController, AppointmentViewController
    static func contactEmail() -> String? {
        return "hello@mystyleteam.com"
    }
    static func emailSubject() -> String? {
        return "MyStyleTeam Appointment Request"
    }
    
    //MyStyleTeamViewController
    static func phoneNumber() -> String? {
        return "(773)819-0469"
    }
    static func serviceArea() -> String? {
        return "Austin and Round Rock"
    }
    
}
