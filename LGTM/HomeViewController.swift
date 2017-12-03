//
//  HomeViewController.swift
//  LGTM
//
//  Created by D on 2017/11/30.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import AlamofireImage
import Haneke
import SwiftyJSON

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    let refreshControl = UIRefreshControl()

    let PhotoCellIdentifier = "PhotoCell"
    let PhotoLoadingIdentifier = "PhotoLoading"
    let PhotoHeaderIdentifier = "PhotoHeader"

    var items = [Item]()
    var page: Int = 1
    var isLoading: Bool = false

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white

        setupView()
        page = 1
        fetchData(page: page)
    }
    
    func fetchData(page: Int) {
        if isLoading == true {
            return
        }
        isLoading = true
        Alamofire.request("https://lgtm.lol/api/list?page=" + String(page)).responseJSON { response in
            LoadingProxy.off()
            switch response.result {
            case .success:
                if let jsonObject = response.result.value {
                    let json = JSON(jsonObject)
                    let array = json["items"].arrayValue
                    var index = 0 + (self.page - 1) * 24
                    for a in array {
                        let item = Item(id: Int64(a["id"].intValue), imageURL: NSURL(string:a["url"].stringValue.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!)
                        self.items.append(item)
                        let indexPath = IndexPath(row:index, section: 0)
                        self.collectionView!.insertItems(at: [indexPath])
                        index += 1
                    }
                }
                self.isLoading = false
            case .failure(_):
                print("Error")
                self.isLoading = false
            }
        }
    }
    
    func setupView() {
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: createLayout())

        self.collectionView.backgroundColor = UIColor.white

        collectionView!.register(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoCellIdentifier)

        collectionView!.register(PhotoCollectionViewLoading.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoLoadingIdentifier)

        collectionView?.dataSource = self
        collectionView?.delegate = self

        self.view.addSubview(collectionView)

        refreshControl.tintColor = UIColor(white: 0.7, alpha: 0.5)
        let attributedString = NSMutableAttributedString(string:"Loading...")
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(white: 0.7, alpha: 0.5) , range: range)
        refreshControl.attributedTitle = attributedString
        refreshControl.addTarget(self, action: #selector(HomeViewController.refreshAction), for: .valueChanged)

        collectionView!.addSubview(refreshControl)

        LoadingProxy.set(v: self)
        LoadingProxy.on()

    }

    func createLayout() -> UICollectionViewFlowLayout {
        let column = 1
        let layout = UICollectionViewFlowLayout()
        let itemWidth = floor((view.bounds.size.width - CGFloat(column - 1)) / CGFloat(column))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 100.0)
        return layout
    }

    @objc func refreshAction() {
        refreshControl.beginRefreshing()
        self.items.removeAll(keepingCapacity: false)
        self.collectionView!.reloadData()
        refreshControl.endRefreshing()
        self.page = 1
        fetchData(page: self.page)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath as IndexPath) as! PhotoCollectionViewCell
        cell.imageView.image = nil
        let item = items[indexPath.row] as Item
        cell.imageView.hnk_setImageFromURL(item.imageURL as URL, placeholder: nil, format: nil, failure:
            { (error) -> () in
                print(error)
        }) { (image) -> () in
            let itemWidth = floor(self.view.bounds.size.width)
            cell.imageView.frame = CGRect(x: 0, y: 0, width: itemWidth, height: image.size.height)
            cell.imageView.image = image
            cell.imageView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                cell.imageView.alpha = 1.0
                cell.imageView.isUserInteractionEnabled = true
                cell.imageView.layer.setValue(item, forKey: "photoinfo")
                cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.imageTapped(_:))))
            })
        }
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.isLoading == false && scrollView.contentOffset.y > 0 && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            self.page += 1
            fetchData(page: self.page)
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let photoInfo = sender.view?.layer.value(forKey: "photoinfo") as! Item
        let itemViewController = ItemViewController()
        itemViewController.itemId = photoInfo.id
        self.navigationController?.pushViewController(itemViewController, animated: true)
    }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    override func prepareForReuse() {
        imageView.hnk_cancelSetImage()
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        imageView.image = nil
    }
    
    internal override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        imageView.frame = bounds
    }
}

class PhotoCollectionViewLoading: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner.center = self.center
        addSubview(spinner)
        spinner.stopAnimating()
    }
}
