//
//  ViewController.swift
//  YOW
//
//  Created by pandaman on 9/23/14.
//  Copyright (c) 2014 Ratsimihah. All rights reserved.
//

import UIKit
import Accounts
import SwifteriOS

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?
    var swifter: Swifter
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.swifter = Swifter(consumerKey: "EkPgKMGXFuf06hYNh4xJxzOKr", consumerSecret: "NFT2KaEaMOQzsVdkx7GyhDp80suDvPSKBpkrhwW5hdcrGDRqwA")
        NSLog("Initialized Swifter as \(swifter)")
        super.init(nibName:nil, bundle:nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Loaded ViewController!")
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView!.delegate = self;
        tableView!.dataSource = self;
        tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier:"cell")
        self.view.addSubview(tableView!)
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options:nil) { (granted, error) -> Void in
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                let twitterAccount = twitterAccounts.last as ACAccount
                NSLog("Got Twitter account: \(twitterAccount)")
                self.swifter = Swifter(account: twitterAccount)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView!.contentOffset = CGPoint(x: 0, y: -UIApplication.sharedApplication().statusBarFrame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Checkpoint \(indexPath.row+1)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (UIScreen.mainScreen().bounds.height - UIApplication.sharedApplication().statusBarFrame.height) / 9
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Hit checkpoint \(indexPath.row+1)")
    }
}