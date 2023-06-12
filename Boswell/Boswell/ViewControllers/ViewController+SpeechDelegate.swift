//
//  ViewController+SpeechDelegate.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import UIKit
import AVFoundation
import Speech
import Foundation

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("didFinish")
        // restart speaking from the last stop speech. if speech available
        if let last = self.spokenTextRange, let text = self.currentSpeechText, text != "", self.isSoundSettingUpdated {
            self.isSoundSettingUpdated = false
            print("Last Spoken Range: ", last)
            let startIndex = last.location + last.length // random for this example
            let endIndex = text.count
            let start = String.Index(utf16Offset: startIndex, in: text)
            let end = String.Index(utf16Offset: endIndex, in: text)
            let substring = String(text[start..<end])
            if substring != "" && substring.count > 0 {
                self.speakApple(text: substring)
            }
        }
        if self.isSpeakingAI == true {
            self.isSpeakingAI = false
            self.finishThinking()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("didCancel")
    }

    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        self.spokenTextRange = characterRange
        print("characterRange")
    }
}
