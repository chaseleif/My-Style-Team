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
    
    var fieldText: [UITextField: String] = [:]
    var viewText: [UITextView: String] = [:]
    
    //buttons
    @IBOutlet weak var groupRequest: UIButton!
    @IBOutlet weak var groupCancel: UIButton!
    
    //used for keyboard display to not cover text fields
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var topLabelToTopViewConstraint: NSLayoutConstraint!
    let topLabelToTopViewConstraintConstant:CGFloat = 20.0
    
    
    let emailRecipient: [String] = [ ContactNumberAndServiceArea.contactEmail() ?? "emailaddressnotfound" ]
    let emailSubject = ContactNumberAndServiceArea.emailSubject() ?? "Missing app information!"
    
    @IBAction func groupRequestButtonAction(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let emailBody = EmailFormat.formatEmail(from: groupName.text, contact: groupPhone.text, address: groupStreet.text, cityorzip: nil, requestInfo: groupDetails.text?.removingPercentEncoding, at: groupTime.text, with: nil)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(emailRecipient)
        composeVC.setSubject(emailSubject)
        composeVC.setMessageBody(emailBody, isHTML: false)
        groupCancel.setTitle("Return", for: .normal)
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
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if !groupDetails.isFirstResponder {
            return
        }
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            let targetY = view.frame.size.height - rect.height - 8 - groupDetails.intrinsicContentSize.height
            let textFieldY = outerView.frame.origin.y + groupDetails.frame.maxY
            self.topLabelToTopViewConstraint.constant = (targetY - textFieldY) + self.topLabelToTopViewConstraintConstant
            self.view.layoutIfNeeded()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If we can't email let us know
        if !MFMailComposeViewController.canSendMail() {
            let displayMessage = UIAlertController(title: "Email must be enabled", message: "Unable to submit request", preferredStyle: UIAlertControllerStyle.alert)
            displayMessage.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(displayMessage, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

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
        
        fieldText = [groupName:"Name", groupPhone:"Phone number", groupStreet:"Event location", groupTime:"Event date and time"]
        viewText = [groupDetails:"Event details"]
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissTextViews))
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        groupPhone.inputAccessoryView = toolBar
        groupDetails.inputAccessoryView = toolBar
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
            topLabelToTopViewConstraint.constant = self.topLabelToTopViewConstraintConstant
            return
        }
        if textView.clearsOnInsertion == true {
            textView.clearsOnInsertion = false
            textView.text = String()
        }
    }
    @objc func dismissTextViews() {
        if groupPhone.isFirstResponder {
            if (groupPhone.text?.isEmpty)! {
                groupPhone.text = fieldText[groupPhone]
                groupPhone.clearsOnBeginEditing = true
            }
            groupPhone.resignFirstResponder()
            groupStreet.becomeFirstResponder()
        }
        else if groupDetails.isFirstResponder {
            if groupDetails.text.isEmpty {
                groupDetails.text = viewText[groupDetails]
                groupDetails.clearsOnInsertion = true
            }
            groupDetails.resignFirstResponder()
            topLabelToTopViewConstraint.constant = topLabelToTopViewConstraintConstant
            self.view.layoutIfNeeded()
        }
        else if groupName.isFirstResponder {
            if (groupName.text?.isEmpty)! {
                groupName.text = fieldText[groupName]
                groupName.clearsOnBeginEditing = true
            }
            groupName.resignFirstResponder()
        }
        else if groupStreet.isFirstResponder {
            if (groupStreet.text?.isEmpty)! {
                groupStreet.text = fieldText[groupStreet]
                groupStreet.clearsOnBeginEditing = true
            }
            groupStreet.resignFirstResponder()
        }
        else if groupTime.isFirstResponder {
            if (groupTime.text?.isEmpty)! {
                groupTime.text = fieldText[groupTime]
                groupTime.clearsOnBeginEditing = true
            }
            groupTime.resignFirstResponder()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.clearsOnBeginEditing = false
        textField.resignFirstResponder()
        if (textField.text?.isEmpty)! {
            textField.text = fieldText[textField]
            textField.clearsOnBeginEditing = true
        }
        if textField == groupName {
            groupPhone.becomeFirstResponder()
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
        if groupPhone.isFirstResponder {
            if (groupPhone.text?.isEmpty)! {
                groupPhone.text = fieldText[groupPhone]
                groupPhone.clearsOnBeginEditing = true
            }
            groupPhone.resignFirstResponder()
        }
        else {
            self.dismissTextViews()
        }
    }
    
}
