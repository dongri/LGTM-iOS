//
//  ItemViewController.swift
//  LGTM
//
//  Created by D on 2017/11/30.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ItemViewController: UIViewController {
    var itemId: Int64!
    var imageView: UIImageView!
    var copyButton: UIButton!
    var mdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        imageView = UIImageView()
        self.view.addSubview(imageView)
        
        mdLabel = UILabel()
        mdLabel.text = "![LGTM](https://lgtm.lol/p/\(itemId)"
        self.view.addSubview(mdLabel)

        copyButton = UIButton()
        copyButton.setTitle("Copy", for: .normal)
        copyButton.setTitleColor(UIColor.blue, for: .normal)
        copyButton.addTarget(self, action: #selector(self.copyString), for: .touchUpInside)
        
        self.view.addSubview(copyButton)

        LoadingProxy.set(v: self)
        loadImage()
    }
    
    func loadImage() {
        LoadingProxy.on()
        Alamofire.request("https://lgtm.lol/api/item/" + String(itemId)).responseJSON { response in
            LoadingProxy.off()
            switch response.result {
            case .success:
                if let jsonObject = response.result.value {
                    let json = JSON(jsonObject)
                    let item = json["item"].dictionaryValue
                    let imageURL = item["url"]?.stringValue
                    Alamofire.request(imageURL!, method: .get).responseImage { response in
                        guard let image = response.result.value else {
                            // Handle error
                            return
                        }
                        self.imageView.image = image
                        
                        let sh = UIApplication.shared.statusBarFrame.height
                        let nh = self.navigationController?.navigationBar.frame.size.height
                        let mh = sh + nh!

                        let vf = self.view.frame
                        
                        let iw = image.size.width
                        let ih = image.size.height
                        
                        let imageViewHeight = ih * vf.size.width / iw
                        self.imageView.frame = CGRect(x: 0, y: mh, width: vf.size.width, height: imageViewHeight)
                        self.mdLabel.frame = CGRect(x: 0, y: self.imageView.frame.size.height + mh + 10, width: vf.size.width, height: 20)
                        self.copyButton.frame = CGRect(x: 0, y: self.imageView.frame.size.height + mh + 40, width: vf.size.width, height: 20)
                    }
                }
            case .failure(_):
                print("Error")
            }
        }
    }
    
    @objc func copyString() {
        let board = UIPasteboard.general
        board.string = mdLabel.text
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Copy",
            message: "Copied!",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

}
