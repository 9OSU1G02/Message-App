//
//  MapViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController {
    // MARK: - Properties
    var location: CLLocation?
    var mapView: MKMapView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureTitle()
        configureLeftBarButton()
    }
    
    // MARK: - Configurations
    private func configureMapView() {
        //MapView have size entail screen
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            //Set center of MapView is user location
            mapView.setCenter(location!.coordinate, zoomLevel: 17, animated: true)
            //add annotation
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
        }
        view.addSubview(mapView)
    }
    private func configureLeftBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left"), style: .done, target: self, action: #selector(backButtonPressed))
    }
    private func configureTitle() {
        self.title = "Map View"
    }
    
    // MARK: - Actions
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
