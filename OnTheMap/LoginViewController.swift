//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        /* Configure the UI*/
        self.configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    // MARK: - Actions
    
    @IBAction func signupAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.Constants.signupUrl)!)
    }
    
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        // check if username (email) and aswword fields are entered
        if usernameTextField.text!.isEmpty {
            self.showAlertView("Email is empty!")
        } else if passwordTextField.text!.isEmpty {
            self.showAlertView("Password is empty!")
        } else {
            self.activityIndicator.startAnimating()
        
            UdacityClient.sharedInstance().authenticateUser(usernameTextField.text!, password: passwordTextField.text!) { (success, error) in
                
                
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(error?.localizedDescription)
                }
            }
            
        }
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    
    // MARK - UI configuration
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.969, green: 0.588, blue: 0.231, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.988, green: 0.435, blue: 0.176, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "Roboto-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        usernameTextField.leftView = emailTextFieldPaddingView
        usernameTextField.leftViewMode = .Always
        usernameTextField.font = UIFont(name: "Roboto-Medium", size: 17.0)
        usernameTextField.backgroundColor = UIColor(red: 0.980, green: 0.769, blue: 0.608, alpha:1.0)
        usernameTextField.textColor = UIColor(red: 0.988, green: 0.435, blue: 0.176, alpha: 1.0)
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.font = UIFont(name: "Roboto-Medium", size: 17.0)
        passwordTextField.backgroundColor = UIColor(red: 0.980, green: 0.769, blue: 0.608, alpha:1.0)
        passwordTextField.textColor = UIColor(red: 0.988, green: 0.435, blue: 0.176, alpha: 1.0)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "Roboto-Medium", size: 20)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure login button */
        loginButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 17.0)
        loginButton.highlightedBackingColor = UIColor(red: 1.0, green: 0.514, blue: 0.349, alpha:1.0)
        loginButton.backingColor = UIColor(red: 0.941, green:0.337, blue:0.169, alpha: 1.0)
        loginButton.backgroundColor = UIColor(red: 0.941, green:0.337, blue:0.169, alpha: 1.0)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        /* Configure signup button */
        signupButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 17.0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    // MARK: - helpers
    
    func showAlertView(errorMessage: String?) {
       
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
          
        
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }

    }
}