//
//  RecordSoundViewController.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/5/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var startRecording: UIButton!
    @IBOutlet weak var stopRecording: UIButton!
    @IBOutlet weak var cancelRecording: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var shouldFetchNewData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
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
                //self.setNavigationItems()
                //loadSelfieData()
            }
            // logout and ask user to sign in again if token is expired
            if comparision != NSComparisonResult.OrderedAscending {
                self.logoutBtnTapped()
            }
        }
    }
    
    @IBAction func logoutButton(sender: UIBarButtonItem) {
        self.logoutBtnTapped()
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
        //self.dataArray.removeAll(keepCapacity: true)
        //self.collectionView?.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: UIButton) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let timeStamp = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(timeStamp)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // Initialize and prepare the recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        // audioRecorder.recordForDuration(10.0)
        //TODO Show Clock Counter (10seconds)
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        // Handle the UI stuff
        sender.hidden = true
        stopRecording.hidden = false
        recordingLabel.toggleFade(duration: 0.8)
        view.backgroundColor = UIColor.redBgColor()
        cancelRecording.toggleFade(duration: 0.8)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio()
            recordedAudio.filePathUrl = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            self.performSegueWithIdentifier("stoppedRecording", sender: recordedAudio)
        }else {
            println("Recording was not successfull")
            startRecording.hidden = false
            startRecording.hidden = true
            recordingLabel.toggleFade(duration: 0.1)
            cancelRecording.toggleFade(duration: 0.1)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stoppedRecording") {
            let playSoundVC:ShareSoundViewController = segue.destinationViewController as! ShareSoundViewController
            let data = sender as! RecordedAudio
            playSoundVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        sender.hidden = true
        startRecording.hidden = false
        recordingLabel.toggleFade(duration: 0.1)
        view.backgroundColor = UIColor.greenBgColor()
        cancelRecording.toggleFade(duration: 0.1)
    }
    
    @IBAction func cancelRecording(sender: UIButton) {
        audioRecorder.prepareToRecord()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        sender.toggleFade(duration: 0.1)
        stopRecording.hidden = true
        startRecording.hidden = false
        recordingLabel.toggleFade(duration: 0.1)
        view.backgroundColor = UIColor.greenBgColor()
    }
}

