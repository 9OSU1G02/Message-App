//
//  VideoMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/31/20.
//

import Foundation
import MessageKit
class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    override init() {
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 200, height: 200)
    }
}
