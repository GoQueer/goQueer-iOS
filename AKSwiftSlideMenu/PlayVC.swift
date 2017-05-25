//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class PlayVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        chooseImage(girlNumber: 1)
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBOutlet weak var picture: UIImageView!
    func chooseImage(girlNumber: Int) {
        var imageURL = URL(string: "")
        switch girlNumber {
        case 0: imageURL = URL(string: "https://goo.gl/8q08OP")
        case 1: imageURL = URL(string: "http://geeksnation.org/wp-content/uploads/2016/10/Most-Beautiful-Girl.jpg")
        case 2: imageURL = URL(string: "https://goo.gl/ZP6Bvh")
        case 3: imageURL = URL(string: "https://goo.gl/Vn9oqX")
        case 4: imageURL = URL(string: "https://goo.gl/GUxkqU")
        case 5: imageURL = URL(string: "https://goo.gl/jCLhhD")
        case 6: imageURL = URL(string: "https://goo.gl/UETU1G")
        case 7: imageURL = URL(string: "https://goo.gl/4v5RfE")
        case 8: imageURL = URL(string: "https://goo.gl/zJri4Z")
        case 9: imageURL = URL(string: "https://goo.gl/uQwgoy")
        default:
            break
        }
        fetchImageFromURL(imageURL: imageURL!)
    }
    
    func fetchImageFromURL(imageURL: URL) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let fetch = NSData(contentsOf: imageURL as URL)
            // Display about the actual image
            DispatchQueue.main.async {
                if let imageData = fetch {
                    //                    self.activityIndicator.stopAnimating()
                    self.picture.image = UIImage(data: imageData as Data)
                }
            }
        }
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
