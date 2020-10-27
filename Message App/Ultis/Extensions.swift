//
//  Extensions.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation
import UIKit
import ProgressHUD
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superViewTopAnchor = superview?.topAnchor,
              let superViewBotAnchor = superview?.bottomAnchor,
              let superViewLeadingAnchor = superview?.leadingAnchor,
              let superViewTrailingAnchor = superview?.trailingAnchor
        else {
            return
        }
        anchor(top: superViewTopAnchor, left: superViewLeadingAnchor , bottom: superViewBotAnchor, right: superViewTrailingAnchor)
    }
}

extension UITextField {
    func configTextField(leftTextfieldImage: UIImageView) {
        
        //Create space on the left and right inside TextFiled
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 40)
        //display on the left side (or trailing) of textField
        leftView = spacer
        
        let leftImage = leftTextfieldImage
        leftImage.alpha = 0.5
        leftImage.setDimensions(height: 15, width: 22)
        leftView?.addSubview(leftImage)
        leftImage.centerY(inView: leftView!)
        leftImage.anchor(left: leftView?.leftAnchor,paddingLeft: 10)
        //allwas display no matter what
        leftViewMode = .always
        backgroundColor = UIColor(white: 1, alpha: 0.05)
        keyboardAppearance = .dark
        //placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [.foregroundColor : UIColor(white: 1, alpha: 0.5)])
    }
}

extension UIViewController {
   
    
    
    
}
