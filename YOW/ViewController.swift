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
import CoreLocation
import MobileCoreServices // for kUTTypeImage

class ViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIAlertViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CLLocationManagerDelegate {

    let countDownInitialValue = 1;
    let quotes = [
        "Let's get rolling!",
        "What a nice day!",
        "Here we go!",
        "Cruising!",
        "Where's the party at?",
        "Almost there!",
        "Not even tired!",
        "I can see the finish line!",
        "Oh, hello!"
    ]
    
    var collectionView: UICollectionView?
    var swifter: Swifter
    
    var cameraUI: UIImagePickerController
    var countDownNSTimer:NSTimer?
    var countDownTimer:Int
    var countDownLabel:UILabel
    var messageContent:String?
    
    var locationManager: CLLocationManager!
    var currentLocationCoordinates = CLLocationCoordinate2D()

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.swifter = Swifter(consumerKey: "EkPgKMGXFuf06hYNh4xJxzOKr", consumerSecret: "NFT2KaEaMOQzsVdkx7GyhDp80suDvPSKBpkrhwW5hdcrGDRqwA")
        self.countDownTimer = countDownInitialValue
        self.countDownLabel = UILabel(frame: UIScreen.mainScreen().bounds)
        self.cameraUI = UIImagePickerController()
        self.locationManager = CLLocationManager()
        super.init(nibName:nil, bundle:nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Loaded ViewController!")
        // Do any additional setup after loading the view, typically from a nib.
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flowLayout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.width/3, UIScreen.mainScreen().bounds.height/3)
        
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: flowLayout)
        collectionView!.backgroundColor = UIColor.blackColor()
        collectionView!.delegate = self;
        collectionView!.dataSource = self;
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collectionView!)
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options:nil) { (granted, error) -> Void in
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                let twitterAccount = twitterAccounts.last as! ACAccount
                NSLog("Got Twitter account: \(twitterAccount)")
                self.swifter = Swifter(account: twitterAccount)
            }
        }
        
        println("Setting up location manager \(locationManager)")
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locationArray = locations as! [CLLocation]
        let location = locationArray[0]
        let coordinates = location.coordinate
        self.currentLocationCoordinates = coordinates
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.contentView.backgroundColor = UIColor.blackColor()
        
        let numberLabel = UILabel(frame: cell.bounds)
        numberLabel.text = "\(indexPath.row + 1)"
        numberLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 300)
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.textAlignment = NSTextAlignment.Center
        cell.addSubview(numberLabel)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSLog("Hit checkpoint \(indexPath.row+1)")
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let errorAlertView = UIAlertView(title: "Whoops", message: "Camera not available!", delegate:self, cancelButtonTitle:"Back", otherButtonTitles:"Double Back")
        } else {
            NSLog("Camera is available. Presenting UI...")
            self.cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
            self.cameraUI.mediaTypes = NSArray(object: kUTTypeImage) as [AnyObject]
            self.cameraUI.allowsEditing = false
            self.cameraUI.showsCameraControls = false
            self.cameraUI.delegate = self
            self.cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            self.countDownLabel.text = String(self.countDownTimer)
            self.countDownLabel.textColor = UIColor.whiteColor()
            self.countDownLabel.textAlignment = NSTextAlignment.Center
            self.countDownLabel.font = UIFont(name: "HelveticaNeue-Light", size: 200)
            
            self.cameraUI.cameraOverlayView?.addSubview(self.countDownLabel)
            self.cameraUI.cameraViewTransform = CGAffineTransformMakeScale(2, 2)
            
            self.messageContent = "\(indexPath.row+1) down! \(quotes[indexPath.row]) #YOW @paragonsports"
            
            self.presentViewController(self.cameraUI, animated:false, completion: { () -> Void in
                NSLog("Presented camera UI!")
                self.countDownNSTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
            })
        }

    }
    
    func countDown() {
        if self.countDownTimer == -1 {
            NSLog("Timer is 0. Picture time!")
            self.countDownNSTimer?.invalidate()
            self.countDownLabel.text = ":)"
            self.cameraUI.takePicture()
            self.countDownTimer = countDownInitialValue
        } else {
            NSLog("Countdown is now \(self.countDownTimer)!")
            self.countDownLabel.text = String(countDownTimer)
            self.countDownTimer--
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        NSLog("Got image \(image)!")
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // Should tweet picture as well
        postToTwitter(image)
        postToInstagram(image)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func postToTwitter(image: UIImage!) {
        NSLog("Posting to Twitter...")
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        self.swifter.postStatusUpdate(self.messageContent!, media:imageData,
            inReplyToStatusID: nil,
            lat: self.currentLocationCoordinates.latitude,
            long: self.currentLocationCoordinates.longitude,
            placeID: nil,
            displayCoordinates: true, trimUser: nil, success: { (status) -> Void in
            NSLog("\(status)")
        }) { (error) -> Void in
            NSLog("\(error)")
        }
    }
    
    func postToInstagram(image: UIImage!) {
        NSLog("Posting to Instagram...")
    }
}