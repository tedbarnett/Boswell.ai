//
//  AudioRecorderManager.swift
//  Boswell
//
//  Created by MyMac on 03/05/23.
//



import UIKit
import AVFoundation
import Photos

/**
 `AudioRecorderManager` Class is useful for recording user speech and merge user recorded speech and AI Response
 */
class AudioRecorderManager: NSObject {
    private var composition: AVMutableComposition!
    private var audioMix: AVMutableAudioMix = AVMutableAudioMix()
    private var audioMixParam: [AVMutableAudioMixInputParameters] = []
    private var audioFileUrls: [URL] = []
    private var audioComplitionHandler : ((_ audioPlaybackFileURL: URL?, _ error: Error?) -> Void)?
    
    /// Create a file name. It will read all `mp4` and `caf` files inside the `PlaybackAudio` Folder then sort the filename in ascending order and then get the last filename and increment it by 1 to get the next filename. Basically, we stored files in sequential order to merge all audio sequentially
    ///
    /// ```
    /// print(getFilename()) // "1"
    /// ```
    ///
    /// - Returns: Return next audio filename. In case any error it will return "1"
    static func getFilename(isUser: Bool) -> String {
        if let directoryURL = Utility.getDirectoryURL(name:  AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) { // Get PlaybackAudio Directory URL
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) // Read all file in  PlaybackAudio Directory
                var arrayFileNumber: [Int] = []
                for contentURL in directoryContents {
                    if contentURL.pathExtension == "m4a" || contentURL.pathExtension == "mp3" { // Check file is m4a or caf
                        let filename = contentURL.deletingPathExtension().lastPathComponent
                        if !(filename.lowercased().contains("Boswell Interview Audio".lowercased())) { // Add all files except Playback Audio because Playback Audio file is a full interview audio playback file.
                            let components = filename.components(separatedBy: "_")
                            if components.count > 0 {
                                let filenumber = Int(components.last!) ?? 0
                                arrayFileNumber.append(filenumber)
                            }
                        }
                    }
                }
                arrayFileNumber = arrayFileNumber.sorted(by: {$0 < $1}) //sort file names in ascending order
                if let filenumber = arrayFileNumber.last {
                    return isUser ? "User_\(filenumber + 1)" : "AI_\(filenumber + 1)"// increment the last file name by 1
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        return isUser ? "User_1" : "AI_1" // Default return "1"
    }
    
    static func getAllInterviewFrom(directory: String) -> [URL] {
        var arrayFileUrls: [URL] = []
        if let directoryURL =
            Utility.getDirectoryURL(name: FolderName.Boswell) { // Get PlaybackAudio Directory URL
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) // Read all file in  PlaybackAudio Directory
                
                for contentURL in directoryContents {
                    if contentURL.pathExtension == "m4a" || contentURL.pathExtension == "mp3" { // Check file is m4a or caf
                        arrayFileUrls.append(contentURL)
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        return arrayFileUrls
    }
    
    /// Delete all audio playback files.
    ///
    /// ```
    /// deleteAllAudioFile()
    /// ```
    ///
    static func deleteAllAudioFileFrom(directory: String) {
        if let directoryURL = Utility.getDirectoryURL(name: directory) { // Get PlaybackAudio Directory URL
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
                for fileURL in directoryContents where (fileURL.pathExtension == "m4a" || fileURL.pathExtension == "mp3") {
                    try FileManager.default.removeItem(at: fileURL) // Remove m4a and caf files
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// It will return all m4a and caf files in ascending order from `PlaybackAudio` directory.
    ///
    /// ```
    /// getAllAudioFileURL() -> [URL]
    /// ```
    ///
    /// - Returns: Return array of all m4a and caf file URLs
    static func getAllAudioFileURL(isOnlyUserFiles: Bool = false) -> [URL] {
        if let directoryURL = Utility.getDirectoryURL(name: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
                var urls: [URL] = []
                for fileURL in directoryContents where (fileURL.pathExtension == "m4a" || fileURL.pathExtension == "mp3") {
                    let filename = fileURL.deletingPathExtension().lastPathComponent
                    if !(filename.lowercased().contains("Boswell Interview Audio".lowercased())) {
                        if isOnlyUserFiles {
                            if filename.lowercased().contains("user") {
                                urls.append(fileURL)
                            }
                        }
                        else {
                            urls.append(fileURL)
                        }
                    }
                }
                urls = urls.sorted(by: { url1, url2 in
                    let filename1 = url1.deletingPathExtension().lastPathComponent
                    let filename2 = url2.deletingPathExtension().lastPathComponent
                    var filenumber1: Int = 0
                    let components1 = filename1.components(separatedBy: "_")
                    if components1.count > 0 {
                        filenumber1 = Int(components1.last!) ?? 0
                    }
                    var filenumber2: Int = 0
                    let components2 = filename2.components(separatedBy: "_")
                    if components2.count > 0 {
                        filenumber2 = Int(components2.last!) ?? 0
                    }
                    return filenumber1 < filenumber2
                })
                //urls = urls.sorted(by: {(Int($0.deletingPathExtension().lastPathComponent) ?? 0) < (Int($1.deletingPathExtension().lastPathComponent)  ?? 0)})
                return urls
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        return []
    }
    
    /**
     Remove last audio User recording file if user didn't speak
     ```
     removeLastAudioFile()
     ```
     */
    static func removeLastAudioFile() {
        let allFilesURL = AudioRecorderManager.getAllAudioFileURL()
        if let lastURL = allFilesURL.last {
            let filename = lastURL.deletingPathExtension().lastPathComponent
            let components = filename.components(separatedBy: "_")
            if components.count > 0 && components.first! == "User" {
                try? FileManager.default.removeItem(at: lastURL) // Remove last audio User recording file if user didn't speak
            }
        }
    }

    func deleteBoswellInterviewAudioFile() {
        if let directoryURL = Utility.getDirectoryURL(name: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) { // Get PlaybackAudio Directory URL
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
                for fileURL in directoryContents where (fileURL.lastPathComponent.lowercased().contains("Boswell Interview Audio".lowercased())) {
                    try FileManager.default.removeItem(at: fileURL) // Remove m4a and caf files
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    /**
     Merge all Boswell interview audio files in on the playback audio file `PlaybackAudio.m4a`. Once finish merging it will return the handler
     ```
     mergeAudioFiles(handler: (@escaping (_ audioPlaybackFileURL: URL?, _ error: Error?) -> Void))
     ```
     */
    func mergeAudioFiles(foldername: String, filename: String, handler: (@escaping (_ audioPlaybackFileURL: URL?, _ error: Error?) -> Void)) {
        self.audioComplitionHandler = handler
        if let directoryURL = Utility.getDirectoryURL(name: foldername) {
            let audioFilename = directoryURL.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: audioFilename) // Remove previously recorded file
            if foldername == FolderName.PlaybackAudio || foldername == FolderName.PlaybackAudioParents {
                self.deleteBoswellInterviewAudioFile()
            }
            audioFileUrls.removeAll()
            audioFileUrls = AudioRecorderManager.getAllAudioFileURL()
            if audioFileUrls.count > 0 {
                //Remove last auido file if user didn't answer
                if let lastURL = audioFileUrls.last {
                    let filename = lastURL.deletingPathExtension().lastPathComponent
                    let components = filename.components(separatedBy: "_")
                    if components.count > 0 && components.first! == "AI" {
                        audioFileUrls.removeLast()
                    }
                }
                if audioFileUrls.count > 0 {
                    self.composition = AVMutableComposition()
                    self.audioMix = AVMutableAudioMix()
                    self.audioMixParam.removeAll()
                    self.createAudioComposition(foldername: foldername, filename: filename)
                }
                else {
                    self.audioComplitionHandler?(nil, nil)
                }
            }
            else {
                self.audioComplitionHandler?(nil, nil)
            }
        }
    }
    
    /**
     create audio compositions one by one recursively. It recursion method because we need to merge audio files in order of user speech and AI Response
     ```
     createAudioComposition(audioFileUrls: [URL])
     ```
     */
    private func createAudioComposition(foldername: String, filename: String) {
        if audioFileUrls.count > 0 {
            let audioFileUrl = audioFileUrls.first! // Start first audio file
            if let compositionAudioTrack = self.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID()) {
                let filePath = audioFileUrl.path
                Task {
                    do {
                        let asset = AVURLAsset(url: URL(filePath: filePath))
                        let assetTracks = try await asset.loadTracks(withMediaType: AVMediaType.audio)
                        if assetTracks.count > 0 {
                            let audioTrack = assetTracks.first!
                            let audioParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)
                            audioParam.trackID = audioTrack.trackID
                            if let urlAsset = audioTrack.asset as? AVURLAsset {
                                if urlAsset.url.lastPathComponent.hasPrefix("AI_") {
                                    audioParam.setVolume(0.5, at: self.composition.duration)
                                }
                                else {
                                    audioParam.setVolume(1.0, at: self.composition.duration)
                                }
                            }
                            self.audioMixParam.append(audioParam)
                            let duration = try await audioTrack.load(.timeRange).duration
                            let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: duration)
                            try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: self.composition.duration)
                            self.startNextAudioComposition(foldername: foldername, filename: filename)
                        }
                    }
                    catch let error {
                        print(error)
                        self.startNextAudioComposition(foldername: foldername, filename: filename)
                    }
                }
                
//                asset.loadTracks(withMediaType: AVMediaType.audio) { assetTracks, error in
//                    if let trackContainer = assetTracks, trackContainer.count > 0 {
//                        let audioTrack = trackContainer[0]
//                        Task {
//                            do {
//                                let audioParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)
//                                audioParam.trackID = audioTrack.trackID
//                                if let urlAsset = audioTrack.asset as? AVURLAsset {
//                                    if urlAsset.url.lastPathComponent.hasPrefix("AI_") {
//                                        audioParam.setVolume(0.5, at: self.composition.duration)
//                                    }
//                                    else {
//                                        audioParam.setVolume(1.0, at: self.composition.duration)
//                                    }
//                                }
//                                self.audioMixParam.append(audioParam)
//                                let duration = try await audioTrack.load(.timeRange).duration
//                                let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: duration)
//                                try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: self.composition.duration)
//                            }
//                            catch let error {
//                                print("Murge Auido Insert Time Range Error: ", error)
//                            }
//                        }
//                        self.startNextAudioComposition(foldername: foldername, filename: filename)
//                    }
//                    else {
//                        self.startNextAudioComposition(foldername: foldername, filename: filename)
//                    }
//                }
            }
            else {
                self.startNextAudioComposition(foldername: foldername, filename: filename)
            }
        }
    }
    
    private func startNextAudioComposition(foldername: String, filename: String) {
        self.audioFileUrls.removeFirst() // Remove first file from array
        if self.audioFileUrls.count > 0 { // Check if the array has still files
            self.createAudioComposition(foldername: foldername, filename: filename) // Yes, then insert it into composition track
        }
        else {
            self.audioMix.inputParameters = self.audioMixParam
            self.exportPlaybackAudio(foldername: foldername, filename: filename) // Export complete audio once finish inserting
        }
    }
    
    /**
     Export Boswell playback interview audio
     ```
     exportPlaybackAudio()
     ```
     */
    private func exportPlaybackAudio(foldername: String, filename: String) {
        if let directoryURL = Utility.getDirectoryURL(name: foldername) {
            let audioFilename = directoryURL.appendingPathComponent(filename)
            let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
            assetExport?.outputFileType = AVFileType.m4a
            assetExport?.outputURL = audioFilename
            assetExport?.audioMix = self.audioMix
            assetExport?.exportAsynchronously(completionHandler:{
                switch assetExport!.status
                {
                case AVAssetExportSession.Status.failed:
                    print("AUDIO_MERGE -> failed \(String(describing: assetExport!.error!))")
                    self.audioComplitionHandler?(nil, assetExport!.error)
                case AVAssetExportSession.Status.cancelled:
                    print("AUDIO_MERGE -> cancelled \(String(describing: assetExport!.error))")
                    self.audioComplitionHandler?(nil, assetExport!.error)
                case AVAssetExportSession.Status.unknown:
                    print("AUDIO_MERGE -> unknown\(String(describing: assetExport!.error))")
                    self.audioComplitionHandler?(nil, assetExport!.error)
                case AVAssetExportSession.Status.waiting:
                    print("AUDIO_MERGE -> waiting\(String(describing: assetExport!.error))")
                case AVAssetExportSession.Status.exporting:
                    print("AUDIO_MERGE -> exporting\(String(describing: assetExport!.error) )")
                default:
                    print("Audio Concatenation Complete")
                    print(audioFilename)
                    self.audioComplitionHandler?(audioFilename, nil)
                }
            })
        }
    }
}


