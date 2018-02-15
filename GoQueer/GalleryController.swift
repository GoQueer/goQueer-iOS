//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class GalleryController: BaseViewController {

    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBAction func previousPressed(_ sender: UIButton) {
        chooseImage(media: GalleryController.myGallery.media[getPrevious(index: self.index)])
        descriptionText.text = GalleryController.myGallery.media[self.index].description
        titleText.text = GalleryController.myGallery.media[self.index].name
    }
    @IBAction func nextPressed(_ sender: UIButton) {
            chooseImage(media: GalleryController.myGallery.media[getNext(index: self.index)])
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
        chooseImage(media: GalleryController.myGallery.media[self.index])
        descriptionText.text = GalleryController.myGallery.media[index].description
        titleText.text = GalleryController.myGallery.media[index].name
        titleText.textAlignment = .center
        //imageViewWidth.constant = self.view.frame.width * 0.95
        //imageViewHeight.constant = self.view.frame.height * 0.5
        // Make width 85% of Screen Width
    }
    
    
    
    @IBOutlet weak var picture: UIImageView!
    func chooseImage(media: QMedia) {
        var imageURL = URL(string: "")
        imageURL = URL(string: MapController.baseUrl + "client/downloadMediaById?media_id=" + String(media.id) )
        fetchImageFromURL(imageURL: imageURL!, media: media)
    }
    
    func fetchImageFromURL(imageURL: URL,media: QMedia) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: imageURL as URL)
            
            DispatchQueue.main.async {
                if let imageData = fetch {
                    
                    let imageView = UIImageView(frame: self.view.bounds)
                    if media.typeId == 4 {
                        self.picture.image = UIImage(data: imageData as Data)
                        self.view.addSubview(imageView)
                    }else if media.typeId == 5 {
                        self.picture.image = UIImage.gif(data: imageData as Data)
                        self.view.addSubview(imageView)
                    }
                    
                    
                    
                }
            }
        }
    }
    
    @IBOutlet weak var descriptionText: UILabel!

    @IBOutlet weak var titleText: UILabel!
}
