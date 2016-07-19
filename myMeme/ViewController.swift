//
//  ViewController.swift
//  myMeme
//
//  Created by Pamela Rios on 7/19/16.
//  Copyright © 2016 Pamela Rios. All rights reserved.
//

import UIKit

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{
    
    
    @IBOutlet var memeView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    @IBOutlet weak var topField: UITextField!
    
    
    
    @IBOutlet weak var bottomField: UITextField!
    
    
    
    @IBOutlet weak var pickImageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    let TextLabelDelegate = TextDelegate()
    let imagePicker = UIImagePickerController()
    
    private var arrageDisplayForKeyboard = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        shareButton.enabled = imageView.image != nil
        
        let textAttributes = [NSStrokeColorAttributeName : UIColor.blackColor(),
                              NSForegroundColorAttributeName : UIColor.whiteColor(),
                              NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                              NSStrokeWidthAttributeName : NSNumber(double: -3.0)]
        
        topField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: textAttributes)
        bottomField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: textAttributes)
        
        topField.defaultTextAttributes = textAttributes
        bottomField.defaultTextAttributes = textAttributes
        
        topField.delegate = TextLabelDelegate
        bottomField.delegate = TextLabelDelegate
        
        
        imagePicker.delegate = self
    }
    
    
    //***********Keyboard Subscriptions**********************
    
    // keyboard will show
    
    func keyboardWillShow(notification: NSNotification) {
        
        let isCurrentAppKeyboard = notification.userInfo![UIKeyboardIsLocalUserInfoKey] as! NSNumber
        
        if isCurrentAppKeyboard.boolValue {
            if bottomField.isFirstResponder() {
                if !arrageDisplayForKeyboard {
                    view.frame.origin.y -= getKeyboardHeight(notification)
                    arrageDisplayForKeyboard = true
                }
            } else {
                if arrageDisplayForKeyboard {
                    adjustForKeyboardRemoval(notification)
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let isCurrentAppKeyboard = notification.userInfo![UIKeyboardIsLocalUserInfoKey] as! NSNumber
        
        if isCurrentAppKeyboard.boolValue && arrageDisplayForKeyboard {
            adjustForKeyboardRemoval(notification)
        }
    }
    
    func adjustForKeyboardRemoval(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
        arrageDisplayForKeyboard = false
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue    // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    
    
    
    //*************************view will appear commands***********************
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribeToKeyboardNotifications()
        
        // pickImageButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        // cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        shareButton.enabled = imageView.image != nil
        
        
        func subscribeToKeyboardNotification () {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)) , name: UIKeyboardWillHideNotification, object: nil)}
        
    }
    //
    
    
    //will get the pics from the album
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    //method will get pics from the camera directly
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType=UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //
    //view will dissapear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        func unsubscribeFromKeyboardNotification(){
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        }
    }
    
    
    //share meme ************************************************************
    
    @IBAction func shareMeme1(sender: UIBarButtonItem) {
        
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            
        }
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func save() {
        
        let myMeme = Meme(topField:topField.text!,bottomField: bottomField.text!, image: imageView.image!, memedImage: generateMemedImage())
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(myMeme)
    }
    func generateMemedImage() -> UIImage {
        // Render image
        UIGraphicsBeginImageContext(memeView.frame.size)
        memeView.drawViewHierarchyInRect(CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: memeView.frame.size), afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
    
    
}
