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
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 240, height: 240)
    }
}
