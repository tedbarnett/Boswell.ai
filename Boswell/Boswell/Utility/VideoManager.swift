//
//  VideoManager.swift
//  Boswell
//
//  Created by MyMac on 12/06/23.
//

import UIKit
import AVFoundation
import Photos
import Foundation

enum VideoManagerError: Error {
    case AVAssetExportSessionError
    case ErrorInGenerateBlankVideo
    case ExportVideoError
}

class VideoManager: NSObject {
    
    static let shared = VideoManager()
    let progress = Progress(totalUnitCount: 100)
    
    func loadAudioDurations(usingURLs urls: [URL]) async throws -> [CMTime] {
        var durations: [CMTime] = []
        try await withThrowingTaskGroup(of: CMTime.self) { group in
            for url in urls {
                let asset = AVURLAsset(url: url)
                group.addTask {
                    let duration = try await asset.load(.duration)
                    return duration
                }
            }
            for try await (duration) in group {
                durations.append(duration)
            }
        }
        return durations
    }
    
    func totalAudioDuration(cmtimes: [CMTime]) -> Double {
        let sum = cmtimes.reduce(CMTime.zero, +)
        let duration = sum.seconds
        return duration
    }
    
//    func createVideoInterView(history: [AIPromptModel]) {
//        let audioURLs = AudioRecorderManager.getAllAudioFileURL(isOnlyUserFiles: true)
//        if audioURLs.count > 0 {
//            var index: Int = 1
//            // Create video composition
//            var arrayImages: [UIImage] = []
//            var arrayAudioURL: [URL] = []
//            for conversationHistory in history {
//                if conversationHistory.isDisplay && conversationHistory.isAddToHistory && !conversationHistory.isError && conversationHistory.role == .assistant && conversationHistory.content != nil  && conversationHistory.content! != "" {
//
//                    let paragraphStyle2 = NSMutableParagraphStyle()
//                    paragraphStyle2.alignment = .center
//
//                    let attribute: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.white , .font: UIFont(name: "Lato-Regular", size: 72.0)!, .backgroundColor: UIColor.black, .paragraphStyle: paragraphStyle2]
//                    if let image = conversationHistory.content!.image(withAttributes: attribute) {
//                        if audioURLs.count >= index {
//                            arrayImages.append(image)
//                            arrayAudioURL.append(audioURLs[index - 1])
//                        }
//                    }
//                    index = index + 1
//                }
//            }
//            if arrayImages.count > 0 && arrayAudioURL.count > 0 {
//                VideoGenerator.fileName = "VideoInterView"
//                VideoGenerator.videoBackgroundColor = .black
//                VideoGenerator.videoImageWidthForMultipleVideoGeneration = 1080
//
//                VideoGenerator.current.generate(withImages: arrayImages, andAudios: arrayAudioURL, andType: .multiple, { (progress) in
//                    print(progress)
//                }) { (result) in
//                    switch result {
//                    case .success(let url):
//                        print(url)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
    
//    func loadAudioAssetTracks(usingURLs urls: [URL]) async throws -> [(AVAssetTrack, CMTime)] {
//        var tracks: [(AVAssetTrack, CMTime)] = []
//        try await withThrowingTaskGroup(of: (AVAssetTrack, CMTime).self) { group in
//            for url in urls {
//                let asset = AVAsset(url: url)
//                group.addTask {
//                    let assetTracks = try await asset.loadTracks(withMediaType: .audio)
//                    let timeRange = try await assetTracks.first!.load(.timeRange)
//                    return (assetTracks.first!, timeRange.duration)
//                }
//            }
//            for try await (track) in group {
//                tracks.append((track.0, track.1))
//            }
//        }
//        return tracks
//    }
    
    
    func loadAudioAssetTracks(usingURLs urls: [URL]) async throws -> [(AVAssetTrack, CMTime)] {
        let audioTracks = try await withThrowingTaskGroup(of: (AVAssetTrack, CMTime).self) { group -> [(AVAssetTrack, CMTime)] in
            for url in urls {
                let asset = AVAsset(url: url)
                group.addTask {
                    let assetTracks = try await asset.loadTracks(withMediaType: .audio)
                    let timeRange = try await assetTracks.first!.load(.timeRange)
                    return (assetTracks.first!, timeRange.duration)
                }
            }
            var tracks: [(AVAssetTrack, CMTime)] = []
            for try await (track) in group {
                tracks.append((track.0, track.1))
            }
            return tracks
        }
        return audioTracks
    }
    
