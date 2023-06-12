//
//  BackgroundViewController.swift
//  Boswell
//
//  Created by MyMac on 26/04/23.
//

import UIKit
import Photos
import PhotosUI

protocol BackgroundViewControllerDelegate: NSObjectProtocol {
    func backgroundViewControllerDidUpdate(isUpdated: Bool, isParentPhoto: Bool, isFromParentProfile: Bool)
}

class BackgroundViewController: UIViewController {
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var collectionViewPhotos: UICollectionView!
    var arrayImageURLs: [URL] = []
    var isPhotosAvailable: Bool = false
    var isParentPhoto: Bool = false
    var isFromParentProfile: Bool = false
    weak var delegate: BackgroundViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photo Memories"
        isPhotosAvailable = BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: isParentPhoto)
        setupUI()
        setupNavigationButton()
        getData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var isUpdate: Bool = false
        if isPhotosAvailable != BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: isParentPhoto) {
            isUpdate = true
        }
        self.delegate?.backgroundViewControllerDidUpdate(isUpdated: isUpdate, isParentPhoto: self.isParentPhoto, isFromParentProfile: self.isFromParentProfile)
        
    }
    
    func setupUI() {
        collectionViewPhotos.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
    }
    
    func setupNavigationButton() {
        let btnAdd = UIButton(type: .contactAdd)
        btnAdd.tintColor = UIColor.systemBlue
        btnAdd.addTarget(self, action: #selector(self.btnAddAction(_:)), for: .touchUpInside)
        let btnBarButtonAdd = UIBarButtonItem(customView: btnAdd)
        self.navigationItem.rightBarButtonItem = btnBarButtonAdd
    }

    func markUsedAndUnused(url: URL) {
        BoswellInterviewHelper.markUsedAndUnused(url: url, isParentPhoto: self.isParentPhoto)
        self.collectionViewPhotos.reloadData()
    }
    
    func getData() {
        self.arrayImageURLs = BoswellInterviewHelper.getBackgroundImageURLs(isParentPhoto: self.isParentPhoto)
        collectionViewPhotos.reloadData()
    }

    @objc func btnAddAction(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = PHPickerFilter.images
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.toolbarItems = nil
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }

    func deletePhoto(index: Int) {
        let url = self.arrayImageURLs[index]
        do {
            try FileManager.default.removeItem(at: url)
        }
        catch let error {
            print(error.localizedDescription)
        }
        self.arrayImageURLs.remove(at: index)
        self.collectionViewPhotos.reloadData()
    }
}

extension BackgroundViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        let group = DispatchGroup()
        var arrayURLs: [URL] = []
        if itemProviders.count > 0 {
            Utility.showLoader(status: "Preparing...")
            for item in itemProviders {
                group.enter()
                if item.canLoadObject(ofClass: UIImage.self) {
                    item.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            if let dirPath = Utility.getDirectoryURL(name: self.isParentPhoto ? FolderName.BackgroundForParentPhotos : FolderName.BackgroundPhotos) {
                                do {
                                    // choose a name for your image
                                    let fileName = "\(UUID().uuidString).png"
                                    // create the destination file url to save your image
                                    let fileURL = dirPath.appendingPathComponent(fileName)
                                    // get your UIImage png data representation and check if the destination file url already exists
                                    if let data = image.fixOrientation().pngData(),
                                       !FileManager.default.fileExists(atPath: fileURL.path) {
                                        // writes the image data to disk
                                        try data.write(to: fileURL)
                                        print("file saved")
                                        arrayURLs.append(fileURL)
                                    }
                                } catch {
                                    print("error:", error)
                                }
                            }
                        }
                        group.leave()
                    }
                }
                else {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                Utility.hideLoader()
                if self.arrayImageURLs.count > 0 {
                    self.arrayImageURLs.append(contentsOf: arrayURLs)
                }
                else {
                    self.arrayImageURLs = arrayURLs
                }
                self.collectionViewPhotos.reloadData()
            }
        }
        
    }
}

extension BackgroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayImageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let url = self.arrayImageURLs[indexPath.row]
            let delete = UIAction(title: "Remove from Boswell", image: UIImage(systemName: "xmark"), attributes: .destructive) { action in
                self.deletePhoto(index: indexPath.row)
            }
            let markUsed = UIAction(title: "Mark used") { action in
                self.markUsedAndUnused(url: url)
            }
            let markUnUsed = UIAction(title: "Mark unused") { action in
                self.markUsedAndUnused(url: url)
            }
            let cancel = UIAction(title: "Cancel") { action in
                
            }
            if BoswellInterviewHelper.isPhotoUsed(url: url, isParentPhoto: self.isParentPhoto) {
                return UIMenu(title: "", children: [delete, markUnUsed, cancel])
            }
            else {
                return UIMenu(title: "", children: [delete, markUsed, cancel])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let url = self.arrayImageURLs[indexPath.row]
        do {
            let imageData = try Data(contentsOf: url)
            cell.imgPhoto.image = UIImage(data: imageData)
        } catch {
            cell.imgPhoto.image = nil
        }
        if BoswellInterviewHelper.isPhotoUsed(url: url, isParentPhoto: self.isParentPhoto) {
            cell.viewAlpha.isHidden = false
        }
        else {
            cell.viewAlpha.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - 2) / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }

}
