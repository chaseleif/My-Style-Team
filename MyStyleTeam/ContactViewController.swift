//
//  ContactViewController.swift
//  MyStyleTeam
//
//  Created by Chase Phelps on 26/12/17.
//  Copyright © 2017 Chase Phelps. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class ContactViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    //text fields
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupPhone: UITextField!
    @IBOutlet weak var groupStreet: UITextField!
    @IBOutlet weak var groupDetails: UITextView!
    @IBOutlet weak var groupTime: UITextField!
    //buttons
    @IBOutlet weak var groupRequest: UIButton!
    @IBOutlet weak var groupCancel: UIButton!
    
    let emailRecipient: [String] = [ "hello@mystyleteam.com" ]
    let emailSubject = "MyStyleTeam Appointment Request"
    
    @IBAction func groupRequestButtonAction(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        groupCancel.setTitle("Return", for: .normal)
        let emailBody = EmailFormat.formatEmail(from: groupName.text, contact: groupPhone.text, address: groupStreet.text, cityorzip: nil, requestInfo: groupDetails.text?.removingPercentEncoding, at: groupTime.text, with: nil)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(emailRecipient)
        composeVC.setSubject(emailSubject)
        composeVC.setMessageBody(emailBody, isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
     }
     func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        var emailSent: String?
        var emailInfo: String?
        
        if (result.rawValue == 0) {//cancel
            emailSent = "Cancelled"
        }
        else if (result.rawValue == 1) {//save
            emailSent = "Email saved to drafts"
        }
        else if (result.rawValue == 2) {//send
            emailSent = "Email sent"
            emailInfo = "We will contact you to confirm!"
        }
        else {
            emailSent = "Unsure if email sent!"
        }
        let displayResult = UIAlertController(title: emailSent!, message: emailInfo ?? String(), preferredStyle: UIAlertControllerStyle.alert)
        displayResult.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(displayResult, animated: true, completion: nil)
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If we can't email let us know
        if !MFMailComposeViewController.canSendMail() {
            let displayMessage = UIAlertController(title: "Email must be enabled", message: "Unable to submit request", preferredStyle: UIAlertControllerStyle.alert)
            displayMessage.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(displayMessage, animated: true, completion: nil)
        }

        groupName.delegate = self
        groupPhone.delegate = self
        groupStreet.delegate = self
        groupTime.delegate = self
        groupDetails.delegate = self
        
        groupName.clearsOnBeginEditing = true
        groupPhone.clearsOnBeginEditing = true
        groupStreet.clearsOnBeginEditing = true
        groupTime.clearsOnBeginEditing = true
        
        groupDetails.clearsOnInsertion = true
        groupDetails.autocorrectionType = UITextAutocorrectionType.yes
        groupDetails.spellCheckingType = UITextSpellCheckingType.yes
        groupDetails.layer.cornerRadius = 10
    }
    
    var textViewHasBeenAutomaticallyOpened: Bool?
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if textViewHasBeenAutomaticallyOpened == nil {
            textViewHasBeenAutomaticallyOpened = true
            textView.resignFirstResponder()
            return
        }
        if textView.clearsOnInsertion == true {
            textView.clearsOnInsertion = false
            textView.text = String()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.clearsOnBeginEditing = false
        textField.resignFirstResponder()
        if textField == groupName {
            groupPhone.becomeFirstResponder()
        }
        else if textField == groupPhone {
            groupStreet.becomeFirstResponder()
        }
        else if textField == groupStreet {
            groupTime.becomeFirstResponder()
        }
        else if textField == groupTime {
            groupDetails.becomeFirstResponder()
        }
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        groupDetails.resignFirstResponder()
    }
    
}