    func createBlackVideo(duration: TimeInterval) async -> (URL?, Error?) {
        await withCheckedContinuation { continuation in
            createBlackVideo(duration: duration) { url, error in
                continuation.resume(returning: (url, error))
            }
        }
    }
    
    func createVideoInterView(history: [AIPromptModel]) async throws {
        let audioURLs = AudioRecorderManager.getAllAudioFileURL(isOnlyUserFiles: true)
        if audioURLs.count > 0 {
            var index: Int = 1
            var arrayAudioURL: [URL] = []
            var arrayAIResponse: [Any] = []
            for conversationHistory in history {
                if conversationHistory.isDisplay && conversationHistory.isAddToHistory && !conversationHistory.isError && conversationHistory.role == .assistant && conversationHistory.content != nil  && conversationHistory.content! != "" {
                    if audioURLs.count >= index {
                        arrayAudioURL.append(audioURLs[index - 1])
                        if let image = conversationHistory.backgroundImage {
                            arrayAIResponse.append(image)
                        }
                        else {
                            arrayAIResponse.append(conversationHistory.content!)
                        }
                    }
                    index = index + 1
                }
            }
            if arrayAIResponse.count > 0 && arrayAudioURL.count > 0 {
                let arrayAudioDurations = try await self.loadAudioDurations(usingURLs: arrayAudioURL)
                let totalAudioDuration = self.totalAudioDuration(cmtimes: arrayAudioDurations)
                let durationBetweenAudio = 3.0
                let introScreenTime = 2.0
                let endScreditScreenTime = 2.0
                let totalVideoDuration = totalAudioDuration + (durationBetweenAudio * Double(arrayAudioURL.count)) + 1.0 + introScreenTime + endScreditScreenTime  //First 1.0 second is blank and then start intro screen for 2 second and then start questionns. 3.0 is duration between 2 questions.
                let (url, error) = await self.createBlackVideo(duration: totalVideoDuration)
                if let videoURL = url {
                    let mixComposition: AVMutableComposition = AVMutableComposition()
                    let aVideoAsset: AVAsset = AVAsset(url: videoURL)
                    
                    let videoComposition = AVMutableVideoComposition()
                    
                    if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                        let aVideoAssetTracks = try await aVideoAsset.loadTracks(withMediaType: .video)
                        if let aVideoAssetTrack: AVAssetTrack = aVideoAssetTracks.first {
                            let videoTimeRange = try await aVideoAssetTrack.load(.timeRange)
                            try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoTimeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

                            let videoSize = CGSize(
                                width: aVideoAssetTrack.naturalSize.width,
                                height: aVideoAssetTrack.naturalSize.height)
                            let videoLayer = CALayer()
                            videoLayer.frame = CGRect(origin: .zero, size: videoSize)
                            let overlayLayer = CALayer()
                            overlayLayer.frame = CGRect(origin: .zero, size: videoSize)

                            var username = "User"
                            if let firstName = UserDefaultsManager.getFirstname(), firstName != "" {
                                username = firstName
                            }
                            
                            addIntroduction(text: "\(username): Life Story", to: overlayLayer, videoSize: videoSize, startTime: 1, endTime: 2)
                            var timeElapsed = CMTime(seconds: 6, preferredTimescale: 30)
                            var index: Int = 0
                            for audioUrl in arrayAudioURL {
                                let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
                                if let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                                    try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aAudioAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: timeElapsed)
                                    //addImage(to: overlayLayer, videoSize: videoSize, startTime: timeElapsed.seconds, endTime: aAudioAssetTrack.timeRange.duration.seconds, image: arrayImages[index])
                                    if let backgrounImage = arrayAIResponse[index] as? UIImage {
                                        addImage(to: overlayLayer, videoSize: videoSize, image: backgrounImage, startTime: timeElapsed.seconds - 3, endTime: aAudioAssetTrack.timeRange.duration.seconds, index: index)
                                    }
                                    else {
                                        add(
                                          text: arrayAIResponse[index] as! String,
                                          to: overlayLayer,
                                          videoSize: videoSize, startTime: timeElapsed.seconds - 3, endTime: aAudioAssetTrack.timeRange.duration.seconds, index: index)
                                    }
                                    index = index + 1
                                    timeElapsed = CMTimeAdd(timeElapsed, aAudioAssetTrack.timeRange.duration)
                                    if index == arrayAudioURL.count {
                                        timeElapsed = CMTimeAdd(timeElapsed, CMTime(seconds: 3, preferredTimescale: 30))
                                    }
                                }
                            }
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MMM d, yyyy"
                            let date = formatter.string(from: Date())
                            addEndCredit(text: "These interview took place between \(date) and \(date)", to: overlayLayer, videoSize: videoSize, startTime: timeElapsed.seconds - 3, endTime: timeElapsed.seconds + 2)
                            
    //                        let audioAssetsTrack = try await self.loadAudioAssetTracks(usingURLs: audioURLs)
    //                        var timeElapsed = CMTime.zero
    //                        for audioAssetTrack in audioAssetsTrack {
    //                            try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAssetTrack.1), of: audioAssetTrack.0, at: timeElapsed)
    //                            timeElapsed = CMTimeAdd(timeElapsed, audioAssetTrack.1)
    //                        }
                            
                            let outputLayer = CALayer()
                            outputLayer.frame = CGRect(origin: .zero, size: videoSize)
                            outputLayer.addSublayer(videoLayer)
                            outputLayer.addSublayer(overlayLayer)
                            
                            //let videoComposition = AVMutableVideoComposition()
                            videoComposition.renderSize = videoSize
                            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
                            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                              postProcessingAsVideoLayer: videoLayer,
                              in: outputLayer)
                            
                            let instruction = AVMutableVideoCompositionInstruction()
                            instruction.timeRange = CMTimeRange(
                              start: .zero,
                              duration: mixComposition.duration)
                            
                            videoComposition.instructions = [instruction]
                            let layerInstruction = compositionLayerInstruction(
                              for: videoTrack,
                              assetTrack: aVideoAssetTrack)
                            instruction.layerInstructions = [layerInstruction]

                        }
                    }

