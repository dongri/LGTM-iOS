//
//  LoadingProxy.swift
//  LGTM
//
//  Created by D on 2017/12/01.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import UIKit

struct LoadingProxy{
    
    static var myActivityIndicator: UIActivityIndicatorView!
    
    static func set(v:UIViewController){
        self.myActivityIndicator = UIActivityIndicatorView()
        self.myActivityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.myActivityIndicator.center = v.view.center
        self.myActivityIndicator.hidesWhenStopped = false
        self.myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.myActivityIndicator.backgroundColor = UIColor.darkGray
        self.myActivityIndicator.layer.masksToBounds = true
        self.myActivityIndicator.layer.cornerRadius = 5.0;
        self.myActivityIndicator.layer.opacity = 0.5;
        v.view.addSubview(self.myActivityIndicator);
        self.off();
    }
    static func on(){
        myActivityIndicator.startAnimating();
        myActivityIndicator.isHidden = false;
    }
    static func off(){
        myActivityIndicator.stopAnimating();
        myActivityIndicator.isHidden = true;
    }
    
}

