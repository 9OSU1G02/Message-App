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
        let imageData = image.jpegData(compressionQuality: 0.3)
        
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!,metadata: nil,completion: { (metaData, error) in
            //As soon as we upload it, remove all observers so we are not notified about any changes to file just uploads and dissmiss progress
            task.removeAllObservers()
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
        #warning("bug ather user will not get latest avatar of current user because avatar file name == user id --> another user locally have avatar image with same name ---> remove fileExistAtPath ")
        //If image in locally then don't have to download from Firebase
        if fileExistAtPath(path: imageFileName) {
            // get data locally and convert to UIImage
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentsDicrectory(fileName: imageFileName)) {
                competion(contentOfFile)
            }
            else {
                competion(UIImage(named: "avatar"))
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
    
    
    class func downloadImageWithOutCheckForLocal(imageUrl: String, competion: @escaping (_ image: UIImage?) -> Void) {
        if imageUrl != "" {
            let imageFileName = fileNameFrom(fileUrl: imageUrl)
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
        else {
            return
        }
    }
    
    // MARK: - Video
    class func downloadVideo(videoLink: String, competion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mp4"
        //If video in locally then don't have to download from Firebase
        if fileExistAtPath(path: videoFileName) {
            competion(true,videoFileName)
        }
        // download video from fb
        else {
            //Background Queue
            let videoDownloadQueue = DispatchQueue(label: "videoDownloadQueue")
            videoDownloadQueue.async {
                //take whatever is in documentURL(here is mp4 video) and create a data from it
                let data = NSData(contentsOf: videoUrl!)
                if let data = data {
                    //Save video locally so next time we don't need to redownload it
                    FileStorage.saveFileLocally(fileData: data, fileName: videoFileName)
                    DispatchQueue.main.async {
                        competion(true, videoFileName)
                    }
                } else {
                    print("no document in database")
                }
            }
        }
    }
    
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void ) {
        //Reference to FireStorage
        let storageRef = Storage.storage().reference(forURL: FIREBASE_STORAGE_REFERENCE).child(directory)
        //Convert UIImage to Data (for upload to FireStorage)
        
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data,metadata: nil,completion: { (metaData, error) in
            //As soon as we upload it, remove all observers so we are not notified about any changes to file just uploads and dissmiss progress
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if let error = error {
                print("error uploading video \(error.localizedDescription)")
                return
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
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    // MARK: - Audio
    class func downloadAudio(audioLink: String, competion: @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        //If video in locally then don't have to download from Firebase
        if fileExistAtPath(path: audioFileName) {
            competion(audioFileName)
        }
        // download video from fb
        else {
            //Background Queue
            let audioDownloadQueue = DispatchQueue(label: "imageDownloadQueue")
            audioDownloadQueue.async {
                //take whatever is in documentURL(here is mp4 video) and create a data from it
                let data = NSData(contentsOf: URL(string: audioLink)!)
                if let data = data {
                    //Save video locally so next time we don't need to redownload it
                    FileStorage.saveFileLocally(fileData: data, fileName: audioFileName)
                    DispatchQueue.main.async {
                        competion(audioFileName)
                    }
                } else {
                    print("no document in database")
                }
            }
        }
    }
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void ) {
        let fileName = audioFileName + ".m4a"
        //Reference to FireStorage
        let storageRef = Storage.storage().reference(forURL: FIREBASE_STORAGE_REFERENCE).child(directory)
        //Convert UIImage to Data (for upload to FireStorage)
        
        var task: StorageUploadTask!
        //Check if have audio file in locally
        if fileExistAtPath(path: fileName) {
            //Convert audio file to nsData to upload on Firebase
            if let audioData = NSData(contentsOfFile: fileInDocumentsDicrectory(fileName: fileName)) {
                task = storageRef.putData(audioData as Data,metadata: nil,completion: { (metaData, error) in
                    //As soon as we upload it, remove all observers so we are not notified about any changes to file just uploads
                    task.removeAllObservers()
                    //Dismiss showProgress
                    ProgressHUD.dismiss()
                    if let error = error {
                        print("error uploading audio \(error.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            completion(nil)
                            return
                        }
                        //Provide the link where file was saved on firebase
                        completion(downloadURL.absoluteString)
                    }
                })
                // We want observer StorageTaskStatus.progress: progress upload file
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    let progress = Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount)
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            }
            else {
                print("nothing to upload audio")
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
