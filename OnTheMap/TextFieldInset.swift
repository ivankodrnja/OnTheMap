//
//  TextFieldInset.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 24/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit
// enable insets for the textfield in Storyboard
@IBDesignable
class TextFieldInset: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
}
