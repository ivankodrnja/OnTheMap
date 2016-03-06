//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //var students: [StudentInformation] = [StudentInformation]()
    
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
       // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonTouchUp")
        
        
        let rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshData")
        let rightInformationPostingButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "postInformation")
        
        self.parentViewController?.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightInformationPostingButtonItem], animated: true)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    

    func logoutButtonTouchUp(){
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().logout(){ success, error in
            
            if success{
                self.activityIndicator.stopAnimating()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print(error)
            }
        }
        
    }
    
    func refreshData(){
        self.activityIndicator.startAnimating()
        // get locations
        ParseClient.sharedInstance().getStudentLocations(){(result, error) in
            // proceeed if we got result from Parse API with student locations (information)
            if error == nil {
                ParseClient.sharedInstance().studentsDict = result!
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.studentsTableView.reloadData()
                }
            } else {
         
                self.displayError(error?.localizedDescription)


            }
        }
    }
    
    func postInformation(){
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController 
            self.presentViewController(controller, animated: true, completion: nil)
            
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
    
    // MARK: - Table delegate methods
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentlistTableViewCell"
        let student = ParseClient.sharedInstance().studentsDict[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = student.firstName! + " " + student.lastName!
        cell.imageView!.image = UIImage(named: "Pin Icon")
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentsDict.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: ParseClient.sharedInstance().studentsDict[indexPath.row].mediaUrl!)!)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}

