//
//  ViewController.swift
//  LiveCodeDemo
//
//  Created by Qingjie Zhao on 6/17/16.
//  Copyright © 2016 Qingjie Zhao. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController ,UITableViewDataSource {

	let ref = FIRDatabase.database().reference()

	
	var messages = [String]()
	var uid:String = ""
	
	@IBOutlet weak var tbView: UITableView!
	
	@IBAction func addMessage(sender: UIBarButtonItem) {
		let msgInput = UIAlertController(title:"New message",message: "Add message",preferredStyle: UIAlertControllerStyle.Alert)
		
		msgInput.addAction(UIAlertAction(title:"Add",style: .Default,handler: {(action) -> Void in
			let textField = msgInput.textFields![0] as UITextField
			self.pushToFirebase(textField.text! as String)
		}))
		
		msgInput.addTextFieldWithConfigurationHandler { (textField) -> Void in
			textField.placeholder = "Your message"
		}
		
		msgInput.view.setNeedsLayout()
		self.presentViewController(msgInput, animated: true, completion: nil)
	}
	
	
	func pushToFirebase(text:String) {
		let msgData = [
			"text" : text,
			"user" : uid
		]
		ref.childByAutoId().setValue(msgData)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ref.keepSynced(true)
		
		FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (user, error) in
			if error != nil {
				print(error)
			}else{
				//let isAnonymous = user!.anonymous
				//let uid = user!.uid
				self.uid = user!.uid
			}
			
		})
		
	}

	
	override func viewDidAppear(animated: Bool) {
		var localArray = [String]()
		
		ref.observeEventType(.ChildAdded, withBlock:  { snapshot in
			print(snapshot.value)
			let msgText = snapshot.value?.objectForKey("text") as! String
			localArray.insert(msgText, atIndex: 0)
			self.messages = localArray
			self.tbView.reloadData()
		})
		
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) 
		
		cell.textLabel?.text = messages[indexPath.section]
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	

}

