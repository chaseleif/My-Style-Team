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
    
    var fieldText: [UITextField: String] = [:]
    var viewText: [UITextView : String] = [:]
    //buttons
    @IBOutlet weak var bookCancel: UIButton!
    
    //used for keyboard display to not cover text fields
    @IBOutlet var outerView: UIView!
    @IBOutlet weak var topLabelToTopViewConstraint: NSLayoutConstraint!
    let topLabelToTopViewConstraintConstant:CGFloat = 20.0
    
    let emailRecipient: [String] = [ ContactNumberAndServiceArea.contactEmail() ?? "emailaddressnotfound"]
    let emailSubject = ContactNumberAndServiceArea.emailSubject() ?? "Missing app information!"
    
    @IBAction func bookRequestButtonAction(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let emailBody = EmailFormat.formatEmail(from: bookName.text, contact: bookPhone.text, address: bookStreet.text, cityorzip: bookZip.text, requestInfo: bookServices.text?.removingPercentEncoding, at: bookTime.text?.removingPercentEncoding, with: bookPromo.text)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(emailRecipient)
        composeVC.setSubject(emailSubject)
        composeVC.setMessageBody(emailBody, isHTML: false)
        bookCancel.setTitle("Return", for: .normal)
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
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            let targetY = view.frame.size.height - rect.height - 8 - self.activeFieldHeight()
            let textFieldY = outerView.frame.origin.y + activeFieldPos()
            
            if targetY < textFieldY {
                self.topLabelToTopViewConstraint.constant = (targetY - textFieldY) + self.topLabelToTopViewConstraintConstant
                self.view.layoutIfNeeded()
            }
        }
    }
    func activeFieldHeight() -> CGFloat {
        if bookServices.isFirstResponder {
            return bookServices.intrinsicContentSize.height
        }
        if bookTime.isFirstResponder {
            return bookTime.intrinsicContentSize.height
        }
        return bookName.intrinsicContentSize.height
    }
    func activeFieldPos() -> CGFloat {
        if bookServices.isFirstResponder {
            return bookServices.frame.maxY
        }
        if bookTime.isFirstResponder {
            return bookTime.frame.maxY
        }
        if bookPromo.isFirstResponder {
            return bookPromo.frame.maxY
        }
        return CGFloat(0.0)
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
        
        fieldText = [bookName:"Name", bookPhone:"Phone number", bookStreet:"Address", bookZip:"City or Postal code", bookPromo:"Promo code"]
        viewText = [bookServices:"Services requested",
                    bookTime:"Date(s) & time(s) available"]
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissTextViews))
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        bookPhone.inputAccessoryView = toolBar
        bookServices.inputAccessoryView = toolBar
        bookTime.inputAccessoryView = toolBar
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
        topLabelToTopViewConstraint.constant = self.topLabelToTopViewConstraintConstant
        self.view.layoutIfNeeded()
        if bookPhone.isFirstResponder {
            if (bookPhone.text?.isEmpty)! {
                bookPhone.text = fieldText[bookPhone]
                bookPhone.clearsOnBeginEditing = true
            }
            bookPhone.resignFirstResponder()
            bookStreet.becomeFirstResponder()
        }
        else if bookServices.isFirstResponder {
            if (bookServices.text?.isEmpty)! {
                bookServices.text = viewText[bookServices]
                bookServices.clearsOnInsertion = true
            }
            bookServices.resignFirstResponder()
        }
        else if bookName.isFirstResponder {
            if (bookName.text?.isEmpty)! {
                bookName.text = fieldText[bookName]
                bookName.clearsOnBeginEditing = true
            }
            bookName.resignFirstResponder()
        }
        else if bookStreet.isFirstResponder {
            if (bookStreet.text?.isEmpty)! {
                bookStreet.text = fieldText[bookStreet]
                bookStreet.clearsOnBeginEditing = true
            }
            bookStreet.resignFirstResponder()
        }
        else if bookZip.isFirstResponder {
            if (bookZip.text?.isEmpty)! {
                bookZip.text = fieldText[bookZip]
                bookZip.clearsOnBeginEditing = true
            }
            bookZip.resignFirstResponder()
        }
        else if bookTime.isFirstResponder {
            if (bookTime.text?.isEmpty)! {
                bookTime.text = viewText[bookTime]
                bookTime.clearsOnInsertion = true
            }
            bookTime.resignFirstResponder()
        }
        else if bookPromo.isFirstResponder {
            if (bookPromo.text?.isEmpty)! {
                bookPromo.text = fieldText[bookPromo]
                bookPromo.clearsOnBeginEditing = true
            }
            bookPromo.resignFirstResponder()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.topLabelToTopViewConstraint.constant = self.topLabelToTopViewConstraintConstant
        self.view.layoutIfNeeded()
        self.view.endEditing(true)
        textField.resignFirstResponder()
        if (textField.text?.isEmpty)! {
            textField.text = fieldText[textField]
            textField.clearsOnBeginEditing = true
        }
        if textField == bookName {
            bookPhone.becomeFirstResponder()
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
        topLabelToTopViewConstraint.constant = self.topLabelToTopViewConstraintConstant
        self.view.layoutIfNeeded()
        if bookPhone.isFirstResponder {
            if (bookPhone.text?.isEmpty)! {
                bookPhone.text = fieldText[bookPhone]
                bookPhone.clearsOnBeginEditing = true
            }
            bookPhone.resignFirstResponder()
        }
        else {
            self.dismissTextViews()
        }
    }
    
}

