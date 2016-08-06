//
//  TextDelegate.swift
//  myMeme
//
//  Created by Pamela Rios on 7/19/16.
//  Copyright © 2016 Pamela Rios. All rights reserved.
//
import UIKit

class TextDelegate:NSObject, UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        }
}

