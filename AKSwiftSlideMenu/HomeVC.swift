import Foundation
import UIKit
import MapKit
import CoreLocation


class HomeVC: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var coordinates: [[Double]]!
    var names:[String]!
    var addresses:[String]!
    var phones:[String]!
    
    func callPhoneNumber(sender: UIButton)
    {
        let v = sender.superview as! CustomCalloutView
        if let url = URL(string: "telprompt://\(v.starbucksPhone.text!)"), UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.openURL(url)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        // 1
        coordinates = [[53.521436, -113.487262],[53.53436, -113.487262],[53.521436, -113.497262]]// Latitude,Longitude
        names = ["Coffee Shop · Rue de Rivoli","Cafe · Boulevard Saint-Germain","Coffee Shop · Rue Saint-André des Arts"]
        addresses = ["46 Rue de Rivoli, 75004 Paris, France","91 Boulevard Saint-Germain, 75006 Paris, France","62 Rue Saint-André des Arts, 75006 Paris, France"]
        phones = ["+33144789478","+33146345268","+33146340672"]
        self.mapView.delegate = self
        // 2
        for i in 0...2
        {
            let coordinate = coordinates[i]
            let point = CustomPin(coordinate: CLLocationCoordinate2D(latitude: coordinate[0] , longitude: coordinate[1] ))
            point.image = UIImage(named: "splashScreen")
            point.name = names[i]
            point.address = addresses[i]
            point.phone = phones[i]
            self.mapView.addAnnotation(point)
        }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.521436, longitude: -113.487262), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
    }
    
    
    var point:CustomPin!
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        if point != nil {
            self.mapView.removeAnnotation(point)
        }
        let latestLocation: CLLocation = locations[locations.count - 1]
        point = CustomPin(coordinate: CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude , longitude:latestLocation.coordinate.longitude ))
        point.image = UIImage(named: "splashScreen")
//        self.mapView.addAnnotation(point)

    }
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "locationPin")
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView,didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let starbucksAnnotation = view.annotation as! CustomPin
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.starbucksName.text = starbucksAnnotation.name
        calloutView.starbucksAddress.text = starbucksAnnotation.address
        calloutView.starbucksPhone.text = starbucksAnnotation.phone
        
        //
        let button = UIButton(frame: calloutView.starbucksPhone.frame)
        button.addTarget(self, action: #selector(HomeVC.callPhoneNumber(sender:)), for: .touchUpInside)
        calloutView.addSubview(button)
        calloutView.starbucksImage.image = starbucksAnnotation.image
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    @IBOutlet weak var picture: UIImageView!
    
      

}
