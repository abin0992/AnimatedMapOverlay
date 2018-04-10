//
//  ViewController.swift
//  maptest
//
//  Created by Abin Baby on 05/04/2018.
//  Copyright © 2018 Abin Baby. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var arrowDirection: CLLocationDirection!
    let arrowImage: UIImage = #imageLiteral(resourceName: "arrow")
    var visibleOverlayLayer: Int = 0
    var overlay: MapOverlay!
    var timer = Timer()
    let coordinates = [
        CLLocationCoordinate2DMake(50.41880, 20.49000),
        CLLocationCoordinate2DMake(55.76105, 10.14051)
    ]
    
    let helperClass = HelperClass()
    var pointsCoordinates1: [CLLocationCoordinate2D] = []
    var pointsCoordinates2: [CLLocationCoordinate2D] = []
    var pointsCoordinates3: [CLLocationCoordinate2D] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up map view
        mapView.centerCoordinate = CLLocationCoordinate2DMake(51.107, 17.0385)
        let span = MKCoordinateSpanMake(18.075, 18.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.107, longitude: 17.0385), span: span)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        
        // Draw Polyline
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlays([polyline])
        
        //Direction of Polyline
        arrowDirection = helperClass.calculateDirectionOfpolyline(coordinates: coordinates)
        
        //Add overlay
        addLayersOfAnimatingOverlay()
        
        // Call function to change alpha value
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.toggle), userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: View of Overlay
    //Overlay View
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MapOverlay {
            let angle: CGFloat = helperClass.DegreesToRadians(degrees: Double(arrowDirection))
            let overlayView = MapOverlayView(overlay: overlay, overlayImage: arrowImage, angle: angle)
            return overlayView
        }
        else {
            guard let polyline = overlay as? MKPolyline else {
                fatalError("Not a MKPolyline")
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            renderer.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            renderer.lineWidth = 5
            renderer.alpha = 0.5
            return renderer
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        for renderer in renderers {
            if renderer is MapOverlayView {
                renderer.alpha = 0.0
            }
        }
    }
    
    
    // Toggle alpha value of MKOverlayRenderer
    @objc func toggle() {
        switch visibleOverlayLayer {
        case 1:
            visibleOverlayLayer = 2
            changeAlphaValue(identifier: "1")
        case 2:
            visibleOverlayLayer = 3
            changeAlphaValue(identifier: "2")
        case 3:
            visibleOverlayLayer = 1
            changeAlphaValue(identifier: "3")
        default:
            changeAlphaValue(identifier: "0")
        }
    }

    func changeAlphaValue(identifier: String) {
        let overlays = self.mapView.overlays
        let tag: String = identifier
        for overlay in overlays {
            if let overlay = overlay as? MapOverlay {
                let identifier = overlay.identifier
                if identifier == tag {
                    let renderer = mapView.renderer(for: overlay)
                    DispatchQueue.main.async{
                        renderer?.alpha = 1.0
                    }
                }
                else {
                    let renderer = mapView.renderer(for: overlay)
                    DispatchQueue.main.async{
                        renderer?.alpha = 0.0
                    }
                }
            }
        }
    }
    
    
    // Add first overlays to map
    func addLayersOfAnimatingOverlay() {
        let sourcePoint = helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: coordinates.first!)
        let destinationPoint =  helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: coordinates.last!)
        pointsCoordinates1 = self.getLocationArrayFrom(startLocation: sourcePoint, endLocation: destinationPoint)
            //add overlay on above coordinates
        DispatchQueue.main.async{
            self.addDirectionOverlayInMap(locationArray: self.pointsCoordinates1, title: "1")
        }
       visibleOverlayLayer = 1
        
        let fromPoints = helperClass.getEquidistantPoints(startPoint: pointsCoordinates1[0], endPoint: pointsCoordinates1[1], numberOfPoints: 2)
        let lastTwoPoints = pointsCoordinates1.suffix(2)
        print(lastTwoPoints)
        let toPoints = helperClass.getEquidistantPoints(startPoint: lastTwoPoints.first!, endPoint: lastTwoPoints.last!, numberOfPoints: 2)
        let from2 = helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: fromPoints[0])
        let to2 = helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: toPoints[0])
        pointsCoordinates2  = self.getLocationArrayFrom(startLocation: from2, endLocation: to2)
        DispatchQueue.main.async{
            self.addDirectionOverlayInMap(locationArray: self.pointsCoordinates2, title: "2")
        }
        
        let from3 = helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: fromPoints[1])
        let to3 = helperClass.convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: toPoints[1])
        pointsCoordinates3  = self.getLocationArrayFrom(startLocation: from3, endLocation: to3)
        DispatchQueue.main.async{
            self.addDirectionOverlayInMap(locationArray: self.pointsCoordinates3, title: "3")
        }
    }

    //Add layers to map
    func getLocationArrayFrom(startLocation: CLLocation, endLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var coordinatesArray: [CLLocationCoordinate2D] = []
        if let points = helperClass.getPointsOnRoute(from: startLocation, to: endLocation, on: mapView) {
            for point in points {
                let coordinate  = point.coordinate
                coordinatesArray.append(coordinate)
            }
        }
        return coordinatesArray
    }
    
    // Add overlays to map
    func addDirectionOverlayInMap(locationArray: [CLLocationCoordinate2D], title: String){
        for pointsCoordinate in locationArray {
            let location = pointsCoordinate
            //1. Show direction Using Overlays
            let span = MKCoordinateSpanMake(1.0, 1.0)
            let region = MKCoordinateRegion(center: location, span: span)
            let mapRect: MKMapRect = helperClass.MKMapRectForCoordinateRegion(region: region)
            overlay = MapOverlay(identifier: title, coord: location, rect: mapRect)
            self.mapView.add(overlay)
        }
    }
}

