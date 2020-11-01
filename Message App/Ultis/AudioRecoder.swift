//
//  AudioRecoder.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import AVFoundation

class AudioRecoder: NSObject, AVAudioRecorderDelegate {
    var recordingSesssion: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let shared = AudioRecoder()
    private override init() {
        super.init()
        checkForRecordPermisson()
    }
    
    func checkForRecordPermisson() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (isAllowed) in
                self.isAudioRecordingGranted = isAllowed
            }
        default:
            break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSesssion = AVAudioSession.sharedInstance()
            do {
                try recordingSesssion.setCategory(.playAndRecord, mode: .default)
                try recordingSesssion.setActive(true)
            } catch {
                print("error setting up audio recorder,",error)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName + ".m4a", isDirectory: false)
        let settings = [
            //Audio format
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            //strart recored and save file under audioFileName url
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error recording", error)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
