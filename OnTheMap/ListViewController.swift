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
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ListViewController.logoutButtonTouchUp))
        
        
        let rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(ListViewController.refreshData))
        let rightInformationPostingButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin Icon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ListViewController.postInformation))
        
        self.parent?.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightInformationPostingButtonItem], animated: true)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    

    @objc func logoutButtonTouchUp(){
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().logout(){ success, error in
            
            if success{
                self.activityIndicator.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error!)
            }
        }
        
    }
    
    @objc func refreshData(){
        self.activityIndicator.startAnimating()
        // get locations
        ParseClient.sharedInstance().getStudentLocations(){(result, error) in
            // proceeed if we got result from Parse API with student locations (information)
            if error == nil {
                ParseClient.sharedInstance().studentsDict = result!
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.studentsTableView.reloadData()
                }
            } else {
         
                self.displayError(error?.localizedDescription)


            }
        }
    }
    
    @objc func postInformation(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController 
            self.present(controller, animated: true, completion: nil)
            
        }

    // MARK: - helpers

    func showAlertView(_ errorMessage: String?) {

        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true){
            
        }
        
    }
    
    // MARK: - Table delegate methods
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentlistTableViewCell"
        let student = ParseClient.sharedInstance().studentsDict[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = student.firstName! + " " + student.lastName!
        cell.imageView!.image = UIImage(named: "Pin Icon")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentsDict.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        app.openURL(URL(string: ParseClient.sharedInstance().studentsDict[indexPath.row].mediaUrl!)!)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

