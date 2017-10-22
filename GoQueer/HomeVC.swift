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
    var myGalleries:[QGallery] = []
    var names1: [String] = []
    var contacts: [String] = []
    var currentCoordinate:CLLocationCoordinate2D!
    var timer = Timer()
    var myPins:[CustomPin]!
    var selectedLocationId : Int = 0
//    public static let baseUrl = "http://206.167.180.114/"
    public static let baseUrl = "http://localhost:8000/"
    
    
//    func callPhoneNumber(sender: UIButton)
//    {
//        let v = sender.superview as! CustomCalloutView
//        if let url = URL(string: "telprompt://\(v.starbucksPhone.text!)"), UIApplication.shared.canOpenURL(url)
//        {
//            UIApplication.shared.openURL(url)
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        scheduledTimerWithTimeInterval()
        updateLocations()
        self.mapView.delegate = self
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.521436, longitude: -113.487262), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
    }
    
   
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.updateLocations), userInfo: nil, repeats: true)
    }
   
    @objc func updateLocations(){
        if let url = URL(string: HomeVC.baseUrl + "/client/getAllLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfileName()) {
            do {
                let contents = try String(contentsOf: url)
                allLocations = []
                allLocations = parseLocations(contents)
                if let url = URL(string: HomeVC.baseUrl + "/client/getMyLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfileName()) {
                    do {
                        let contents = try String(contentsOf: url)
                        myLocations = []
                        myLocations = parseLocations(contents)
                        let allAnnotations = self.mapView.annotations
                        self.mapView.removeAnnotations(allAnnotations)
                        for myLocation in myLocations {
                            if myLocation.type == "Point" {
                                let point = CustomPin(coordinate: CLLocationCoordinate2D(latitude: Double(myLocation.getLat())! , longitude: Double(myLocation.getlong())! ))
                                point.name = myLocation.name
                                point.id = myLocation.id
                                point.address = myLocation.address
                                point.myDescription = myLocation.description
    //                            point.image = UIImage(named: "splashScreen")
                                let imageURL = URL(string: HomeVC.baseUrl + "client/downloadMediaById?media_id=" + String(findCoverPicture(galleryId: myLocation.galleryId)) )
                                fetchImageFromURL(imageURL: imageURL!, point: point)

                                self.mapView.addAnnotation(point)
                                var flag = false
                                for gallery in myGalleries {
                                    if gallery.id == myLocation.galleryId{
                                        flag = true
                                    }
                                }
                                if (!flag) {
                                    if let url = URL(string: HomeVC.baseUrl + "client/getGalleryById?gallery_id=" + String(myLocation.galleryId)) {
                                        do {
                                            let contents = try String(contentsOf: url)
                                            myGalleries.append(parseGallery(contents,galleryId: myLocation.galleryId))
                                            
                                        }
                                    }

                                }
                            }
                        }
                        
                        
                    } catch {
                        
                    }
                }
            } catch {
                
            }
        }
    
    }
    func findCoverPicture(galleryId: Int) -> Int {
        for gallery in myGalleries {
            if gallery.id ==  galleryId && gallery.media.count > 0 {
                return gallery.media[0].id
            }
        }
        return 0
    }
    
    func fetchImageFromURL(imageURL: URL, point: CustomPin)   {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: imageURL as URL)
            // Display about the actual image
            DispatchQueue.main.async {
                if let imageData = fetch {
                    point.image =   UIImage(data: imageData as Data)
                }
            }
        }
    }


    func parseGallery(_ input:String, galleryId: Int) -> QGallery {
        let qGallery = QGallery()
        var result = input.components(separatedBy: ",\"")
        qGallery.id = Int(result[0].components(separatedBy: ":")[1])!
        qGallery.name = result[1].components(separatedBy: "name\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        qGallery.description = result[2].components(separatedBy: "description\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        
        if let url = URL(string: HomeVC.baseUrl + "client/getGalleryMediaById?gallery_id=" + String(galleryId)) {
            do {
                let contents = try String(contentsOf: url)
                if (contents != "[]"){
                    qGallery.media = parseMedias(contents)
                    print()
                }
                
            }catch {
                
            }
        }
        ///
        return qGallery
    }
        
        
    func parseMedias(_ input:String) -> [QMedia]{
        var qMedidas:[QMedia] = []
        let qMedia = QMedia()
        let rows = input.components(separatedBy: "},{")
        for row in rows {
            var myresult = row.components(separatedBy: ",\"")
            qMedia.id = Int(myresult[0].components(separatedBy: ":")[1])!
            qMedia.source = myresult[1].components(separatedBy: "source\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qMedia.name = myresult[2].components(separatedBy: "name\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qMedia.description = myresult[3].components(separatedBy: "description\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qMedia.displayDate = myresult[5].components(separatedBy: "display_date\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qMedia.typeId = Int( myresult[6].components(separatedBy: "type_id\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil).replacingOccurrences(of: "}", with: "", options: .literal, range: nil).replacingOccurrences(of: "]", with: "", options: .literal, range: nil) )!
            qMedidas.append(qMedia)
        }
        return qMedidas
    }

    
    
   
    
    
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        currentCoordinate = manager.location!.coordinate
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
            
            let type = location.coordinate?.components(separatedBy: "type:")[2]
            let index = type?.index((type?.startIndex)!, offsetBy: 5)
            location.type = type?.substring(to: index!)
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
        calloutView.id = starbucksAnnotation.id
        selectedLocationId = calloutView.id
        //
        let button = UIButton(frame: calloutView.starbucksPhone.frame)
//        button.addTarget(self, action: #selector(HomeVC.callPhoneNumber(sender:)), for: .touchUpInside)
        calloutView.addSubview(button)
        calloutView.starbucksImage.image = starbucksAnnotation.image
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
        calloutView.addGestureRecognizer(gestureRec)
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        var resultGallery = QGallery()
        for location in myLocations {
            if location.id == selectedLocationId {
                for gallery in myGalleries {
                    if gallery.id == location.galleryId {
                        resultGallery = gallery
                    }
                }
            }
        }
        PlayVC.myGallery = resultGallery
        performSegue(withIdentifier: "gallerySegue", sender: self)
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
