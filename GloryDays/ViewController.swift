//
//  ViewController.swift
//  GloryDays
//
//  Created by Jorge Eduardo on 17/08/17.
//  Copyright © 2017 Jorge Eduardo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func askForPermission(_ sender: UIButton) {
        self.askForPhotosPermission()
    }
    
    func askForPhotosPermission(){
        PHPhotoLibrary.requestAuthorization { [unowned self](authStatus) in
            
            DispatchQueue.main.async {
                switch authStatus {
                    
                case .authorized:
                    self.askForRecordPermission()
                    
                case .denied:
                    self.showDialog(title: "Glory Days", message: "Please go to your device settings to enable permission for this app.")
                    
                case .notDetermined:
                    self.showDialog(title: "Glory Days", message: "Please go to your device settings to enable permission for this app.")
                    
                default:
                    break
                    
                }
            }
            
        }
    }
    
    func askForRecordPermission(){
        
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self](allowed) in
            DispatchQueue.main.async {
                switch allowed {
                case true :
                    self.askForTranscriptionPermission()
                case false:
                    self.showDialog(title: "Glory Days", message: "Please go to your device settings to enable permission for this app.")
                }
            }
        }
        
    }
    
    func askForTranscriptionPermission(){
        
        SFSpeechRecognizer.requestAuthorization { [unowned self](authStatus) in
            
            DispatchQueue.main.async {
                
                switch authStatus {
                case .authorized:
                    self.authorizationComplete()
                case .denied:
                    self.showDialog(title: "Glory Days", message: "Please go to your device settings to enable permission for this app.")
                case .notDetermined:
                    self.showDialog(title: "Glory Days", message: "Please go to your device settings to enable permission for this app.")
                default:
                    break
                }
                
            }
            
        }
        
    }
    
    func authorizationComplete(){
        dismiss(animated: true, completion: nil)
        
    }
    
    func showDialog(title: String?, message : String?){
        
        if let title = title, let message = message {
            let alertController : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            showDialog(title: "Glory Days", message: "Something went terribly wrong")
        }
        
    }
    
}

