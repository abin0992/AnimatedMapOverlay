//
//  HelperClass.swift
//  maptest
//
//  Created by Abin Baby on 09/04/2018.
//  Copyright © 2018 Abin Baby. All rights reserved.
//

import Foundation
import MapKit
import UIKit

 class HelperClass {
    
    //MARK: get cordinates from line
    func getPointsOnRoute(from: CLLocation?, to: CLLocation?, on mapView: MKMapView?) -> [CLLocation]? {
        let NUMBER_OF_PIXELS_TO_SKIP: Int = 120
        //lower number will give a more smooth animation, but will result in more layers
        var ret = [Any]()
        
        var fromPoint: CGPoint? = nil
        if let aCoordinate = from?.coordinate {
            fromPoint = mapView?.convert(aCoordinate, toPointTo: mapView)
        }
        var toPoint: CGPoint? = nil
        if let aCoordinate = to?.coordinate {
            toPoint = mapView?.convert(aCoordinate, toPointTo: mapView)
        }
        let allPixels = getAllPoints(from: fromPoint!, to: toPoint!)
        var i = 0
        while i < (allPixels?.count)! {
            let pointVal = allPixels![i] as? NSValue
            ret.append(point(toLocation: mapView, from: (pointVal?.cgPointValue)!)!)
            i += NUMBER_OF_PIXELS_TO_SKIP
        }
        ret.append(point(toLocation: mapView, from: toPoint!)!)
        return ret as? [CLLocation]
    }
    
    
    /**convert a CGPoint to a CLLocation according to a mapView*/
    func point(toLocation mapView: MKMapView?, from fromPoint: CGPoint) -> CLLocation? {
        let coord: CLLocationCoordinate2D? = mapView?.convert(fromPoint, toCoordinateFrom: mapView)
        return CLLocation(latitude: coord?.latitude ?? 0, longitude: coord?.longitude ?? 0)
    }
    
    func getAllPoints(from fPoint: CGPoint, to tPoint: CGPoint) -> [Any]? {
        /*Simplyfied implementation of Bresenham's line algoritme */
        var ret = [AnyHashable]()
        let deltaX: Float = fabsf(Float(tPoint.x - fPoint.x))
        let deltaY: Float = fabsf(Float(tPoint.y - fPoint.y))
        var x: Float = Float(fPoint.x)
        var y: Float = Float(fPoint.y)
        var err: Float = deltaX - deltaY
        var sx: Float = -0.5
        var sy: Float = -0.5
        if fPoint.x < tPoint.x {
            sx = 0.5
        }
        if fPoint.y < tPoint.y {
            sy = 0.5
        }
        repeat {
            ret.append(NSValue(cgPoint: CGPoint(x: CGFloat(x), y: CGFloat(y))))
            let e: Float = 2 * err
            if e > -deltaY {
                err -= deltaY
                x += sx
            }
            if e < deltaX {
                err += deltaX
                y += sy
            }
        } while round(Float(x)) != round(Float(tPoint.x)) && round(Float(y)) != round(Float(tPoint.y))
        ret.append(NSValue(cgPoint: tPoint))
        //add final point
        return ret
    }
    
    // MARK: direction of image annotation
    func DirectionBetweenPoints(previousMapPoint: MKMapPoint, nextMapPoint: MKMapPoint) -> CLLocationDirection {
        let x: Double = nextMapPoint.x - previousMapPoint.x
        let y: Double = nextMapPoint.y - previousMapPoint.y
        
        return fmod(RadiansToDegrees(radians: atan2(y, x)), 360.0)
    }
    
    func RadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    func DegreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * .pi / 180.0)
    }
    
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let a = MKMapPointForCoordinate(topLeft)
        let b = MKMapPointForCoordinate(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    open func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
        
        var x = 0.0 as CGFloat
        var y = 0.0 as CGFloat
        var z = 0.0 as CGFloat
        
        for coordinate in listCoords{
            
            let lat:CGFloat = DegreesToRadians(degrees: coordinate.latitude)
            let lon:CGFloat = DegreesToRadians(degrees: coordinate.longitude)
            
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon);
            z = z + sin(lat);
            
        }
        
        x = x/CGFloat(listCoords.count)
        y = y/CGFloat(listCoords.count)
        z = z/CGFloat(listCoords.count)
        
        let resultLon: CGFloat = atan2(y, x)
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        let resultLat:CGFloat = atan2(z, resultHyp)
        
        let newLat = RadiansToDegrees(radians: Double(resultLat))
        let newLon = RadiansToDegrees(radians: Double(resultLon))
        let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        return result
        
    }

    //Calculate direction of polyline
    func calculateDirectionOfpolyline(coordinates: [CLLocationCoordinate2D]) -> CLLocationDirection {
        let first: MKMapPoint = MKMapPointForCoordinate(coordinates.first!)
        let last: MKMapPoint = MKMapPointForCoordinate(coordinates.last!)
        let arrowDirection: CLLocationDirection = DirectionBetweenPoints(previousMapPoint: first, nextMapPoint: last)
        return arrowDirection
    }
    
    func convertCLLocationCoordinate2DToCLLocation(LocationCoordinates: CLLocationCoordinate2D) -> CLLocation {
        let fLat: CLLocationDegrees = LocationCoordinates.latitude
        let fLon: CLLocationDegrees = LocationCoordinates.longitude
        let location: CLLocation =  CLLocation(latitude: fLat, longitude: fLon)
        return location
    }
    
    func getEquidistantPoints(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D, numberOfPoints: Int) -> [CLLocationCoordinate2D] {
        
        var midPoints: [CLLocationCoordinate2D] = []
        var newPoint: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
        
        let count = numberOfPoints + 1

        let latitudeModifier = (endPoint.latitude - startPoint.latitude) / Double(count)
        let longitudeModifier = (endPoint.longitude - startPoint.longitude) / Double(count)
        
        // Loop through the points
        for i in 1..<count {
            newPoint.latitude = CLLocationDegrees(startPoint.latitude + (latitudeModifier * Double(i)))
            newPoint.longitude = CLLocationDegrees(startPoint.longitude + (longitudeModifier * Double(i)))
            midPoints.append(newPoint)
        }
        return midPoints
    }
}
