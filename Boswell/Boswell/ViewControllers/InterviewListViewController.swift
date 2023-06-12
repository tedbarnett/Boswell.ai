//
//  InterviewListViewController.swift
//  Boswell
//
//  Created by MyMac on 24/05/23.
//

import UIKit

class InterviewListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var firtAudioURL: URL?
    var arrayInterviewURLs: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Interviews"
        setupUI()
        setData()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        tableView.register(UINib(nibName: "AudioListCell", bundle: nil), forCellReuseIdentifier: "AudioListCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setData() {
        self.arrayInterviewURLs.removeAll()
        if let url = self.firtAudioURL {
            self.arrayInterviewURLs.append(url)
        }
        let urls = AudioRecorderManager.getAllInterviewFrom(directory: AppData.shared.config.isSilverMode ? FolderName.BoswellParents : FolderName.Boswell)
        self.arrayInterviewURLs.append(contentsOf: urls)
        tableView.reloadData()
    }

    // Open Audio Playback screen.
    func openAudioPlaybackScreen(audioURL: URL) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AudioPlaybackViewController") as! AudioPlaybackViewController
        vc.audioURL = audioURL
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
}

extension InterviewListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayInterviewURLs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioListCell", for: indexPath) as! AudioListCell
        cell.selectionStyle = .none
        cell.setupUI()
        let url = self.arrayInterviewURLs[indexPath.row]
        cell.lblFilename.text = url.lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.arrayInterviewURLs[indexPath.row]
        self.openAudioPlaybackScreen(audioURL: url)
    }
}
