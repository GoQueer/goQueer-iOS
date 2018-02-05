import Foundation
import UIKit
import GLKit
import GoogleMaps
import CoreLocation
import SwiftGifOrigin



class MapController: BaseViewController, CLLocationManagerDelegate, SlideMenuDelegate, GMSMapViewDelegate {
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
    
    
    
  
  

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //this is our map view
        self.mapView = GMSMapView(frame: self.view.bounds)
        
        mapView.isMyLocationEnabled = true
        do {
            // Set the map style by passing a valid JSON string.
            self.mapStyle(withFilename: "grayscale", andType: "json")
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        view = mapView
        
        mapView.delegate = self
  
        addSlideMenuButton()
        scheduledTimerWithTimeIntervalForPullingData()
        scheduledTimerWithTimeIntervalForComparingCoordinates()
        updateLocations()
        
        if (  getProfile().name == "" ) {
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
                                defaults.set(profile.id, forKey: defaultsKeys.keyTwo)
                                defaults.set(profile.show, forKey: defaultsKeys.keyThree)
                                
                                self.moveToRegion(profile: profile)
                                
                                
                            }))
                        }
                          alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in}))
                        
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
                            if (profile.name == getProfile().name){
                                
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
        initThumNailView()
        
        
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
                                defaults.set(profile.id, forKey: defaultsKeys.keyTwo)
                                defaults.set(profile.show, forKey: defaultsKeys.keyThree)
                                
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
            
            if let url = URL(string: MapController.baseUrl + "/client/getHint?device_id=" + getDeviceId()+"&profile_name=" + getProfile().name ) {
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
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(profile.lat)!, longitude: Double(profile.lng)!, zoom: Float(profile.zoom)!, bearing: Double(profile.bearing)!, viewingAngle: Double(profile.viewingAngle)!)
        self.mapView.animate(to: camera)
        
     }
    
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
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
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateLocations), userInfo: nil, repeats: true)
    }
    
    func scheduledTimerWithTimeIntervalForComparingCoordinates(){

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
        if let url = URL(string: MapController.baseUrl + "/client/getAllLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfile().name) {
            do {
                let contents = try String(contentsOf: url)
                
                allLocations = []
                allLocations = parseLocations(contents)
       
                
               
                if let url = URL(string: MapController.baseUrl + "/client/getMyLocations?device_id=" + getDeviceId() + "&profile_name=" + getProfile().name) {
                    do {
                        let contents = try String(contentsOf: url)
                        let tempMyLocations = parseLocations(contents)
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
                        
                        self.mapView.clear()
                        if ( (getProfile().show == "1") || (getProfile().show == "2") ) {
                            processLocations(locations: allLocations)
                        } else {
                            processLocations(locations: myLocations)
                        }
                        
                        
                    } catch {
                        
                    }
                }
            } catch {
                
            }
        }
    
    }
    
    func processLocations(locations: [QLocation]){
        do{
            for myLocation in locations {
                if myLocation.type == "Point" {
                   
                    let marker = GMSMarker()
                    let markerImage = UIImage(named: "locationPin")!.withRenderingMode(.alwaysTemplate)
                    let markerView = UIImageView(image: markerImage)
                    markerView.tintColor = UIColor.black
                    marker.position = CLLocationCoordinate2D(latitude: Double(myLocation.getLat())!, longitude: Double(myLocation.getlong())!)
                    marker.iconView = markerView
                    marker.title = myLocation.name
                    marker.snippet = myLocation.description
                    marker.zIndex = Int32(myLocation.id)
                    marker.map = mapView
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
                    
                    let rect = GMSMutablePath()
                    var points = [CLLocationCoordinate2D]()
                    let items = myLocation.parseCoordinateOfLocation()
                    for item in items {
                        rect.add(CLLocationCoordinate2D(latitude: Double(item.lat)!, longitude: Double(item.lng)!))
                        points.append(CLLocationCoordinate2D(latitude: Double(item.lat)!, longitude: Double(item.lng)!))
                    }
                    let polygon1 = GMSPolygon(path: rect)
                    polygon1.fillColor = UIColor(red: 0.0, green: 0.55, blue: 0, alpha: 0.15);
                    polygon1.strokeColor = .black
                    polygon1.strokeWidth = 2
                    polygon1.map = mapView
                    
                    
                    
                    let centerMarker = GMSMarker()
                    let markerImage = UIImage(named: "polygonPin")!.withRenderingMode(.alwaysTemplate)
                    let markerView = UIImageView(image: markerImage)
                    markerView.tintColor = UIColor.black
                    centerMarker.position = getCenterCoord(points)
                    centerMarker.iconView = markerView
                    centerMarker.title = myLocation.name
                    centerMarker.snippet = myLocation.description
                    centerMarker.zIndex = Int32(myLocation.id)
                    centerMarker.map = mapView
                }
            }
        }catch {
        
        }
    }
    
    func getCenterCoord(_ LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
        var x:Float = 0.0;
        var y:Float = 0.0;
        var z:Float = 0.0;
        for points in LocationPoints {
            let lat = GLKMathDegreesToRadians(Float(points.latitude));
            let long = GLKMathDegreesToRadians(Float(points.longitude));
            
            x += cos(lat) * cos(long);
            
            y += cos(lat) * sin(long);
            
            z += sin(lat);
        }
        x = x / Float(LocationPoints.count);
        y = y / Float(LocationPoints.count);
        z = z / Float(LocationPoints.count);
        let resultLong = atan2(y, x);
        let resultHyp = sqrt(x * x + y * y);
        let resultLat = atan2(z, resultHyp);
        let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))));
        return result;
    }
    
    static let thumbNailViewWidth = 400
    static let thumbNailViewHeight = 250
    let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    let moreButton = UIButton(frame: CGRect(x: 295, y: thumbNailViewHeight - 35, width: 100, height: 30))
    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: thumbNailViewWidth, height: thumbNailViewHeight))
    let descriptionLable = UITextView(frame: CGRect(x: 200, y: 40, width: 195, height: 205))
    let titleLable = UITextView(frame: CGRect(x: 200, y: 5, width: 195, height: 40))
    var image: UIImage = UIImage()
    var thumbNailView = UIImageView(frame: CGRect(x: 5, y: 5, width: 195, height: thumbNailViewHeight-5))
    var activityIndicator = UIActivityIndicatorView()
    
  
    func initThumNailView(){
        closeButton.addTarget(self, action: #selector(MapController.closeButtonClicked(_:)), for: .touchUpInside)
        
        

        titleLable.font = UIFont.boldSystemFont(ofSize: 20)
        titleLable.isEditable = false
        mainView.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.5)
        mainView.addSubview(titleLable)
        mainView.addSubview(descriptionLable)
        descriptionLable.font = descriptionLable.font?.withSize(16)
        descriptionLable.isEditable = false
        closeButton.backgroundColor = UIColor.black
        closeButton.setTitle("X", for: .normal)
        moreButton.backgroundColor = UIColor.green
        moreButton.setTitle("Read More", for: .normal)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 80, y: 100, width: 46, height: 46)
        mainView.addSubview(activityIndicator)
        
        
        
        
        mainView.addSubview(thumbNailView)
        mainView.center = CGPoint(x: self.view.frame.size.width - 250, y: self.view.frame.size.height - 180)
        mainView.addSubview(closeButton)
        mainView.addSubview(moreButton)
        self.view.addSubview(mainView)
        mainView.isHidden = true
    }
    var selectedGalleryId: Int = 0
   
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        selectedLocationId = Int(marker.zIndex)
        var found: Bool = false
        if (getProfile().show == "2" ) {
            for location in myLocations {
                if (location.id == selectedLocationId) {
                    found = true
                }
            }
            if found == false{
                showToast(message: "You have to discover this location first")
                return
            }
        }
        
        activityIndicator.startAnimating()
        mainView.isHidden = false
        
        
        titleLable.text = marker.title
        
        
        for location in allLocations {
            if (location.id == selectedLocationId) {
                selectedGalleryId = location.galleryId
            }
        }
    
        descriptionLable.text = marker.snippet
        
        
        fetchImageFromURL(media: findCoverPicture(galleryId: Int(selectedGalleryId)))
        _ = UITapGestureRecognizer(target: self, action: #selector(navigateToGallery(galleryID: )))
        thumbNailView.isUserInteractionEnabled = true
        moreButton.addTarget(self, action: #selector(MapController.navigateToGallery(galleryID: )), for: .touchUpInside)

    }
    
    @objc func navigateToGallery(galleryID: Int32)
    {
        var resultGallery = QGallery()
        for gallery in myGalleries {
            if gallery.id == selectedGalleryId {
                resultGallery = gallery
            }
        }
        GalleryController.myGallery = resultGallery
        performSegue(withIdentifier: "gallerySegue", sender: self)
    }
    
    @objc func closeButtonClicked(_ sender: AnyObject?)
    {
        if sender === closeButton {
            thumbNailView.image = nil
            mainView.isHidden = true
        }
    }
    
    
    func findCoverPicture(galleryId: Int) -> QMedia {
        for gallery in myGalleries {
            if gallery.id ==  galleryId && gallery.media.count > 0 {
                return gallery.media[0]
            }
        }
        return QMedia()
      
    }
    
    func fetchImageFromURL(media: QMedia)   {
        
        let url = URL(string: MapController.baseUrl + "client/downloadMediaById?media_id=" + String(media.id))
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: url as! URL)
            DispatchQueue.main.async {
                if let imageData = fetch {
                    if media.typeId == 4 {
                        self.thumbNailView.image =   UIImage(data: imageData as Data)
                    }else if media.typeId == 5 {
                        
                        self.thumbNailView.image = UIImage.gif(data: imageData as Data)
                    }
                }
            }
        }
    }


    func parseGallery(_ input:String, galleryId: Int) -> QGallery {
        
        let qGallery = QGallery()
        if (input == "[]"){
            return qGallery
        }
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
            qProfile.viewingAngle = myresult[8].components(separatedBy: "tilt\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.zoom = myresult[9].components(separatedBy: "zoom\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.bearing = myresult[10].components(separatedBy: "bearing\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            qProfile.visibleToPlayer = myresult[11].components(separatedBy: "visibleToPlayer\":")[1].replacingOccurrences(of: "\"", with: "", options: .literal, range: nil).replacingOccurrences(of: "}]", with: "", options: .literal, range: nil)

           qProfiles.append(qProfile)
        }
        return qProfiles
    }

    
    
   
    
     let currentLocationMarker = GMSMarker()
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
        GalleryController.myGallery = resultGallery
        performSegue(withIdentifier: "gallerySegue", sender: self)
    }*/
    
    
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


