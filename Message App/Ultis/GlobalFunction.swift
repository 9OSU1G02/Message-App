//
//  GlobalFunction.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import Foundation
import AVFoundation
import UIKit
func fileNameFrom(fileUrl: String) -> String {
    /* https://firebasestorage.googleapis.com/v0/b/m3ssag3r-8c5fa.appspot.com/o/Avatars%2F_N8Y1H85cFLQ8XjuLefRnowNt1753.jpg?alt=media&token=7bc34e02-dc3e-479e-a791-3a2d4d28085d
     ---> N8Y1H85cFLQ8XjuLefRnowNt1753.jpg?alt=media&token=7bc34e02-dc3e-479e-a791-3a2d4d28085d
     ---> N8Y1H85cFLQ8XjuLefRnowNt1753.jpg
     ---> N8Y1H85cFLQ8XjuLefRnowNt1753
     */
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}


//Time has elapsed from date to current
func timeElapsed(_ date: Date) -> String {
    //Second Eplapsed since date
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    if seconds < 60 {
        elapsed = "Just now"
    }
    //How many minutes has passed
    else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) \(minText)"
    }
    //How many hour has passed
    else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) \(hourText)"
    }
    //The day message was send
    else {
        elapsed = date.longDate()
    }
    return elapsed
}

//Create thumbnail from video
func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    //time take screenshot of video
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var image: CGImage?
    do {
        //get image from time at 0.5s of video
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print("error making thumbnail", error.localizedDescription)
    }
    if let image = image {
        return UIImage(cgImage: image)
    }
    return UIImage(systemName: "video.bubble.left")!
}
