//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class GalleryController: BaseViewController {

    @IBAction func previousPressed(_ sender: UIButton) {
        chooseImage(mediaId: GalleryController.myGallery.media[getPrevious(index: self.index)].id)
        descriptionText.text = GalleryController.myGallery.media[self.index].description
        titleText.text = GalleryController.myGallery.media[self.index].name
    }
    @IBAction func nextPressed(_ sender: UIButton) {
            chooseImage(mediaId: GalleryController.myGallery.media[getNext(index: self.index)].id)
            descriptionText.text = GalleryController.myGallery.media[self.index].description
            titleText.text = GalleryController.myGallery.media[self.index].name
    }
    func getPrevious(index: Int) -> Int{
        if index > 0 {
            self.index = index - 1
            return self.index
        }
        else{
            showToast(message: "Nothing left")
        }
        return 0
    }
    
    
    
    func getNext(index: Int) -> Int{
        if index < GalleryController.myGallery.media.count-1 {
            self.index = index+1 
            return self.index
        }
        else{
            showToast(message: "Nothing left")
        }
        return GalleryController.myGallery.media.count-1
    }
    var index: Int = 0
    public static var myGallery = QGallery()
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseImage(mediaId: GalleryController.myGallery.media[index].id)
        descriptionText.text = GalleryController.myGallery.media[index].description
        titleText.text = GalleryController.myGallery.media[index].name
    }
    
    
    
    @IBOutlet weak var picture: UIImageView!
    func chooseImage(mediaId: Int) {
        var imageURL = URL(string: "")
        imageURL = URL(string: MapController.baseUrl + "client/downloadMediaById?media_id=" + String(mediaId) )
        fetchImageFromURL(imageURL: imageURL!)
    }
    
    func fetchImageFromURL(imageURL: URL) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: imageURL as URL)
            // Display about the actual image
            DispatchQueue.main.async {
                if let imageData = fetch {
                    
                    let imageView = UIImageView(frame: self.view.bounds)
                    self.picture.image = UIImage(data: imageData as Data)
                    //imageView.image = UIImage(named: "bkgrd")
                    self.view.addSubview(imageView)
                }
            }
        }
    }
    
    @IBOutlet weak var descriptionText: UILabel!

    @IBOutlet weak var titleText: UILabel!
}
