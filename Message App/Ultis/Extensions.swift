//
//  Extensions.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation
import UIKit
import ProgressHUD
import MapKit
import SafariServices
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
    
    func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func backgroundTap() {
        //Disable all keyboard for any view that has currently called the keyboard
        view.endEditing(false)
    }
    
    func presentSafariVC(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true, completion: nil)
    }
    
}

extension UIImage {
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    //Create Circle Image
    var circleMasked: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension Date {
    //Return String Represent Date
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    //Return String contain Hour and minute of input date
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }
    
    
    //How many time passed
    func interval(ofComponent comp: Calendar.Component, from date: Date) -> Float {
        //gregorian calendar
        let currentCalender = Calendar.current
        guard let start = currentCalender.ordinality(of: comp, in: .era, for: self) else {
            return 0
        }
        guard let end = currentCalender.ordinality(of: comp, in: .era, for: date) else {
            return 0
        }
        return Float(end - start)
    }
    
}


let MERCATOR_OFFSET = 268435456.0
let MERCATOR_RADIUS = 85445659.44705395
let DEGREES = 180.0
//Set initial zoom level of MapView
public extension MKMapView {
    
    //MARK: Map Conversion Methods
    
    private func longitudeToPixelSpaceX(longitude:Double)->Double{
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / DEGREES)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double)->Double{
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / DEGREES)) / (1 - sin(latitude * Double.pi / DEGREES))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double)->Double{
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * DEGREES / Double.pi
    }
    
    private func pixelSpaceYToLatitude(pixelY:Double)->Double{
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * DEGREES / Double.pi
    }
    
    private func coordinateSpanWithCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double)->MKCoordinateSpan{
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        print(centerCoordinate)
        // determine the scale value from the zoom level
        let zoomExponent:Double = 20.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2.0)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2.0)
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1.0 * (maxLat - minLat)
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    /**
     Sets the center of the `MKMapView` to a `CLLocationCoordinate2D` with a custom zoom-level. There is no nee to set a region manually. :-)
     
     - author: Mylene Bayan (on GitHub)
     */
     func setCenter(_ coordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool){
        // clamp large numbers to 28
        var zoomLevel = zoomLevel
        zoomLevel = min(zoomLevel, 28)
        // use the zoom level to compute the region
        print(coordinate)
        let span = self.coordinateSpanWithCenterCoordinate(centerCoordinate: coordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        if region.center.longitude == -180.00000000{
            print("Invalid Region")
        }
        else{
            self.setRegion(region, animated: animated)
        }
    }
}
