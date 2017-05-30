//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class PlayVC: BaseViewController {

    @IBAction func previousPressed(_ sender: UIButton) {
        chooseImage(mediaId: PlayVC.myGallery.media[getPrevious(index: self.index)].id)
        descriptionText.text = PlayVC.myGallery.media[self.index].description
        titleText.text = PlayVC.myGallery.media[self.index].name
    }
    @IBAction func nextPressed(_ sender: UIButton) {
            chooseImage(mediaId: PlayVC.myGallery.media[getNext(index: self.index)].id)
            descriptionText.text = PlayVC.myGallery.media[self.index].description
            titleText.text = PlayVC.myGallery.media[self.index].name
    }
    func getPrevious(index: Int) -> Int{
        if index > 0 {
            self.index = index - 1
            return self.index
        }
        return 0
    }
    
    func getNext(index: Int) -> Int{
        if index < PlayVC.myGallery.media.count {
            self.index = index+1 
            return self.index
        }
        return PlayVC.myGallery.media.count
    }
    var index: Int = 0
    public static var myGallery = QGallery()
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseImage(mediaId: PlayVC.myGallery.media[index].id)
        descriptionText.text = PlayVC.myGallery.media[index].description
        titleText.text = PlayVC.myGallery.media[index].name
    }
    
    
    
    @IBOutlet weak var picture: UIImageView!
    func chooseImage(mediaId: Int) {
        var imageURL = URL(string: "")
        imageURL = URL(string: HomeVC.baseUrl + "client/downloadMediaById?media_id=" + String(mediaId) )
        fetchImageFromURL(imageURL: imageURL!)
    }
    
    func fetchImageFromURL(imageURL: URL) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: imageURL as URL)
            // Display about the actual image
            DispatchQueue.main.async {
                if let imageData = fetch {
                    self.picture.image = UIImage(data: imageData as Data)
                }
            }
        }
    }
    
    @IBOutlet weak var descriptionText: UILabel!

    @IBOutlet weak var titleText: UILabel!
}
