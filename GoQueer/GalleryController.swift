import UIKit
import YouTubePlayer

class GalleryController: BaseViewController {

    
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBAction func previousPressed(_ sender: UIButton) {
        
            chooseImage(media: GalleryController.myGallery.media[getPrevious(index: self.index)])
            descriptionText.text = GalleryController.myGallery.media[self.index].description
            titleText.text = GalleryController.myGallery.media[self.index].name
            if (GalleryController.myGallery.media[self.index].extraLinks != "" && GalleryController.myGallery.media[self.index].extraLinks != nil &&
                GalleryController.myGallery.media[self.index].extraLinks != "null"){
                linkText.text = GalleryController.myGallery.media[self.index].extraLinks.replacingOccurrences(of: "\\/", with: "/")
            } else {
                linkText.text = ""
            }
    }
    @IBAction func nextPressed(_ sender: UIButton) {
            chooseImage(media: GalleryController.myGallery.media[getNext(index: self.index)])
            descriptionText.text = GalleryController.myGallery.media[self.index].description
            titleText.text = GalleryController.myGallery.media[self.index].name
            if (GalleryController.myGallery.media[self.index].typeId == 1){
                linkText.text = String(GalleryController.myGallery.media[self.index].mediaURL).replacingOccurrences(of: "\\/",  with: "/", options: .literal, range: nil)
            } else {
                linkText.text = ""
            }
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
    
    
    
    @IBOutlet weak var linkText: UITextView!
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
        if (self.index > -1 && self.index < GalleryController.myGallery.media.count ){
            chooseImage(media: GalleryController.myGallery.media[self.index])
            descriptionText.text = GalleryController.myGallery.media[index].description
            titleText.text = GalleryController.myGallery.media[index].name
            titleText.textAlignment = .center
        }
    }
    
    
    
    @IBOutlet weak var picture: UIImageView!
    func chooseImage(media: QMedia) {
        progress.startAnimating()
        var imageURL = URL(string: "")
        imageURL = URL(string: MapController.baseUrl + "client/downloadMediaById?media_id=" + String(media.id) )
        if (media.typeId == 5 || media.typeId == 4) {
            self.videoPlayer.isHidden = true
            fetchImageFromURL(imageURL: imageURL!, media: media)
        } else if media.typeId == 1 {
            self.videoPlayer.isHidden = false
            let myVideoURL = NSURL(string: media.mediaURL.replacingOccurrences(of: "\\", with: ""))
            self.videoPlayer.loadVideoURL(myVideoURL! as URL)
        } else {
            self.videoPlayer.isHidden = true
        }
        
        
        
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
    
    

    @IBOutlet weak var titleText: UILabel!
}
