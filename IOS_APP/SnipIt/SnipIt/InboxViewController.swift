//
//  InboxViewController.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/15/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import UIKit
import AVFoundation


let reuseIdentifier = "SnippetCollectionViewCell"

class InboxViewController: UICollectionViewController {
    var shouldFetchNewData = true
    var audioPlayer: AVPlayer!
    var dataArray = [RecordedAudio]()
    let httpHelper = HTTPHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check if user signed in
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // If not signed in, go to the Login screen
        if defaults.objectForKey("userLoggedIn") == nil {
            let loginController: LoginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.navigationController?.presentViewController(loginController, animated: true, completion: nil)
        }else {
            // Check if API token has expired
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let userTokenExpiryDate : NSString? = KeychainAccess.passwordForAccount("Auth_Token_Expiry", service: "KeyChainService")
            let dateFromString : NSDate? = dateFormatter.dateFromString(userTokenExpiryDate! as String)
            let now = NSDate()
            
            let comparision = now.compare(dateFromString!)
            
            // check if should fetch new data
            if shouldFetchNewData {
                shouldFetchNewData = false
                loadSnippetData()
            }
            // logout and ask user to sign in again if token is expired
            if comparision != NSComparisonResult.OrderedAscending {
                self.logoutBtnTapped()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        let errorAlert: UIAlertController = UIAlertController(title: alertTitle as String, message: alertDescription as String, preferredStyle: .Alert)
        let cancelAlert: UIAlertAction = UIAlertAction(title: "Got it", style: .Cancel) { action -> Void in }
        errorAlert.addAction(cancelAlert)
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }

    func logoutBtnTapped() {
        clearLoggedinFlagInUserDefaults()
        clearDataArrayAndReloadCollectionView()
        clearAPITokensFromKeyChain()
        
        // Set flag to display Sign In view
        shouldFetchNewData = true
        self.viewDidAppear(true)
    }
    
    func clearLoggedinFlagInUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        defaults.synchronize()
    }
    
    // 2. Removes the data array
    func clearDataArrayAndReloadCollectionView() {
        self.dataArray.removeAll(keepCapacity: true)
        self.collectionView?.reloadData()
    }
    
    // 3. Clears API Auth token from Keychain
    func clearAPITokensFromKeyChain () {
        // clear API Auth Token
        if let userToken = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService") {
            KeychainAccess.deletePasswordForAccount(userToken, account: "Auth_Token", service: "KeyChainService")
        }
        
        // clear API Auth Expiry
        if let userTokenExpiryDate = KeychainAccess.passwordForAccount("Auth_Token_Expiry",
            service: "KeyChainService") {
                KeychainAccess.deletePasswordForAccount(userTokenExpiryDate, account: "Auth_Token_Expiry",
                    service: "KeyChainService")
        }
    }
    
    func loadSnippetData() {
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("get_snippets", method: "GET",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        // Send HTTP request to load existing selfie
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                return
            }
            
            var eror: NSError?
            let jsonDataArray = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions(0), error: &eror) as! NSArray!
            
            // load the collection view with existing selfies
            if jsonDataArray != nil {
                for audioDataDict in jsonDataArray {
                    var snippetObj = RecordedAudio()
                    var urlString = audioDataDict.valueForKey("audio_url") as! NSString
                    snippetObj.filePathUrl = NSURL(string: urlString as String)
                    snippetObj.title = audioDataDict.valueForKey("from") as! NSString as String
                    self.dataArray.append(snippetObj)
                }
                self.collectionView?.reloadData()
            }
        })
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! InboxViewCell
        
        // Configure the cell
        var rowIndex = self.dataArray.count - (indexPath.row + 1)
        var selfieRowObj = self.dataArray[rowIndex] as RecordedAudio
        
        cell.backgroundColor = UIColor.whiteColor()
        
        cell.from.text = selfieRowObj.title
        cell.play.setTitle("Play", forState: .Normal)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Here's where we'll play the audio
        var rowIndex = self.dataArray.count - (indexPath.row + 1)
        var snippetRowObj = self.dataArray[rowIndex] as RecordedAudio
        let playerItem = AVPlayerItem(URL: snippetRowObj.filePathUrl)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer.rate = 1.0;
//        for cell in collectionView.subviews as! [InboxViewCell] {
//            if let button = cell.play {
//                button.setTitle("Play", forState: .Normal)
//            }
//        }
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? InboxViewCell {
            if cell.play.titleLabel?.text == "Play" {
                cell.play.setTitle("Stop", forState: .Normal)
                audioPlayer.play()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemDidReachEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: audioPlayer.currentItem)
            }else {
                audioPlayer.pause()
                audioPlayer.seekToTime(CMTimeMake(0, 1))
            }
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
//        for cell in self.collectionView!.visibleCells() as! [InboxViewCell] {
//            if let button = cell.play {
//                button.setTitle("Play", forState: .Normal)
//            }
//        }
    }

}
