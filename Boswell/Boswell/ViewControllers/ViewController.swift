//
//  ViewController.swift
//  Boswell
//
//  Created by Ted Barnett (with help from ChatGPT-4!) on 3/31/2023.
//

import UIKit
import AVFoundation
import Speech
import Foundation
import MessageUI

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var listeningStatus: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    //@IBOutlet weak var viewImgBackgroundOpacity: UIView!
    @IBOutlet weak var btnBrightness: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imgBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var imgBackgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var imgBackgroundTop: NSLayoutConstraint!
    
    var viewTapGesture: UITapGestureRecognizer?
    var imgBackgroundPanGesture: UIPanGestureRecognizer?
    var imgBackgroundPinchGesture: UIPinchGestureRecognizer?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var audioRecordManager = AudioRecorderManager()
//    var viewBrightnessControl: BrightnessControlView?
//    var viewBrightnessControlHeight: NSLayoutConstraint?
//    var backgroundBrightness: Float = 0.7
//    private var token: NSKeyValueObservation?
    
    lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 160, height: 44.0)
        button.setTitle(AppData.shared.config.getTitleFromMode(), for: .normal)
        button.titleLabel?.font = UIFont(name: "Lato-Bold", size: 25.0)!
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    lazy var soundButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let unmute = UIImage(systemName: "speaker.wave.2", withConfiguration: imageConfiguration)
        let mute = UIImage(systemName: "speaker.slash", withConfiguration: imageConfiguration)
        button.setImage(unmute, for: .normal)
        button.setImage(mute, for: .selected)
        return button
    }()

    let boswellInterviewHelper = BoswellInterviewHelper()
    var isPlayingIntroAudio: Bool = false
    var elevenLabAudioURL: URL?
    var audioPlayerItem: AVPlayerItem?
    var isSpeakingAI: Bool = false
    let silenceThreshold: Float = 0.01 // Adjust this value as per your requirements
    let silenceDuration: TimeInterval = 10 // Adjust this value as per your requirements
    var startRecordingTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    
    var audioPlayer: AVPlayer?
    public let speechSynthesizer = AVSpeechSynthesizer.init() // added .init per this example: https://developer.apple.com/forums/thread/717355
    var spokenTextRange: NSRange? // Store the current spoken text range
    var currentSpeechText: String? // Store the current speech full text.
    
    var conversationHistory: [AIPromptModel] = []
    var conversationHistoryDisplay: [AIPromptModel] = []
    
    var boswellConversationHistory: [AIPromptModel] = []
    var boswellConversationHistoryDisplay: [AIPromptModel] = []
    private var textSize:CGFloat = 20
    var isSoundSettingUpdated: Bool = false // Indicate sound settings updated
    weak var apiTask: URLSessionTask?
    // NOTE: OpenAI corporate green color is RGB 16, 163, 127 (or #10a37f)
    override func viewDidLoad() { //viewDidLoad
        super.viewDidLoad()
        setupUI()
        // self.speakApple(text: "Hello.  I am Boswell.")
        configureSpeechRecognition()
        // Debugging iOS voice problem
        let voices = AVSpeechSynthesisVoice.speechVoices()
        print("Voice Count: \(voices.count)")
        setupNavigationButton()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        speechSynthesizer.delegate = self
        //self.setBackgroundImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.setBackgroundImage(image: self.getBackgroundImage(isParentPhoto: AppData.shared.config.isSilverMode))
//        self.audioRecordManager.createBlackVideo(duration: 25.0) { url, error in
//            
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopUserRecordingIfAnyAction()
    }

    func requestMicrophoneAccess() {
        // TODO: Tested do{} below per https://stackoverflow.com/questions/49208291/failure-starting-audio-queue-%E2%89%A5%CB%9A%CB%9B%CB%87
        // https://developer.apple.com/documentation/avfaudio/avaudiosession/1616503-categoryoptions
        do{
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetooth]) // or mixWithOthers or duckOthers or defaultToSpeaker or interruptSpokenAudioAndMixWithOthers (suggested duckOthers)
            try audioSession.setMode(AVAudioSession.Mode.default)
            self.setAudioInput()
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            //try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone access granted")
                        self.updateRecordButton(enable: false, title: self.getRecordButtonTitle())
                        if !UserDefaultsManager.getAppLaunchFlag() {
                            UserDefaultsManager.saveAppLaunchFlag(isFirstTime: true)
                            if let path = Bundle.main.path(forResource: "Boswell_Intro_Audio_British_Male.mp3", ofType:nil) {
                                let url = URL(fileURLWithPath: path)
                                self.isPlayingIntroAudio = true
                                self.audioPlayerItem = AVPlayerItem(url: url)
                                self.audioPlayer = AVPlayer(playerItem: self.audioPlayerItem!)
                                self.audioPlayer?.play()
                                NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audioPlayerItem!)
                                //self.playAudio(url: url)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) {
                                self.updateAppMode(isUpdateMode: true, previousMode: .Boswell)
                            }
                        }
                        else {
                            self.updateAppMode(isUpdateMode: true, previousMode: .Boswell)
                        }
                    } else {
                        print("Microphone access denied")
                        self.updateRecordButton(enable: false, title: self.getRecordButtonTitle())
                    }
                }
            }
        }catch {
            print(error)
            self.updateRecordButton(enable: false,  title: self.getRecordButtonTitle())
        }
    }
    
    func configureSpeechRecognition() {
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized.")
                    self.requestMicrophoneAccess()
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized.")
                    self.updateRecordButton(enable: false, title: self.getRecordButtonTitle())
                @unknown default:
                    print("Unknown speech recognition authorization status.")
                    self.updateRecordButton(enable: false, title: self.getRecordButtonTitle())
                }
            }
        }
    }
    
    func setupUI() {
        imgBackgroundWidth.constant = UIScreen.main.bounds.size.width
        imgBackgroundHeight.constant = UIScreen.main.bounds.size.height
        textView.font = UIFont(name: "Lato-Bold", size: textSize)!
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = 15.0
        self.recordButton.layer.borderWidth = 1.0
        self.recordButton.layer.borderColor = UIColor.white.cgColor
        self.recordButton.setTitleColor(UIColor(red: 169.0/255.0, green: 244.0/255.0, blue: 250.0/255.0, alpha: 1.0), for: .normal)
        self.recordButton.setTitleColor(UIColor.systemGray2, for: .disabled)
        self.setupChatTableView()
        if AppData.shared.config.mode == .Boswell {
            self.listeningStatus.text = "Your Personal Biographer"
        }
        else {
            self.listeningStatus.text = AppData.shared.config.apiModel == .ChatGPT_4 ? "(GPT-4)" : "(GPT-3.5)"
        }
//        token = viewImgBackgroundOpacity.observe(\.alpha) { [weak self] object, change in
//            guard let weakSelf = self else { return }
//            if weakSelf.viewImgBackgroundOpacity.alpha == 0 {
//                weakSelf.imgBackground.contentMode = .scaleAspectFit
//                weakSelf.view.bringSubviewToFront(weakSelf.scrollView)
//                weakSelf.view.bringSubviewToFront(weakSelf.btnBrightness)
//                if weakSelf.viewBrightnessControl != nil {
//                    weakSelf.view.bringSubviewToFront(weakSelf.viewBrightnessControl!)
//                }
//                weakSelf.scrollView.delegate = self
//            }
//            else {
//                weakSelf.imgBackground.contentMode = .scaleAspectFill
//                weakSelf.view.sendSubviewToBack(weakSelf.scrollView)
//                weakSelf.scrollView.delegate = nil
//                weakSelf.scrollView.zoomScale = 1.0
//            }
//        }
    }
    
    func setupNavigationButton() {
        soundButton.addTarget(self, action: #selector(self.btnSoundAction(_:)), for: .touchUpInside)
        let btnSound = UIBarButtonItem(customView: soundButton)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleSoundButtonLongPress(_:)))  //Long function will call when user long press on button.
        longGesture.delaysTouchesBegan = true
        longGesture.minimumPressDuration = 1.0
        soundButton.addGestureRecognizer(longGesture)

        let btnMenu = UIButton(type: .custom)
        btnMenu.setImage(UIImage(named: "ic_menu"), for: .normal)
        btnMenu.addTarget(self, action: #selector(self.btnMenuAction(_:)), for: .touchUpInside)
        let navigationMenu = UIBarButtonItem(customView: btnMenu)
        
        self.navigationItem.rightBarButtonItem = btnSound
        self.navigationItem.leftBarButtonItem = navigationMenu
        menuButton.addTarget(self, action: #selector(self.btnModeAction(_:)), for: .touchUpInside)
        self.navigationItem.titleView = menuButton
        self.btnShare.isEnabled = false
    }

    func getRecordButtonTitle() -> String {
        if AppData.shared.config.mode == .ChatGPT {
            return "Speak to ChatGPT"
        }
        else if AppData.shared.config.mode == .CreateImage {
            return "Describe an Image"
        }
        else {
            return "Speak to Boswell"
        }
    }
    
    func setupNotifications() {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
    }
    
    func setAudioInput() {
        let audioSession = AVAudioSession.sharedInstance()
        let availableInputs = audioSession.availableInputs ?? []
        do {
            if let index = availableInputs.firstIndex(where: {$0.portType == .bluetoothHFP}) {
                try audioSession.setPreferredInput(availableInputs[index])
            }
            else if let index = availableInputs.firstIndex(where: {$0.portType == .headsetMic}) {
                try audioSession.setPreferredInput(availableInputs[index])
            }
            else if let index = availableInputs.firstIndex(where: {$0.portType == .headphones}) {
                try audioSession.setPreferredInput(availableInputs[index])
            }
            else if let index = availableInputs.firstIndex(where: {$0.portType == .builtInMic}) {
                try audioSession.setPreferredInput(availableInputs[index])
            }
            else if let firstInput = availableInputs.first {
                try audioSession.setPreferredInput(firstInput)
            }
        } catch {
            print("Error setting preferred input: \(error.localizedDescription)")
        }
    }
    
    //Mark:- Action
    @objc func itemDidFinishPlaying(_ notification: NSNotification) {
        if self.isPlayingIntroAudio {
            self.isPlayingIntroAudio = false
            if let url = elevenLabAudioURL {
                self.playAudio(url: url)
            }
        }
        self.isSpeakingAI = false
        finishThinking()
        if let item = self.audioPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            self.audioPlayerItem = nil
        }
    }
    @objc func handleSoundButtonLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        if let sender = gesture.view as? UIButton {
            UIImpactFeedbackGenerator().impactOccurred()
            //self.dismissBrightnessControl()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoicesViewController") as! VoicesViewController
            vc.modalPresentationStyle = .popover
            if let popover = vc.popoverPresentationController {
                let viewForSource = sender as UIView
                popover.sourceView = viewForSource
                // the position of the popover where it's showed
                popover.sourceRect = viewForSource.bounds
                // the size you want to display
                vc.preferredContentSize = CGSizeMake(130,300)
                popover.delegate = self
            }
            present(vc, animated: true)
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable:
            print("New audio device connected")
            self.setAudioInput()
        default:
            break
        }
    }
    
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    
    @objc func btnModeAction(_ sender: UIButton) {
        if !AppData.shared.config.isSilverMode {
            openModeSelectionScreen(sourceView: sender as UIView)
        }
    }
    
    // Enable/Disable sound
    @objc func btnSoundAction(_ sender: UIButton) {
        self.soundButton.isSelected = !self.soundButton.isSelected
        self.isSoundSettingUpdated = true
        if AppData.shared.config.mode == .Boswell {
            if self.audioPlayer != nil {
                self.audioPlayer?.isMuted = self.soundButton.isSelected
            }
            else {
                self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            }
        }
        else {
            // Stop the current speech. because there is no way to directly control the volume of AVSpeechUtterance. Restart speech from the last stop on speech
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    @IBAction func btnBrightnessAction(_ sender: Any) {
        self.btnBrightness.isSelected = !self.btnBrightness.isSelected
        if self.btnBrightness.isSelected {
            //self.showBrightnessControl()
        }
        else {
            //self.dismissBrightnessControl()
        }
    }
    
    @IBAction func btnShareAction(_ sender: Any) {
        self.stopUserRecordingIfAnyAction()
        var arrayHsitory: [AIPromptModel] = []
        if AppData.shared.config.mode == .Boswell {
            if self.boswellConversationHistory.count > 0 {
                arrayHsitory = self.boswellConversationHistory
            }
        }
        else {
            if self.conversationHistoryDisplay.count > 0 {
                arrayHsitory = self.conversationHistoryDisplay
            }
        }
        if arrayHsitory.count > 0 {
            //self.dismissBrightnessControl()
            let shareManager = ShareManager(conversationHistory: arrayHsitory)
            shareManager.share(vc: self)
//            let url = shareManager.getSharePdfUrl()
//            if MFMessageComposeViewController.canSendAttachments() {
//                let messageComposeVC = MFMessageComposeViewController()
//                messageComposeVC.messageComposeDelegate = self
//                messageComposeVC.recipients = ["+91 9913241004"]
//                messageComposeVC.addAttachmentURL(url, withAlternateFilename: url.lastPathComponent)
//                self.present(messageComposeVC, animated: true)
//            }
        }
    }
    

    func createNewChat() {
        self.btnShare.isEnabled = false
        if AppData.shared.config.mode == .Boswell {
            self.boswellConversationHistory.removeAll()
            self.boswellConversationHistoryDisplay.removeAll()
        }
        else {
            self.conversationHistory.removeAll()
            self.conversationHistoryDisplay.removeAll()
        }
        self.tableViewChat.reloadData()
        listeningStatus.text = "Cleared screen"
        if AppData.shared.config.mode == .Boswell {
            Utility.showLoader(status: "Loading audio...")
            let filename = Utility.getInterviewFilename()
            audioRecordManager.mergeAudioFiles(foldername: AppData.shared.config.isSilverMode ? FolderName.BoswellParents : FolderName.Boswell, filename: filename) { audioPlaybackFileURL, error in
                DispatchQueue.main.async {
                    Utility.hideLoader()
                    AudioRecorderManager.deleteAllAudioFileFrom(directory: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio)
                    self.updateAppMode(isUpdateMode: true, previousMode: .Boswell)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.listeningStatus.text = ""
        }
    }

    func speakApple(text: String) {
        // TODO: Tested do{} below per https://stackoverflow.com/questions/49208291/failure-starting-audio-queue-%E2%89%A5%CB%9A%CB%9B%CB%87
        // https://developer.apple.com/documentation/avfaudio/avaudiosession/1616503-categoryoptions
//        do{
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .duckOthers]) // or mixWithOthers or duckOthers or defaultToSpeaker or interruptSpokenAudioAndMixWithOthers (suggested duckOthers)
//            try audioSession.setMode(AVAudioSession.Mode.default)
//            try audioSession.setActive(true)
//            //try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
//        }catch {
//            print(error)
//        }
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-UK") // or "en-US" or other
        speechUtterance.rate = 0.5
        //speechUtterance.pitchMultiplier = 2
        if !self.soundButton.isSelected {
            speechUtterance.volume = 1
        }
        else {
            speechUtterance.volume = 0
        }
        //speechUtterance.volume = 1
        DispatchQueue.main.async {
            self.currentSpeechText = text
            self.speechSynthesizer.speak(speechUtterance)
            if AppData.shared.config.mode == .Boswell {
                self.storeAIResponseAudio(text: text) // Store AI Response to PlaybackAudio Directory if the mode is Boswell interview
            }
        }
    }
    
    func storeAIResponseAudio(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-UK") // or "en-US" or other
        speechUtterance.rate = 0.5
        if !self.soundButton.isSelected {
            speechUtterance.volume = 1
        }
        else {
            speechUtterance.volume = 0
        }
        var output: AVAudioFile?
        self.speechSynthesizer.write(speechUtterance) { (buffer: AVAudioBuffer) in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                fatalError("unknown buffer type: \(buffer)")
            }
            if pcmBuffer.frameLength == 0 {
                // done
                print("done")
                output = nil // Finish AI response recording
            } else {
                // append buffer to file
                do  {
                    if output == nil, let directoryURL = Utility.getDirectoryURL(name: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) {
                        let audioFileName = AudioRecorderManager.getFilename(isUser: false)
                        let filename = directoryURL.appendingPathComponent("\(audioFileName).m4a")
                        output = try AVAudioFile(
                            forWriting: filename,
                            settings: pcmBuffer.format.settings,
                            commonFormat: .pcmFormatInt16,
                            interleaved: false)
                    }
                    try output?.write(from: pcmBuffer)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func speakElevenLabs(text: String) {
        //self.updateRecordButton(enable: false, title: "Preparing...")
        var content = text
        var isShowBackground: Bool = false
        if let range = content.range(of: "-*---photo-question:") {
            isShowBackground = true
            let upperBound = content.index(range.upperBound, offsetBy: 8)
            let modifiedRange = range.lowerBound..<upperBound
            content.removeSubrange(modifiedRange)
            content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if APIManager.shared.elevenLabAPIKey != "" && APIManager.shared.elevenLabVoiceId != "" {
            APIManager.shared.speakElevenLabs(text: content) { [weak self] tempAudioURL, error in
                guard let weakSelf = self else { return }
                Utility.hideLoader()
                weakSelf.addRow(content: text, role: .assistant, isDisplay: true)
                if weakSelf.soundButton.isSelected {
                    weakSelf.finishThinking()
                }
                if isShowBackground {
                    if let backgroundImage = weakSelf.getBackgroundImage(isParentPhoto: AppData.shared.config.isSilverMode) {
                        weakSelf.setBackgroundImage(image: backgroundImage)
                        if let last = weakSelf.boswellConversationHistory.last, let lastDiplay = weakSelf.boswellConversationHistoryDisplay.last {
                            last.backgroundImage = backgroundImage
                            lastDiplay.backgroundImage = backgroundImage
                        }
                    }
                    else {
                        weakSelf.setBackgroundImage()
                    }
                }
                else {
                    weakSelf.setBackgroundImage()
                }
                weakSelf.showAddPhotoInviteDialog()
                if let audioURL = tempAudioURL {
                    do {
                        if let directoryURL = Utility.getDirectoryURL(name: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) {
                            let audioFileName = AudioRecorderManager.getFilename(isUser: false)
                            let filename = directoryURL.appendingPathComponent("\(audioFileName).mp3")
                            if FileManager.default.fileExists(atPath: filename.path) {
                                try FileManager.default.removeItem(atPath: filename.path)
                            }
                            try FileManager.default.moveItem(atPath: audioURL.path, toPath: filename.path)
                            if weakSelf.isPlayingIntroAudio {
                                weakSelf.elevenLabAudioURL = filename
                            }
                            else {
                                weakSelf.stopAudio()
                                weakSelf.isSpeakingAI = true
                                weakSelf.playAudio(url: filename)
                            }
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                        weakSelf.speakAppleIfElevenLabsFailed(content: content, isShowBackground: isShowBackground)
                    }
                }
                else {
                    print(error?.localizedDescription ?? "data is nil")
                    weakSelf.speakAppleIfElevenLabsFailed(content: content, isShowBackground: isShowBackground)
                }
            }
        }
        else {
            self.speakAppleIfElevenLabsFailed(content: content, isShowBackground: isShowBackground)
        }
    }
    
    func speakAppleIfElevenLabsFailed(content: String, isShowBackground: Bool) {
        Utility.hideLoader()
        if self.soundButton.isSelected {
            self.finishThinking()
        }
        if isShowBackground {
            if let backgroundImage = self.getBackgroundImage(isParentPhoto: AppData.shared.config.isSilverMode) {
                self.setBackgroundImage(image: backgroundImage)
                if let last = self.boswellConversationHistory.last, let lastDiplay = self.boswellConversationHistoryDisplay.last {
                    last.backgroundImage = backgroundImage
                    lastDiplay.backgroundImage = backgroundImage
                }
            }
            else {
                self.setBackgroundImage()
            }
        }
        else {
            self.setBackgroundImage()
        }
        self.isSpeakingAI = true
        self.speakApple(text: content)
    }
    
    func playAudio(url: URL) {
        // Play audio using AVPlayer
        self.audioPlayerItem = AVPlayerItem(url: url)
        self.audioPlayer = AVPlayer(playerItem: self.audioPlayerItem!)
        self.audioPlayer?.play()
        self.audioPlayer?.isMuted = self.soundButton.isSelected
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audioPlayerItem!)
    }
    
    func stopAudio() {
        if self.audioPlayer != nil {
            self.audioPlayer?.pause()
            self.audioPlayer?.replaceCurrentItem(with: nil)
            self.audioPlayer = nil
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        if recognitionRequest != nil {
            recognitionRequest?.endAudio()
            recognitionRequest = nil
        }
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
    
    func startRecording() {
        do {
            let audioFileName = AudioRecorderManager.getFilename(isUser: true) // Get filename
            if let directoryURL = Utility.getDirectoryURL(name: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio) {
                let audioFilename = directoryURL.appendingPathComponent("\(audioFileName).m4a")
                let file = try AVAudioFile(forWriting: audioFilename, settings: audioEngine.inputNode.inputFormat(forBus: 0).settings)
                
                let inputNode = audioEngine.inputNode
                let recordingFormat = inputNode.inputFormat(forBus: 0)
                
                startRecordingTime = Date().timeIntervalSinceReferenceDate
                
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                    if self.recognitionRequest != nil {
                        self.recognitionRequest!.append(buffer)
                    }
                    // Check if the audio level is below the silence threshold
                    let audioLevel = self.calculateAudioLevel(buffer: buffer)
                    if audioLevel < self.silenceThreshold {
                        print("audioLevel: ", audioLevel)
                        let elapsedTime = Date().timeIntervalSinceReferenceDate - self.startRecordingTime
                        if elapsedTime >= self.silenceDuration {
                            DispatchQueue.main.async {
                                self.startRecordingTime = Date().timeIntervalSinceReferenceDate
                                if self.textView.text.isEmpty {
                                    AudioRecorderManager.removeLastAudioFile()
                                }
                                self.recordButtonTapped(self.recordButton)
                            }
                        }
                    } else {
                        print("audioLevel: resert time: ", audioLevel)
                        self.startRecordingTime = Date().timeIntervalSinceReferenceDate
                    }
                    if AppData.shared.config.mode == .Boswell {
                        //Start to record user speech if the mode is Boswell interview
                        do {
                            try file.write(from: buffer)
                        }
                        catch let error {
                            print(error)
                        }
                    }
                }
                audioEngine.prepare()
                try audioEngine.start()
                listeningStatus.text = "Listening..."
                
                recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                recognitionRequest!.addsPunctuation = true
                recognitionRequest!.shouldReportPartialResults = true
                //if AppData.shared.config.mode == .Boswell {
                    //audioRecordManager.startRecording() //Start to record user speech if the mode is Boswell interview
                //}
                recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
                    var isFinal = false
                    if let result = result {
                        // TODO: Ensure font color is gray
                        let userPromptFontColor = UserDefaultsManager.getUserPromptFontColor()
                        let userPromptFontSize = CGFloat(UserDefaultsManager.getUserPromptFontSize())
                        let userPromptFontWeight = UserDefaultsManager.getUserPromptFontWeight()
                        let userPromptFont = userPromptFontWeight == "normal" ?  UIFont(name: "Lato-Regular", size: userPromptFontSize)! :  UIFont(name: "Lato-Bold", size: userPromptFontSize)!

                        self.textView.font = userPromptFont
                        self.textView.textColor = UIColor(hex: userPromptFontColor) // Set text color to gray
                        self.textView.text = result.bestTranscription.formattedString
                        isFinal = result.isFinal
                    }
                    if error != nil || isFinal {
                         self.stopRecording()
                    }
                }
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func calculateAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        let bufferPointer = UnsafeMutableBufferPointer<Float>(audioBuffer)

        let bufferSize = Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.size
        let audioLevels = Array(bufferPointer[0..<bufferSize])

        let averagePower = audioLevels.reduce(0.0, { $0 + abs($1) }) / Float(bufferSize)
        return averagePower
    }
    
    func stopUserRecordingIfAnyAction() {
        if audioEngine.isRunning {
            self.stopRecording()
            self.showSpeakTextView(isShow: false)
            self.textView.text = ""
            listeningStatus.text = ""
            self.updateRecordButton(enable: self.recordButton.isEnabled, title: self.getRecordButtonTitle())
        }
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if let buttonTitle = self.recordButton.title(for: .normal), buttonTitle == "Start Over" {
            let birthdate: Date? = AppData.shared.config.isSilverMode ? UserDefaultsManager.getParentBirthdate() : UserDefaultsManager.getBirthdate()
            let firstname: String? = AppData.shared.config.isSilverMode ? UserDefaultsManager.getParentFirstname() : UserDefaultsManager.getFirstname()
            if AppData.shared.config.mode == .Boswell {
                if let index = self.boswellConversationHistory.lastIndex(where: {$0.role == .assistant && $0.isError == true && $0.isAddToHistory == false}) {
                    self.boswellConversationHistory.remove(at: index)
                }
                if let index = self.boswellConversationHistoryDisplay.lastIndex(where: {$0.role == .assistant && $0.isError == true && $0.isAddToHistory == false}) {
                    self.boswellConversationHistoryDisplay.remove(at: index)
                }
                self.tableViewChat.reloadData()
            }
            else {
                if let index = self.conversationHistory.lastIndex(where: {$0.role == .assistant && $0.isError == true && $0.isAddToHistory == false}) {
                    self.conversationHistory.remove(at: index)
                }
                if let index = self.conversationHistoryDisplay.lastIndex(where: {$0.role == .assistant && $0.isError == true && $0.isAddToHistory == false}) {
                    self.conversationHistoryDisplay.remove(at: index)
                }
                self.tableViewChat.reloadData()
            }
            
            if let tBirthdate = birthdate, let tFirstname = firstname {
                self.startBoswellInterview(birthdate: tBirthdate, firstname: tFirstname)
            }
            else {
                self.openProfileScreen(isParentProfile: AppData.shared.config.isSilverMode)
            }
            return
        }
        // Check if the audio engine is running (i.e., currently recording)
        if audioEngine.isRunning {
            // Stop the audio engine and end the recognition request
            self.stopRecording()
            self.showSpeakTextView(isShow: false)
            if self.textView.text!.isEmpty {
                listeningStatus.text = ""
                self.updateRecordButton(enable: self.recordButton.isEnabled, title: self.getRecordButtonTitle())
                return
            }
            self.addRow(content: self.textView.text!, role: .user)
            self.textView.text = ""
            if APIManager.shared.openAI_APIKey != "" {
                if AppData.shared.config.mode == .CreateImage {
                    if let lastPrompt = self.conversationHistory.last, let content = lastPrompt.content {
                        self.createImage(text: content)
                    }
                }
                else {
                    self.sendToChatGPT(apiModel: .ChatGPT_4)
                }
            }
            else {
                //Open API Key Popup
                self.openAIAPIKeyScreen()
            }
        } else {
            // Start recording user speech
            self.stopAudio()
            self.textView.text = ""
            self.showSpeakTextView(isShow: true)
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            self.isSoundSettingUpdated = false
            stopRecording()
            startRecording()
            // Update the record button title to indicate recording has started
            updateRecordButton(enable: self.recordButton.isEnabled, title: "Stop Recording")
        }
    }
    
    func showSpeakTextView(isShow: Bool) {
        self.textView.isHidden = !isShow
        self.tableViewChat.isHidden = isShow
    }

    // Update button color based on enable/disable
    func updateRecordButton(enable: Bool, title: String? = nil) {
        self.recordButton.isEnabled = enable
        self.navigationItem.leftBarButtonItem?.isEnabled = enable
        self.navigationItem.titleView?.isUserInteractionEnabled = enable
        if let buttonTitle = title {
            self.recordButton.setTitle(buttonTitle, for: .normal)
            self.recordButton.setTitle(buttonTitle, for: .disabled)
        }
        self.navigationItem.leftBarButtonItem?.isEnabled = enable
        var arrayHistory: [AIPromptModel] = []
        if AppData.shared.config.mode == .Boswell {
            arrayHistory = self.boswellConversationHistoryDisplay
        }
        else {
            arrayHistory = self.conversationHistoryDisplay
        }
        if arrayHistory.count > 0 {
            self.btnShare.isEnabled = enable
        }
        else {
            self.btnShare.isEnabled = false
        }
    }
    
    func createImage(text: String) {
        // Send the recorded speech to the ChatGPT API for create image
        self.showSpeakTextView(isShow: false)
        self.listeningStatus.text = "Thinking..."
        self.updateRecordButton(enable: false, title: "AI thinking...")
        if self.apiTask != nil {
            self.apiTask?.cancel()
        }
        self.apiTask = APIManager.shared.createImage(text: text, completion: { responseImage, error in
            DispatchQueue.main.async {
                self.updateRecordButton(enable: true, title: self.getRecordButtonTitle())
                self.listeningStatus.text = "" // clear the listening status text field
                if let error = error {
                    var errorMessage: String = ""
                    if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                        if AppData.shared.config.apiModel == .ChatGPT_4 {
                            errorMessage = "ChatGPT-4 may be temporarily unavailable. Try switching to ChatGPT-3.5."
                        }
                        else {
                            errorMessage = "ChatGPT may be temporarily unavailable. Try again later."
                        }
                    }
                    else {
                        errorMessage = "Error: \(error.localizedDescription)"
                    }
                    self.addRow(content: errorMessage, role: .assistant, isAddToHisoty: false, isError: true)
                } else if let image = responseImage {
                    self.addRow(content: nil, role: .assistant, isAddToHisoty: false, image: image)
                }
            }
        })
    }
    
    func finishThinking() {
        self.updateRecordButton(enable: true, title: self.getRecordButtonTitle())
        self.listeningStatus.text = "" // clear the listening status text field
    }
    
    func sendToChatGPT(apiModel: BoswellModeModel.APIModel = AppData.shared.config.apiModel, isShowLoader: Bool = true) {
        // Send the recorded speech to the ChatGPT API
        self.showSpeakTextView(isShow: false)
        self.listeningStatus.text = "Thinking..."
        self.updateRecordButton(enable: false, title: "AI thinking...")
        if self.apiTask != nil {
            self.apiTask?.cancel()
        }
        var arrayHistory: [AIPromptModel] = []
        if AppData.shared.config.mode == .Boswell {
            arrayHistory = self.boswellConversationHistory
        }
        else {
            arrayHistory = self.conversationHistory
        }
        if isShowLoader {
            Utility.showLoader(status: "Thinking...")
        }
        else {
            Utility.updateLoader(status: "Trying Again...")
        }
        self.apiTask = APIManager.shared.sendToChatGPT(history: arrayHistory, apiModel: apiModel) { response, error in
            DispatchQueue.main.async {
                if let error = error as? NSError {
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                        Utility.hideLoader()
                        return
                    }
                    if apiModel == .ChatGPT_4 {
                        self.sendToChatGPT(apiModel: .ChatGPT_3_5, isShowLoader: false)
                    }
                    else {
                        Utility.hideLoader()
                        self.finishThinking()
                        var errorMessage: String = ""
                        if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                            errorMessage = "ChatGPT may be temporarily unavailable. Try again later."
                        }
                        else {
                            errorMessage = "OpenAI's services appear to be unresponsive. Let's try again later."
                        }
                        self.addRow(content: errorMessage, role: .assistant, isAddToHisoty: false, isError: true)
                        self.addStartOverButton()
                    }
                } else if let response = response {
                    self.parseChatGPT(response: response, apiModel: apiModel)
                }
                else {
                    Utility.hideLoader()
                    self.finishThinking()
                }
            }
        }
    }
    
    func addStartOverButton() {
        if AppData.shared.config.mode == .Boswell {
            self.updateRecordButton(enable: true, title: "Start Over")
        }
    }
    
    func parseChatGPT(response: [String: Any], apiModel: BoswellModeModel.APIModel) {
        if let choices = response["choices"] as? [[String: Any]],
           let firstChoice = choices.first {
            var aiResponseText: String = ""
            if let text = firstChoice["text"] as? String {
                aiResponseText = text
            }
            else if let message = firstChoice["message"] as? [String: Any], let text = message["content"] as? String {
                aiResponseText = text
            }
            if !aiResponseText.isEmpty {
                print("text is: \(aiResponseText)")
                let aiResponse = aiResponseText.replacingOccurrences(of: "AI:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                // Speak the AI's response
                if AppData.shared.config.mode != .Boswell {
                    self.addRow(content: aiResponse, role: .assistant, isDisplay: true)
                    Utility.hideLoader()
                    if self.soundButton.isSelected {
                        self.finishThinking()
                    }
                    self.isSpeakingAI = true
                    self.speakApple(text: aiResponse)
                }
                else {
                    self.speakElevenLabs(text: aiResponse)
                }
            }
            else {
                Utility.hideLoader()
                self.finishThinking()
            }
        }
        else if let error = response["error"] as? [String: Any], let type = error["type"] as? String {
            if apiModel == .ChatGPT_4 {
                self.sendToChatGPT(apiModel: .ChatGPT_3_5, isShowLoader: false)
            }
            else {
                Utility.hideLoader()
                self.finishThinking()
                print("error: ", error)
                if type == "invalid_request_error" {
                    DispatchQueue.main.async {
                        self.openAIAPIKeyScreen()
                    }
                }
                let errorMessage = "OpenAI's services appear to be unresponsive. Let's try again later."
                self.addRow(content: errorMessage, role: .assistant, isAddToHisoty: false, isError: true)
                self.addStartOverButton()
            }
        }
        else {
            if apiModel == .ChatGPT_4 {
                self.sendToChatGPT(apiModel: .ChatGPT_3_5, isShowLoader: false)
            }
            else {
                Utility.hideLoader()
                self.finishThinking()
                let errorMessage = "OpenAI's services appear to be unresponsive. Let's try again later."
                self.addRow(content: errorMessage, role: .assistant, isAddToHisoty: false, isError: true)
                self.addStartOverButton()
            }
        }
    }

    func isQuestion(_ text: String) -> Bool {
        let questionWords = ["who", "what", "where", "when", "why", "how", "can", "is"]
        let words = text.lowercased().split(separator: " ")

        if let firstWord = words.first {
            let firstWordStripped = firstWord.trimmingCharacters(in: .punctuationCharacters)
            if questionWords.contains(firstWordStripped) {
                return true
            }
        }
        return false
    }

}

extension ViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}

//extension ViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.imgBackground
//    }
//}
