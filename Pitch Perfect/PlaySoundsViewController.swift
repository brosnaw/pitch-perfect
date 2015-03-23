//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by William Brosnan on 3/21/15.
//  Copyright (c) 2015 William Brosnan. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    // Globals
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var audioPlayerNode:AVAudioPlayerNode!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        // Code Review Item 2 - removed hard coded movie quote

        // Grab the sound from the segue
        // Instantiate an AVAudioPlayer with the file we recorded
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true // Allow rate to be adjustable
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
    }
    
    // Play audio at specified rate
    func playAudioAtSpecifiedRate(rate: Float)
    {
        print("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension) rate:")
        println(rate)
        
        stopPlayback () // Good practice

        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }

    // Play slowly
    @IBAction func playSlowly(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        playAudioAtSpecifiedRate(0.5) // NOTE: (1.0) - Normal rate is good for testing effects
    }
    
    // Play fast
    @IBAction func playFast(sender: UIButton) {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        playAudioAtSpecifiedRate(2.0)
    }
    
    func playAudioWithVariablePitch (adjustment: Float)
    {
        stopPlayback () // Stop all audio
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        // Setup adjustment
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = adjustment // The range of values is -2400 to 2400.
        audioEngine.attachNode(changePitchEffect)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Play audio with effect
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    // Play chipmunk-style
    @IBAction func playChipmunk(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        playAudioWithVariablePitch (1000)
    }
    
    // Play the Dark Side
    @IBAction func playDarthSide(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        playAudioWithVariablePitch (-1000)
    }
    
    func playAudioWithReverb (adjustment: Float)
    {
        stopPlayback () // Stop all audio
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        // Setup adjustment
        var effect = AVAudioUnitReverb()
        effect.wetDryMix = adjustment
        audioEngine.attachNode(effect)
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        // Play audio with effect
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    // Play with reverb
    @IBAction func Reverb(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        playAudioWithReverb (50) // 0 (all dry) -> 100 (all wet)
    }
    
    func playAudioWithEcho(adjustment: Float)
    {
        stopPlayback () // Stop all audio
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Setup adjustment
        var effect = AVAudioUnitDelay()
        effect.feedback = adjustment // The default value is 50%. The valid range of values is -100% to 100%.
        audioEngine.attachNode(effect)
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        // Play audio with effect
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    // Play with echo
    @IBAction func Echo(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        playAudioWithEcho (0.50)
    }
    
    // Stop any playing sound on exit
    func stopPlayback ()
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        if (audioPlayer != nil)
        {
            audioPlayer.stop()
        }

        if (audioPlayerNode != nil)
        {
            // Would have been code review task 3 if not already handled
            audioPlayerNode.stop()
        }
    }
    
    // Stop button
    @IBAction func stopButton(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        stopPlayback () // Stop all audio
    }
    
    #if INCLUDED_FOR_FLOW_DEBUGGING__
        override func viewWillAppear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        }
        
        override func viewDidAppear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        }
        
        override func viewWillDisappear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

            stopPlayback () // Stop all audio
        }
        
        override func viewDidDisappear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        }
    #endif
}
