//
//  EmailFormat.swift
//  MyStyleTeam
//
//  Created by Chase Phelps on 28/12/17.
//  Copyright © 2017 Chase Phelps. All rights reserved.
//

import Foundation


/*******
 Receives several String? as indicated by $
 this class returns a long string that is to be the body of the email
 ******/

/*Email Format:
 
 My Style Team!
 
 When: $time
 Where: $street, $zip
 What: $details
 Promo: $promo
 Who: $name !
 
 Confirm at: $number
 
 */

class EmailFormat {
    /*variable names
    var customerName: String?
    var customerNumber: String?
    var customerStreet: String?
    var customerZip: String?
    var customerDetails: String?
    var customerTime: String?
    var customerPromo: String?*/
    
    static func formatEmail(from customerName: String?,contact customerNumber: String?, address customerStreet: String?, cityorzip customerZip: String?, requestInfo customerDetails: String?, at customerTime: String?,with customerPromo: String?) -> String {
        
        var returnMe = "My Style Team!\n\n"
        if (customerTime != nil && (customerTime != "Date(s)+time(s) available" && customerTime != "Event date and time")) { returnMe = returnMe + "When: \(customerTime!)\n" }
        if (customerStreet != nil && (customerStreet != "Street address" && customerStreet != "Event location")) {
            returnMe = returnMe + "Where: \(customerStreet!)"
            if customerZip != nil && customerZip != "City/Postal code" { returnMe = returnMe + ", \(customerZip!)\n" }
            else { returnMe = returnMe + "\n" }
        }
        if (customerDetails != nil && (customerDetails != "Services requested" && customerDetails != "Details")) { returnMe = returnMe + "What: \(customerDetails!)\n" }
        if customerPromo != nil && customerPromo != "Promo code" { returnMe = returnMe + "Promo: \(customerPromo!)\n" }
        if customerName != nil && customerName != "Name" { returnMe = returnMe + "Who: \(customerName!) !\n" }
        if customerNumber != nil && customerNumber != "Phone number" { returnMe = returnMe + "\n\nConfirm at: \(customerNumber!)" }
        returnMe = returnMe + "\n\n"
        
        
        return returnMe
    }
    
    
}
