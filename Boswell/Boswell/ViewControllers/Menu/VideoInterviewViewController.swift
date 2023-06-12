//
//  VideoInterviewViewController.swift
//  Boswell
//
//  Created by MyMac on 12/06/23.
//

import UIKit
import AVFoundation
import AVKit
class VideoInterviewViewController: UIViewController {

    @IBOutlet weak var tableViewVideoList: UITableView!
    var arrayVideos: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Interviews"
        setupUI()
        getData()
        // Do any additional setup after loading the view.
    }
    

    func setupUI() {
        tableViewVideoList.register(UINib(nibName: "VideoListCell", bundle: nil), forCellReuseIdentifier: "VideoListCell")
        tableViewVideoList.delegate = self
        tableViewVideoList.dataSource = self
    }
    
    func getData() {
        arrayVideos.removeAll()
        let urls = VideoManager.shared.getAllVideoList()
        for url in urls {
            if let thumb = self.getThumbnailImage(forUrl: url) {
                arrayVideos.append(["url": url, "image": thumb])
            }
            else {
                arrayVideos.append(["url": url])
            }
        }
        tableViewVideoList.reloadData()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 30), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    @objc func btnShareAction(_ sender: UIButton) {
        let data = arrayVideos[sender.tag]
        if let videoURL = data["url"] as? URL {
            let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}

extension VideoInterviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayVideos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell", for: indexPath) as! VideoListCell
        cell.selectionStyle = .none
        let data = arrayVideos[indexPath.row]
        cell.lblName.text = (data["url"] as? URL)?.lastPathComponent
        cell.imgThumb.image = data["image"] as? UIImage
        cell.btnShare.tag = indexPath.row
        cell.btnShare.addTarget(self, action: #selector(self.btnShareAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = arrayVideos[indexPath.row]
        if let videoURL = data["url"] as? URL {
            let player = AVPlayer(url: videoURL)
            let vc = AVPlayerViewController()
            vc.player = player

            present(vc, animated: true) {
                vc.player?.play()
            }
        }
    }
    
}
