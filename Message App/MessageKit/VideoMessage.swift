//
//  VideoMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import MessageKit
class VideoMessage: NSObject, MediaItem {
    // The url where the media is located.
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(systemName: "video.bubble.left")!
        self.size = CGSize(width: 240, height: 240)
    }
}
