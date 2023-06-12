//
//  PhotoSwitchControlView.swift
//  Boswell
//
//  Created by MyMac on 01/05/23.
//

import UIKit

protocol PhotoSwitchControlViewDelegate: NSObjectProtocol {
    func photoSwitchControlViewDidSelectImage(url: URL)
    func photoSwitchControlViewDidSelectAdd()
    func photoSwitchControlViewDidSelectNone()
}

class PhotoSwitchControlView: UIView {

    @IBOutlet weak var collectionViewPhotos: UICollectionView!
    weak var delegate: PhotoSwitchControlViewDelegate?
    var arrayImageURLs: [URL] = []
    var selectedURL: URL?
    class func fromNib() -> PhotoSwitchControlView {
        return Bundle(for: PhotoSwitchControlView.self).loadNibNamed(String(describing: PhotoSwitchControlView.self), owner: nil, options: nil)![0] as! PhotoSwitchControlView
    }

    func setupUI(selectedURL: URL?) {
        self.selectedURL = selectedURL
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        
        collectionViewPhotos.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
        self.getData()
    }
    
    func getData() {
        if let dirPath = Utility.getDirectoryURL(name: FolderName.BackgroundPhotos) {
            do {
                // Get the directory contents urls (including subfolders urls)
                self.arrayImageURLs = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil)
            }
            catch let error {
                print(error)
            }
        }
        collectionViewPhotos.reloadData()
    }
}

extension PhotoSwitchControlView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayImageURLs.count + 2 // +1 because the first option is none.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        if indexPath.row == 0 {
            cell.imgPhoto.contentMode = .scaleAspectFit
            cell.imgPhoto.image = UIImage(systemName: "photo.on.rectangle")
            cell.imgPhoto.tintColor = UIColor.tintColor
            cell.viewAlpha.isHidden = true
        }
        else if indexPath.row == (self.arrayImageURLs.count + 1) {
            cell.imgPhoto.contentMode = .scaleAspectFit
            cell.imgPhoto.image = UIImage(systemName: "xmark.circle")
            cell.imgPhoto.tintColor = UIColor.red
            cell.viewAlpha.isHidden = true
        }
        else {
            cell.imgPhoto.tintColor = UIColor.tintColor
            cell.imgPhoto.contentMode = .scaleAspectFill
            do {
                let imageData = try Data(contentsOf: self.arrayImageURLs[indexPath.row - 1])
                cell.imgPhoto.image = UIImage(data: imageData)
            } catch {
                cell.imgPhoto.image = nil
            }
            if let selectedImageURL = self.selectedURL, selectedImageURL.absoluteString == self.arrayImageURLs[indexPath.row - 1].absoluteString {
                cell.viewAlpha.isHidden = false
            }
            else {
                cell.viewAlpha.isHidden = true
            }
        }
        cell.lblUsed.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.delegate?.photoSwitchControlViewDidSelectAdd()
        }
        else if indexPath.row == (self.arrayImageURLs.count + 1) {
            self.delegate?.photoSwitchControlViewDidSelectNone()
        }
        else {
            self.selectedURL = self.arrayImageURLs[indexPath.row - 1]
            self.delegate?.photoSwitchControlViewDidSelectImage(url: self.selectedURL!)
        }
    }
}
