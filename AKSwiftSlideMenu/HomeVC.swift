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
    var allLocations:[QLocation] = []
    var myLocations:[QLocation] = []
    var names1: [String] = []
    var contacts: [String] = []
    
    static let baseUrl = "http://206.167.180.114/"
    
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
    
    
    
    
    func showToast(message : String) {
            
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
    }
    
    
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if let url = URL(string: HomeVC.baseUrl + "/client/getAllLocations?device_id=1") {
            do {
                let contents = try String(contentsOf: url)
                allLocations = []
                allLocations = parseLocations(contents)
                compareCoordinates(all: allLocations, my: locValue)
            } catch {
                
            }
        } else {
        }
    }
    func compareCoordinates(all: [QLocation], my: CLLocationCoordinate2D) {
        for locationFromAll in all {
                if  locationFromAll.getType() == "Point" {
                    
                    let coordinate0 = CLLocation(latitude: my.latitude, longitude: my.longitude)
                    let coordinate1 = CLLocation(latitude: Double(locationFromAll.getLat())!, longitude: Double(locationFromAll.getlong())!)

                    let distanceInMeters = coordinate0.distance(from: coordinate1) // result is in meters
                    if distanceInMeters < 50 {
                        showToast(message: "You have discovered something!")
                    }
                }
        }
    }
    
    
    
    func parseLocations(_ input:String) -> [QLocation]
    {
        var all:[QLocation] = []
        var rows = input.components(separatedBy: "\"id\":")
        rows.remove(at: 0);
        for row in rows {
            var data = row.components(separatedBy: ",\"")
            let location = QLocation()
            location.id = Int(data[0])!
            let coordinate = data[3].components(separatedBy: "coordinate\":")[1]
            location.coordinate = coordinate.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
                .replacingOccurrences(of: "\\" , with: "", options: .literal, range: nil)
            let name = data[4].components(separatedBy: "name\":")[1]
            location.name = name.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            let description = data[5].components(separatedBy: "description\":")[1]
            location.description = description.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            let address = data[6].components(separatedBy: "address\":")[1]
            location.address = address.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            location.userId = Int(data[7].components(separatedBy: "user_id\":")[1])!
            location.galleryId = Int(data[8].components(separatedBy: "gallery_id\":")[1].components(separatedBy: "}")[0])!
            all.append(location)
        }
        return all
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
