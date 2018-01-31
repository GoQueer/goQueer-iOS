import Foundation
import UIKit

import GoogleMaps
import CoreLocation



class MapController: BaseViewController, CLLocationManagerDelegate, SlideMenuDelegate {
    @IBOutlet  var mapView: GMSMapView!
    
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
    public static let baseUrl = "http://206.167.180.114/"
   // public static let baseUrl = "http://localhost:8000/"
    
    
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
        
        
        //this is our map view
        self.mapView = GMSMapView(frame: self.view.bounds)
        
        //adding mapview to view
        view = mapView
        
        //creating a marker on the map
        /*let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 23.431351, longitude: 85.325879)
        marker.title = "Ranchi, Jharkhand"
        marker.map = mapView*/
        
        
        
        addSlideMenuButton()
        scheduledTimerWithTimeIntervalForPullingData()
        scheduledTimerWithTimeIntervalForComparingCoordinates()
        updateLocations()
        
        if (  getProfileName() == "" ) {
            let alert = UIAlertController(title: "City", message: "Select your City", preferredStyle: .alert)
            if let url = URL(string: MapController.baseUrl + "/client/getAllProfiles") {
                do {
                    let contents = try String(contentsOf: url)
                    if (contents != ""){
                        
                        let profiles = parseProfiles(contents)
                        for profile in profiles {
                            alert.addAction(UIAlertAction(title: profile.name, style: .default, handler: { [weak alert] (_) in
                                let defaults = UserDefaults.standard
                                defaults.set(profile.name, forKey: defaultsKeys.keyOne)
                                
                                self.moveToRegion(profile: profile)
                                
                                
                            }))
                        }
                    }
                }
                catch {}
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            if let url = URL(string: MapController.baseUrl + "/client/getAllProfiles") {
                do {
                    let contents = try String(contentsOf: url)
                    if (contents != ""){
                        
                        let profiles = parseProfiles(contents)
                        for profile in profiles {
                            if (profile.name == getProfileName()){
                                self.moveToRegion(profile: profile)
                            }
                            
                        }
                    }
                }
                catch {}
            }
            
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
        
    }
    /*
    func mapView(mapView: GMSMapView, didSelectAnnotationView view: GSMapAnn) {
        
        let annotationTap = UITapGestureRecognizer(target: self, action: "tapRecognized")
        annotationTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(annotationTap)
        
        let selectedAnnotations = mapView.selectedAnnotations
        
        for annotationView in selectedAnnotations{
            mapView.deselectAnnotation(annotationView, animated: true)
        }
    }
    func tapRecognized(gesture:UITapGestureRecognizer){
        
        let selectedAnnotations = mapView.selectedAnnotations
        
        for annotationView in selectedAnnotations{
            mapView.deselectAnnotation(annotationView, animated: true)
        }
    }*/
    
    var radioButtonController: RadioButtonsController?
    func didSelectButton(selectedButton: UIButton?)
    {
        NSLog(" \(selectedButton)" )
    }
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        switch(index){
        case 0:
        
           
            //
            let alert = UIAlertController(title: "City", message: "Select your City", preferredStyle: .alert)
            if let url = URL(string: MapController.baseUrl + "/client/getAllProfiles") {
                do {
                    let contents = try String(contentsOf: url)
                    if (contents != ""){
                        
                        let profiles = parseProfiles(contents)
                        for profile in profiles {
                            alert.addAction(UIAlertAction(title: profile.name, style: .default, handler: { [weak alert] (_) in
                                let defaults = UserDefaults.standard
                                defaults.set(profile.name, forKey: defaultsKeys.keyOne)
                                self.moveToRegion(profile: profile)
                                
                                
                            }))
                        }
                    }
                }
                    catch {}
            }
        
            
            
         
            
            
            
          
            
            
            self.present(alert, animated: true, completion: nil)
 
    
            
            break
        case 1:
            print("Play\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
        case 6:
            
            if let url = URL(string: MapController.baseUrl + "/client/getHint?device_id=" + getDeviceId()+"&profile_name=" + getProfileName() ) {
                do {
                    let contents = try String(contentsOf: url)
                    if (contents != ""){
                        let alertController = UIAlertController(title: "Hint", message:
                            contents, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }catch {
                    let alertController = UIAlertController(title: "Hint", message:
                        "No Hint available at the moment", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
            break
        case 7:
            
            if let url = URL(string: MapController.baseUrl + "/client/getSetStatusSummary?device_id=" + getDeviceId() + "&gallery_id=16" ) {
                do {
                    let contents = try String(contentsOf: url)
                    if (contents != ""){
                        let alertController = UIAlertController(title: "Set Status:", message:
                            contents, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }catch {
                    
                }
            }
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
     func moveToRegion(profile: QProfile){
        
       let camera = GMSCameraPosition.camera(withLatitude: Double(profile.lat)!, longitude: Double(profile.lng)!, zoom: Float(profile.zoom)!)
        self.mapView.animate(to: camera)
        
     }
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(MapController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    func scheduledTimerWithTimeIntervalForPullingData(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateLocations), userInfo: nil, repeats: true)
    }
    
    func scheduledTimerWithTimeIntervalForComparingCoordinates(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.prepareAndCompare), userInfo: nil, repeats: true)
    }
    
    @objc func prepareAndCompare(){
        var undiscoveredLocations:[QLocation] = []
        let tempAllLocations = allLocations
        for allLocation in tempAllLocations {
            var flag = false
            for myLocation in myLocations {
                
                if (myLocation.id == allLocation.id){
                    flag = true
                }
                
            }
            if (!flag){
                undiscoveredLocations.append(allLocation)
            }
            
            
        }
        if (undiscoveredLocations.count>0){
            if (currentCoordinate != nil){
                compareCoordinates(all: undiscoveredLocations, my: currentCoordinate)
            }
        }
    }
   
    @objc func updateLocations(){
        if let url = URL(string: MapController.baseUrl + "/client/getAllLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfileName()) {
            do {
                let contents = try String(contentsOf: url)
                
                allLocations = []
                allLocations = parseLocations(contents)
       
                
                
                if let url = URL(string: MapController.baseUrl + "/client/getMyLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfileName()) {
                    do {
                        let contents = try String(contentsOf: url)
                        
                       
                        let tempMyLocations = parseLocations(contents)
                       // if (tempMyLocations.count == myLocations.count && tempMyLocations.count>0){
                       //       return;
                      // }
                        myLocations = tempMyLocations
                        
                        var undiscoveredLocations:[QLocation] = []
                        for allLocation in allLocations {
                            var flag = false
                            for myLocation in myLocations {
                                
                                if (myLocation.id == allLocation.id){
                                    flag = true
                                }
                                
                            }
                            if (!flag){
                                undiscoveredLocations.append(allLocation)
                            }
                            
                            
                        }
                        if (undiscoveredLocations.count>0){
                            if (currentCoordinate != nil){
                                compareCoordinates(all: undiscoveredLocations, my: currentCoordinate)
                            }
                        }
                        
                        //let allAnnotations = self.mapView.annotations
                        //self.mapView.removeAnnotations(allAnnotations)
                        for myLocation in myLocations {
                            if myLocation.type == "Point" {
                                let point = CustomPin(coordinate: CLLocationCoordinate2D(latitude: Double(myLocation.getLat())! , longitude: Double(myLocation.getlong())! ))
                                point.name = myLocation.name
                                point.id = myLocation.id
                                point.address = myLocation.address
                                point.myDescription = myLocation.description
                            
    //                            point.image = UIImage(named: "splashScreen")
                                let imageURL = URL(string: MapController.baseUrl + "client/downloadMediaById?media_id=" + String(findCoverPicture(galleryId: myLocation.galleryId)) )
                                fetchImageFromURL(imageURL: imageURL!, point: point)

                                //self.mapView.addAnnotation(point)
                                var flag = false
                                for gallery in myGalleries {
                                    if gallery.id == myLocation.galleryId{
                                        flag = true
                                    }
                                }
                                if (!flag) {
                                    if let url = URL(string: MapController.baseUrl + "client/getGalleryById?gallery_id=" + String(myLocation.galleryId)) {
                                        do {
                                            let contents = try String(contentsOf: url)
                                            myGalleries.append(parseGallery(contents,galleryId: myLocation.galleryId))
                                            
                                        }
                                    }

                                }
                            } else if myLocation.type == "Polyg" {
                                var places = [CustomPolygon]()
                                
                                for item in myLocation.parseCoordinateOfLocation() {
                                    
                                    
                                    let place = CustomPolygon(title: myLocation.name, subtitle: myLocation.address, coordinate: CLLocationCoordinate2DMake(Double(item.lat)!, Double(item.lng)!))
                                    places.append(place)
                                }
                                
                            
                                //addAnnotations(places: places)
                                //addPolyline(places: places)
                                //addPolygon(places: places)
                                
                            }
                        }
                        
                        
                    } catch {
                        
                    }
                }
            } catch {
                
            }
        }
    
    }
    /*
    func addAnnotations(places: [CustomPolygon]) {
        mapView?.delegate = self
        mapView?.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
        mapView?.addOverlays(overlays)
        
        // Add polylines
        
        //        var locations = places.map { $0.coordinate }
        //        print("Number of locations: \(locations.count)")
        //        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        //        mapView?.add(polyline)
        
    }
    
    func addPolyline(places: [CustomPolygon]) {
        var locations = places.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        
        mapView?.add(polyline)
    }
    
    func addPolygon(places: [CustomPolygon]) {
        var locations = places.map { $0.coordinate }
        let polygon = MKPolygon(coordinates: &locations, count: locations.count)
        mapView?.add(polygon)
    }
    */
    
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
        
        if let url = URL(string: MapController.baseUrl + "client/getGalleryMediaById?gallery_id=" + String(galleryId)) {
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
        
        let rows = input.components(separatedBy: "},{")
        for row in rows {
            let qMedia = QMedia()
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
    
    
    func parseProfiles(_ input:String) -> [QProfile]{
       var qProfiles:[QProfile] = []
        
        let rows = input.components(separatedBy: "},{")
        for row in rows {
            let qProfile = QProfile()
            var myresult = row.components(separatedBy: ",\"")
            qProfile.id = Int(myresult[0].components(separatedBy: "id\":")[1])!
            qProfile.name = myresult[3].components(separatedBy: "name\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.description = myresult[4].components(separatedBy: "description\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.show = myresult[5].components(separatedBy: "show\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.lat = myresult[6].components(separatedBy: "lat\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.lng = myresult[7].components(separatedBy: "lng\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.zoom = myresult[9].components(separatedBy: "zoom\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.visibleToPlayer = myresult[11].components(separatedBy: "visibleToPlayer\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil).replacingOccurrences(of: "}]", with: "", options: .literal, range: nil)

           qProfiles.append(qProfile)
        }
        return qProfiles
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
                if distanceInMeters < 10 {
                    if let url = URL(string: MapController.baseUrl + "/client/setDiscoveryStatus?device_id=" + getDeviceId() + "&location_id=" + String(locationFromAll.id)) {
                        do {
                            let contents = try String(contentsOf: url)
                                showToast(message: "You have discovered something! stop!")
                        }
                        catch {
                            
                        }
                    }
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
    /*
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                  control: UIControl)
    {
        let pin = view.annotation
        mapView.deselectAnnotation(pin, animated: false)
        //1Gwn6U2AUZwz7oYFiiJK7careTvn7DqYTS("Next VC Segue", sender: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
            
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CustomPolygon, let title = annotation.title else { return }
        
        let alertController = UIAlertController(title: "Welcome to \(title)", message: "You've selected \(title)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        
            if annotationView == nil{
                annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = false
            }else{
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            }
            
            annotationView?.image = UIImage(named: "locationPin")
        
            
            return annotationView
        }
    }
    
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

        calloutView.addSubview(button)
        calloutView.starbucksImage.image = starbucksAnnotation.image
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
        calloutView.addGestureRecognizer(gestureRec)
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }*/
    
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
        GalleryController.myGallery = resultGallery
        performSegue(withIdentifier: "gallerySegue", sender: self)
    }
    
    
    /*func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }*/
    
    
    @IBOutlet weak var picture: UIImageView!
    
      

}