                    guard let export = AVAssetExportSession(
                        asset: mixComposition,
                        presetName: AVAssetExportPresetHighestQuality)
                    else {
                        print("Cannot create export session.")
                        throw VideoManagerError.AVAssetExportSessionError
                    }
                    if let directory = Utility.getDirectoryURL(name: FolderName.VideoInterview) {
                        let videoName = self.getVideoInterviewFilename()
                        let exportURL = directory
                            .appendingPathComponent(videoName)
                        export.outputFileType = .mov
                        export.outputURL = exportURL
                        export.videoComposition = videoComposition
                        await export.export()
                        switch export.status {
                        case .completed:
                            print("Generated Video URL: ", exportURL)
                        default:
                            print("Something went wrong during export.")
                            print(export.error ?? "unknown error")
                            throw export.error ?? VideoManagerError.ExportVideoError
                        }
                    }
                    
                }
                else {
                    print("Blank Video Error:", (error?.localizedDescription ?? ""))
                    throw error ?? VideoManagerError.ErrorInGenerateBlankVideo
                }
            }
        }
    }
    
    func getVideoInterviewFilename() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd hh-mma"
        let strDate = formatter3.string(from: Date())
        var username: String = "User"
        if let name = UserDefaultsManager.getFirstname(), name != "" {
            username = name
        }
        let filename = "\(username) \(strDate.lowercased()) - Boswell Interview Video.mov"
        return filename
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
      let transform = assetTrack.preferredTransform
      instruction.setTransform(transform, at: .zero)
      return instruction
    }
    
    private func addIntroduction(text: String, to layer: CALayer, videoSize: CGSize, startTime: CFTimeInterval, endTime: CFTimeInterval) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let date = formatter.string(from: Date())
        let introText = "\(text)\n\(date)"
        
        let attributedText = NSMutableAttributedString(string: introText, attributes: [
            .font: UIFont(name: "Lato-Regular", size: 150.0)! as Any,
            .foregroundColor: UIColor.white])
        
        attributedText.addAttributes([
            .font: UIFont(name: "Lato-Regular", size: 100.0)! as Any,
            .foregroundColor: UIColor.white], range: (introText as NSString).range(of: date))
        
        
        let attributedDomainText = NSAttributedString(
            string: "Boswell.ai",
            attributes: [
                .font: UIFont(name: "Lato-Regular", size: 100.0)! as Any,
                .foregroundColor: UIColor.white])
        
        
        let textLayer = CATextLayer()
        textLayer.isWrapped = true
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.opacity = 0.0
        textLayer.frame = CGRect(
            x: 150,
            y: 300,
            width: videoSize.width - 300,
            height: videoSize.height - 600)
        textLayer.displayIfNeeded()
        
        let domainTextLayer = CATextLayer()
        domainTextLayer.isWrapped = true
        domainTextLayer.string = attributedDomainText
        domainTextLayer.shouldRasterize = true
        domainTextLayer.rasterizationScale = UIScreen.main.scale
        domainTextLayer.backgroundColor = UIColor.clear.cgColor
        domainTextLayer.alignmentMode = .center
        domainTextLayer.opacity = 0.0
        domainTextLayer.frame = CGRect(
            x: 150,
            y: 0,
            width: videoSize.width - 300,
            height: 200)
        domainTextLayer.displayIfNeeded()
        
        let startVisible = CABasicAnimation.init(keyPath:"opacity")
        startVisible.duration = 0.5    // for fade in duration
        startVisible.repeatCount = 1
        startVisible.fromValue = 0.0
        startVisible.toValue = 1.0
        startVisible.beginTime = startTime == 0 ? 1 :  startTime// overlay time range start duration
        startVisible.isRemovedOnCompletion = false
        startVisible.fillMode = CAMediaTimingFillMode.forwards
        textLayer.add(startVisible, forKey: "startAnimation_Intro")
        domainTextLayer.add(startVisible, forKey: "startAnimation_Domain")
        
        let endVisible = CABasicAnimation.init(keyPath:"opacity")
        endVisible.duration = 0.5
        endVisible.repeatCount = 1
        endVisible.fromValue = 1.0
        endVisible.toValue = 0.0
        endVisible.beginTime = startTime + endTime
        endVisible.fillMode = CAMediaTimingFillMode.forwards
        endVisible.isRemovedOnCompletion = false
        textLayer.add(endVisible, forKey: "endAnimation_Intro")
        domainTextLayer.add(endVisible, forKey: "endAnimation_Domain")
        
        layer.addSublayer(textLayer)
        layer.addSublayer(domainTextLayer)
    }
    
    private func addEndCredit(text: String, to layer: CALayer, videoSize: CGSize, startTime: CFTimeInterval, endTime: CFTimeInterval) {
                
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: "Lato-Regular", size: 70.0)! as Any,
            .foregroundColor: UIColor.white])

        let attributedDomainText = NSAttributedString(
            string: "Boswell.ai",
            attributes: [
                .font: UIFont(name: "Lato-Regular", size: 100.0)! as Any,
                .foregroundColor: UIColor.white])
        
        
        let textLayer = CATextLayer()
        textLayer.isWrapped = true
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.opacity = 0.0
        textLayer.frame = CGRect(
            x: 150,
            y: 300,
            width: videoSize.width - 300,
            height: videoSize.height - 600)
        textLayer.displayIfNeeded()
        
        let domainTextLayer = CATextLayer()
        domainTextLayer.isWrapped = true
        domainTextLayer.string = attributedDomainText
        domainTextLayer.shouldRasterize = true
        domainTextLayer.rasterizationScale = UIScreen.main.scale
        domainTextLayer.backgroundColor = UIColor.clear.cgColor
        domainTextLayer.alignmentMode = .center
        domainTextLayer.opacity = 0.0
        domainTextLayer.frame = CGRect(
            x: 150,
            y: 0,
            width: videoSize.width - 300,
            height: 200)
        domainTextLayer.displayIfNeeded()
        
        let startVisible = CABasicAnimation.init(keyPath:"opacity")
        startVisible.duration = 0.5    // for fade in duration
        startVisible.repeatCount = 1
        startVisible.fromValue = 0.0
        startVisible.toValue = 1.0
        startVisible.beginTime = startTime == 0 ? 1 :  startTime// overlay time range start duration
        startVisible.isRemovedOnCompletion = false
        startVisible.fillMode = CAMediaTimingFillMode.forwards
        textLayer.add(startVisible, forKey: "startAnimation_End")
        domainTextLayer.add(startVisible, forKey: "startAnimation_Domain_End")
        
        let endVisible = CABasicAnimation.init(keyPath:"opacity")
        endVisible.duration = 0.5
        endVisible.repeatCount = 1
        endVisible.fromValue = 1.0
        endVisible.toValue = 0.0
        endVisible.beginTime = startTime + endTime
        endVisible.fillMode = CAMediaTimingFillMode.forwards
        endVisible.isRemovedOnCompletion = false
        textLayer.add(endVisible, forKey: "endAnimation_End")
        domainTextLayer.add(endVisible, forKey: "endAnimation_Domain_End")
        
        layer.addSublayer(textLayer)
        layer.addSublayer(domainTextLayer)
    }
    
    private func add(text: String, to layer: CALayer, videoSize: CGSize, startTime: CFTimeInterval, endTime: CFTimeInterval, index: Int) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont(name: "Lato-Regular", size: 70.0)!,
                .foregroundColor: UIColor.white])
        
        let textLayer = CATextLayer()
        textLayer.isWrapped = true
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.opacity = 0.0
        textLayer.frame = CGRect(
            x: 150,
            y: 150,
            width: videoSize.width - 300,
            height: videoSize.height - 300)
        textLayer.displayIfNeeded()
        
        let startVisible = CABasicAnimation.init(keyPath:"opacity")
        startVisible.duration = 0.5    // for fade in duration
        startVisible.repeatCount = 1
        startVisible.fromValue = 0.0
        startVisible.toValue = 1.0
        startVisible.beginTime = startTime == 0 ? 1 :  startTime// overlay time range start duration
        startVisible.isRemovedOnCompletion = false
        startVisible.fillMode = CAMediaTimingFillMode.forwards
        textLayer.add(startVisible, forKey: "startAnimation_\(index)")
        
        let endVisible = CABasicAnimation.init(keyPath:"opacity")
        endVisible.duration = 0.5
        endVisible.repeatCount = 1
        endVisible.fromValue = 1.0
        endVisible.toValue = 0.0
        endVisible.beginTime = startTime + endTime
        endVisible.fillMode = CAMediaTimingFillMode.forwards
        endVisible.isRemovedOnCompletion = false
        textLayer.add(endVisible, forKey: "endAnimation_\(index)")
        
        layer.addSublayer(textLayer)
    }

    private func addImage(to layer: CALayer, videoSize: CGSize, image: UIImage, startTime: CFTimeInterval, endTime: CFTimeInterval, index: Int) {
        let imageLayer = CALayer()
        let aspect: CGFloat = image.size.width / image.size.height
        let width = videoSize.width
        let height = width / aspect
        imageLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height)
        imageLayer.contents = image.cgImage
        imageLayer.opacity = 0.0
        
        let startVisible = CABasicAnimation.init(keyPath:"opacity")
        startVisible.duration = 0.5    // for fade in duration
        startVisible.repeatCount = 1
        startVisible.fromValue = 0.0
        startVisible.toValue = 1.0
        startVisible.beginTime = startTime == 0 ? 1 :  startTime// overlay time range start duration
        startVisible.isRemovedOnCompletion = false
        startVisible.fillMode = CAMediaTimingFillMode.forwards
        imageLayer.add(startVisible, forKey: "startAnimation_\(index)")
        
        let endVisible = CABasicAnimation.init(keyPath:"opacity")
        endVisible.duration = 0.5
        endVisible.repeatCount = 1
        endVisible.fromValue = 1.0
        endVisible.toValue = 0.0
        endVisible.beginTime = startTime + endTime
        endVisible.fillMode = CAMediaTimingFillMode.forwards
        endVisible.isRemovedOnCompletion = false
        imageLayer.add(endVisible, forKey: "endAnimation_\(index)")
        
        layer.addSublayer(imageLayer)
    }
    
    func createBlackVideo(duration: TimeInterval, _ completion: @escaping ((_ url: URL?, _ error: Error?) -> Void)) {
        do {
            let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("blackVideo.mp4")
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }
            let videoSize = CGSize(width: 1920, height: 1080)
            let frameRate = 30
            let videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: videoSize.width,
                AVVideoHeightKey: videoSize.height
            ]

            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)

            /// check if an input can be added to the asset
            assert(videoWriter.canAdd(videoWriterInput))
            
            videoWriter.add(videoWriterInput)

            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: .zero)
                /// check that the pixel buffer pool has been created
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                let queue = DispatchQueue(label: "videoQueue", qos: .default, attributes: [], autoreleaseFrequency: .workItem)
                var index: Int = 0
                videoWriterInput.requestMediaDataWhenReady(on: queue) {
                    while videoWriterInput.isReadyForMoreMediaData {
                        if (index == Int(duration)) {
                            break
                        }
                        let presentationTime = CMTime(seconds: Double(index), preferredTimescale: CMTimeScale(frameRate))
                        if let pixelBuffer = self.createBlackPixelBuffer(size: videoSize) {
                            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                            print(presentationTime.seconds)
                        }
                        index = index + 1
                    }
                    if (index == Int(duration)) {
                        videoWriterInput.markAsFinished()
                        videoWriter.finishWriting {
                            if videoWriter.status == .completed {
                                print("Black video exported successfully.")
                                completion(outputURL, nil)
                            } else if let error = videoWriter.error {
                                print("Error exporting black video: \(error)")
                                completion(nil, error)
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error creating black video: \(error.localizedDescription)")
            completion(nil, error)
        }
    }

    func createBlackPixelBuffer(size: CGSize) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        
        if status == kCVReturnSuccess, let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
            let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            context?.setFillColor(UIColor.black.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            
            return pixelBuffer
        }
        
        return nil
    }
    
    func getAllVideoList() -> [URL] {
        var arrayFileUrls: [URL] = []
        if let directoryURL = Utility.getDirectoryURL(name: FolderName.VideoInterview) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) // Read all file in  PlaybackAudio Directory
                
                for contentURL in directoryContents {
                    if contentURL.pathExtension == "mov" { // Check file is m4a or caf
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
}
