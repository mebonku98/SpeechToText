//
//  SpeechController.swift
//  SpeechToText
//
//  Created by Ankita Ghosh on 27/11/19.
//  Copyright © 2019 mebonku. All rights reserved.
//

import Foundation
import Speech

enum SpeechControllerError: Error {
    case noAudioInput
}

protocol SpeechControllerDelegate {
    func speechController(_ speechController: SpeechController, didRecogniseText text: String)
    func speechControllerdidEndTalking()
}

class SpeechController {
        
    private let speechRecognizer = SFSpeechRecognizer()!
    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var delegate: SpeechControllerDelegate?

    func startRecording() throws {
        guard speechRecognizer.isAvailable else {
            return
        }

        if let recognitionTask = recognitionTask {
            //cancel ongoing recognition task
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization({_ in})
            return
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        if(node.inputFormat(forBus: 0).channelCount == 0){
            NSLog("Not enough available inputs!")
            throw SpeechControllerError.noAudioInput
        }
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            buffer, _ in
            self.recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            throw SpeechControllerError.noAudioInput
        }
        
        var talkTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) {
            result, error in
            if let result = result {
                talkTimer.invalidate()
                talkTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
                print("Text: \(result.bestTranscription.formattedString)")
                self.delegate?.speechController(self, didRecogniseText: result.bestTranscription.formattedString)
            } else if let error = error {
                print("Recognition task error: \(error)")
            }
        }
    }
    
    @objc func fireTimer() {
        self.stopRecording()
        self.delegate?.speechControllerdidEndTalking()
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
