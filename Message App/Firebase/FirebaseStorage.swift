//
//  Filestorage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import Foundation
import FirebaseStorage
import ProgressHUD
class FileStorage {
    // MARK: - Image
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void ) {
        //Reference to FireStorage
        let storageRef = Storage.storage().reference(forURL: FIREBASE_STORAGE_REFERENCE).child(directory)
        //Convert UIImage to Data (for upload to FireStorage)
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!,metadata: nil,completion: { (metaData, error) in
            //As soon as we upload it, remove all observers so we are not notified about any changes to file just uploads
            task.removeAllObservers()
            //Dismiss showProgress
            ProgressHUD.dismiss()
            if let error = error {
                print("error wihle upload image,",error.localizedDescription)
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                //Provide the link where file was saved
                completion(downloadURL.absoluteString)
            }
        })
        // We want observer StorageTaskStatus.progress: progress upload file
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount)
            ProgressHUD.colorProgress = UIColor(named: "progress")!
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl: String, competion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        //If image in locally then don't have to download from Firebase
        if fileExistAtPath(path: imageFileName) {
            // get data locally and convert to UIImage
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentsDicrectory(fileName: imageFileName)) {
                competion(contentOfFile)
            }
            else {
                competion(UIImage(named: "Messenger"))
            }
        }
        else {
            // download from FB
                if imageUrl != "" {
                let documentURL = URL(string: imageUrl)
                //Background Queue
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    //take whatever is in documentURL and create a data from it
                    let data = NSData(contentsOf: documentURL!)
                    if let data = data {
                        //Save locally so next time we don't need to redownload it
                        FileStorage.saveFileLocally(fileData: data, fileName: imageFileName)
                        DispatchQueue.main.async {
                            competion(UIImage(data: data as Data))
                        }
                    } else {
                        DispatchQueue.main.async {
                            competion(nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK:  Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        //(e.g: C:\Document )
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        
        //file not folder -> isDirectory: false
        let docURL = documentURL.appendingPathComponent(fileName,isDirectory: false)
        
        //atomically: true -> Create temp file, if everything was succesfully it's just going to replace the old file
        fileData.write(to: docURL, atomically: true)
    }
}

// MARK: - Helpers

func fileInDocumentsDicrectory(fileName: String) -> String {
    //Return documentary where we save file locally (e.g: C:\Document )
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    // C:\Document\filename
    return documentURL.appendingPathComponent(fileName).path
}

func fileExistAtPath(path: String) -> Bool {
    let filePath = fileInDocumentsDicrectory(fileName: path)
    return FileManager.default.fileExists(atPath: filePath)
}
