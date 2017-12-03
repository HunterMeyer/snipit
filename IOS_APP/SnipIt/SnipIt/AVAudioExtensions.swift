//
//  AVAudioExtensions.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/7/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import AVFoundation

extension AVAudioPlayer {
    func togglePlayBack(rate: Float) {
        self.currentTime = 0.0
        if (self.playing && self.rate == rate) {
            self.stop()
        }else {
            self.rate = rate
            self.play()
        }
    }
}

extension AVAudioEngine {
    func playAudioWithVariablePitch(pitch: Float, audioFile: AVAudioFile) {
        self.stop()
        self.reset()
        var audioPlayerNode = AVAudioPlayerNode()
        self.attachNode(audioPlayerNode)
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        self.attachNode(changePitchEffect)
        self.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        self.connect(changePitchEffect, to: self.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        self.startAndReturnError(nil)
        audioPlayerNode.play()
    }
}
