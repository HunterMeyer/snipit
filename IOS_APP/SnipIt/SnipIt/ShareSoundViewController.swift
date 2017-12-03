//
//  ShareSoundViewController.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/7/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftHTTP

class ShareSoundViewController: UIViewController {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var receivedAudio: RecordedAudio!
    let httpHelper = HTTPHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowSound(sender: UIButton) {
        audioEngine.stop()
        audioPlayer.togglePlayBack(0.5)
    }

    @IBAction func playFastSound(sender: UIButton) {
        audioEngine.stop()
        audioPlayer.togglePlayBack(1.8)
    }
    
    @IBAction func playChipSound(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.playAudioWithVariablePitch(1000, audioFile: audioFile)
    }
    
    @IBAction func playDarthSound(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.playAudioWithVariablePitch(-1000, audioFile: audioFile)
    }
    
    @IBAction func playNormalSound(sender: UIButton) {
        audioEngine.stop()
        audioPlayer.togglePlayBack(1.0)
    }
    
    @IBAction func uploadSound(sender: UIButton) {
        uploadButton.hidden = true
        activityIndicator.hidden = false
        let fileUrl = receivedAudio.filePathUrl
        var request = HTTPTask()
        let userToken : NSString? = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService")
        request.requestSerializer = HTTPRequestSerializer()
        request.requestSerializer.headers["Authorization"] = "Token token=\(userToken!)"
        request.POST("https://snipitapp.herokuapp.com/api/upload_snippet", parameters:  ["audio": HTTPUpload(fileUrl: fileUrl!)], success: {(response: HTTPResponse) in
                let recordView: RecordSoundViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RecordSoundViewController") as! RecordSoundViewController
                self.navigationController?.pushViewController(recordView, animated: false)
            },failure: {(error: NSError, response: HTTPResponse?) in
                self.displayAlertMessage("Error", alertDescription: error.localizedDescription)
                self.uploadButton.hidden = false
        })
    }
    
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        let errorAlert: UIAlertController = UIAlertController(title: alertTitle as String, message: alertDescription as String, preferredStyle: .Alert)
        let cancelAlert: UIAlertAction = UIAlertAction(title: "Got it", style: .Cancel) { action -> Void in }
        errorAlert.addAction(cancelAlert)
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
