//
//  ViewController.swift
//  myMeme
//
//  Created by Pamela Rios on 7/19/16.
//  Copyright © 2016 Pamela Rios. All rights reserved.
//



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
        memeView.backgroundColor = UIColor.lightGrayColor()
        setUpTextProperties(topField)
        setUpTextProperties(bottomField)
        imagePicker.delegate = self
        
    }
    // this method will help me to avoid repetition for the top & bottom field so I set up their properties inside of it
    
    func setUpTextProperties ( textField: UITextField ){
        
      textField.defaultTextAttributes = [NSStrokeColorAttributeName : UIColor.blackColor(),
                                         NSForegroundColorAttributeName : UIColor.whiteColor(),
                                         NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                                         NSStrokeWidthAttributeName : NSNumber(double: -3.0)]
        textField.textAlignment = .Center
        
        textField.delegate = TextLabelDelegate
       //instead of an if statement , I will use a ternary conditional // example: let result = true == false ? : true
        textField.placeholder = topField==textField ? " TOP TEXT HERE!":"BOTTOM TEXT HERE!"
    }
   
    
    //keyboard subscriptions will let me access and controlkeyboard
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        pickImageButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        shareButton.enabled = imageView.image != nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
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
    //This will handle the height and the position for the keyboard
    func adjustForKeyboardRemoval(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
        arrageDisplayForKeyboard = false
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue    // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    
    //will get the pics from the album***************************************************************
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    //method will get pics from the camera directly (modificado)
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        if sender as! NSObject == cameraButton {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        }
        else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(imagePicker, animated: true, completion: nil)
        
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

