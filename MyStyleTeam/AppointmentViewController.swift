//
//  AppointmentViewController.swift
//  MyStyleTeam
//
//  Created by Chase Phelps on 27/12/17.
//  Copyright © 2017 Chase Phelps. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AppointmentViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    //text fields
    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var bookPhone: UITextField!
    @IBOutlet weak var bookStreet: UITextField!
    @IBOutlet weak var bookZip: UITextField!
    
    @IBOutlet weak var bookServices: UITextView!
    @IBOutlet weak var bookTime: UITextView!
    @IBOutlet weak var bookPromo: UITextField!
    //buttons
    @IBOutlet weak var bookCancel: UIButton!
    
    let emailRecipient: [String] = [ "hello@mystyleteam.com" ]
    let emailSubject = "MyStyleTeam Appointment Request"
    
    @IBAction func bookRequestButtonAction(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        bookCancel.setTitle("Return", for: .normal)
        let emailBody = EmailFormat.formatEmail(from: bookName.text, contact: bookPhone.text, address: bookStreet.text, cityorzip: bookZip.text, requestInfo: bookServices.text?.removingPercentEncoding, at: bookTime.text?.removingPercentEncoding, with: bookPromo.text)
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
        
        bookName.delegate = self
        bookPhone.delegate = self
        bookStreet.delegate = self
        bookZip.delegate = self
        bookServices.delegate = self
        bookTime.delegate = self
        bookPromo.delegate = self
        
        bookName.clearsOnBeginEditing = true
        bookPhone.clearsOnBeginEditing = true
        bookStreet.clearsOnBeginEditing = true
        bookZip.clearsOnBeginEditing = true
        bookPromo.clearsOnBeginEditing = true
        
        bookServices.autocorrectionType = UITextAutocorrectionType.yes
        bookServices.spellCheckingType = UITextSpellCheckingType.yes
        bookServices.layer.cornerRadius = 10
        bookServices.clearsOnInsertion = true
        bookTime.autocorrectionType = UITextAutocorrectionType.yes
        bookTime.spellCheckingType = UITextSpellCheckingType.yes
        bookTime.layer.cornerRadius = 10
        bookTime.clearsOnInsertion = true
    }
    var textViewWasBeenAutomaticallyOpened: Bool?
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if textViewWasBeenAutomaticallyOpened == nil {
            textViewWasBeenAutomaticallyOpened = true
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
        textField.resignFirstResponder()
        textField.clearsOnBeginEditing = false
        if textField == bookName {
            bookPhone.becomeFirstResponder()
        }
        else if textField == bookPhone {
            bookStreet.becomeFirstResponder()
        }
        else if textField == bookStreet {
            bookZip.becomeFirstResponder()
        }
        else if textField == bookZip {
            bookServices.becomeFirstResponder()
        }
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        bookServices.resignFirstResponder()
        bookTime.resignFirstResponder()
    }
    
}

