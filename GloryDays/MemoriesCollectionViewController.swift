//
//  MemoriesCollectionViewController.swift
//  GloryDays
//
//  Created by Jorge Eduardo on 17/08/17.
//  Copyright © 2017 Jorge Eduardo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

private let reuseIdentifier = "collectionCell"

class MemoriesCollectionViewController: UICollectionViewController,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate {
    
    var memories : [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMemories()
        
        //adding a new right button into navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier) //to register the king of cell that we will use

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForGrantedPermission()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func checkForGrantedPermission(){
        
        let photoAuth : Bool = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuth : Bool = AVAudioSession.sharedInstance().recordPermission() == .granted
        let transcriptionAuth : Bool = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photoAuth && recordingAuth && transcriptionAuth
        
        if !authorized {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "RequestPermission"){
                navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }

    func loadMemories(){
        self.memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        for file in files {
            
            let fileName = file.lastPathComponent
            
            if fileName.hasSuffix(".thumb"){
                let noExtension = fileName.replacingOccurrences(of: ".thumb", with: "")
                let memoryPath = getDocumentsDirectory().appendingPathComponent(noExtension)
                memories.append(memoryPath)
            }
        }
        if (collectionView?.numberOfSections)! > 0 {
            collectionView?.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func addButtonPressed(){
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func addNewMemory(image : UIImage){
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        let imageName = "\(memoryName).jpg"
        let thumbName = "\(memoryName).thumb"
        
        do {
            let imagePath =  self.getDocumentsDirectory().appendingPathComponent(imageName)
            
            if let jpegData = UIImageJPEGRepresentation(image, 80.0) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            if let thumbnail = resizeImage(image: image, toWidth: 200.0){
                let thumbPath = self.getDocumentsDirectory().appendingPathComponent(thumbName)
                
                if let thumbData = UIImageJPEGRepresentation(thumbnail, 80.0){
                    try thumbData.write(to: thumbPath, options: [.atomicWrite])
                }
                
            }
            
        }catch{
            print("Something went terribly wrong while storing the images")
        }
    }
    
    func resizeImage(image: UIImage, toWidth : CGFloat) -> UIImage?{
        let scaleFactor = toWidth / image.size.width
        let newHeight = image.size.height * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: toWidth, height : newHeight), false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: toWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageUrl (for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailUrl (for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    func audioUrl (for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }
    
    func transcriptionUrl (for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let theImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.addNewMemory(image: theImage)
            self.loadMemories()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            return 0
        } else {
            return self.memories.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemoryCell
        
        let memory = self.memories[indexPath.row]
        let memoryName = self.thumbnailUrl(for: memory).path
        let image = UIImage(contentsOfFile: memoryName)
        cell.imageView.image = image
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath)
        
        return header
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: 0, height: 50)
        }else {
            return CGSize.zero
        }
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
