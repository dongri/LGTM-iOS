//
//  SubmitViewController.swift
//  LGTM
//
//  Created by D on 2017/11/30.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

import Alamofire

class SubmitViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var cameraView: UIImageView!
    var lgtmLabel: UILabel!
    var snapshotBounds: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Submit"

        self.view.backgroundColor = UIColor.white

        let cameraBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.cameraAction))
        self.navigationItem.leftBarButtonItem = cameraBarButton

        let uploadBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.uploadAction))
        self.navigationItem.rightBarButtonItem = uploadBarButton
        
        cameraView = UIImageView()
        cameraView.frame = self.view.frame
        self.view.addSubview(cameraView)
        
        let strokeTextAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -2.0,
        ]
        
        lgtmLabel = UILabel()
        lgtmLabel.attributedText = NSAttributedString(string: "LGTM!", attributes: strokeTextAttributes)
        lgtmLabel.textColor = UIColor.white
        lgtmLabel.font = UIFont.boldSystemFont(ofSize: 70)
        lgtmLabel.isHidden = true
        cameraView.addSubview(lgtmLabel)
        LoadingProxy.set(v: self)

        self.navigationItem.rightBarButtonItem?.isEnabled = false

    }
    
    @objc func cameraAction() {
        print("cameraAction")
        let sourceType:UIImagePickerControllerSourceType =
            UIImagePickerControllerSourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
        else{
            print("error")
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage]
            as? UIImage {
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage

            let vf = self.view.frame
            let originalSize = pickedImage.size
            
            let imageSizeHeight = vf.size.width * originalSize.height / originalSize.width
            let imageSize = CGSize(width: vf.size.width, height: imageSizeHeight)
            
            //let ix = (vf.size.width - imageSize.width ) / 2
            let iy = (vf.size.height - imageSize.height ) / 2
            let imageBounds = CGRect(x: 0, y: iy, width: imageSize.width, height: imageSize.height)
            cameraView.frame = imageBounds
            
            let y = imageBounds.size.height - (imageBounds.size.height - imageSize.height ) / 2
            lgtmLabel.frame = CGRect(x: 30, y: y - 120, width: 300, height: 60)
            lgtmLabel.isHidden = false

            snapshotBounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func uploadAction() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        LoadingProxy.on()
        print("uploadAction")
        let image = cameraView.snapshot(snapshotBounds)
        let imageData = UIImagePNGRepresentation(image!)
        let base64String = imageData?.base64EncodedString()
        
        let parameters = [
            "image": base64String
        ]
        
        Alamofire.request("https://lgtm.lol/api/upload", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (response) -> Void in
            print(response)
            LoadingProxy.off()
            self.cameraView.image = nil
            self.lgtmLabel.isHidden = true
            self.showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Upload",
            message: "Successfully!",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func snapshot(_ bounds: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        if UIGraphicsGetCurrentContext() != nil {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
