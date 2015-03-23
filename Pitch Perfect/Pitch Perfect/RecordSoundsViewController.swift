//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by William Brosnan on 3/15/15.
//  Copyright (c) 2015 William Brosnan. All rights reserved.
//
//  There are three states to this view...
//      1 - Waiting to start recording
//      2 - Recording, okay to hit play or pause
//      3 - Paused, only option is to resume. Go back to state 2 after resuming
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // Globals
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    // Button outlets
    @IBOutlet weak var RecordingStatus: UILabel!
    @IBOutlet weak var stopButton: UIButton! // TODO: rename to playButton. NOTE: rename doesn't work in swift yet
    @IBOutlet weak var MicrophoneButton: UIButton! // TODO: rename microphone button to recordButton
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var ResumeButton: UIButton!
    
    // Update the intruction/warning text
    func updateInstructions (label: String)
    {
        print("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        print(" (label=")
        print(label)
        println(")")
        
        dispatch_async(dispatch_get_main_queue(), {self.RecordingStatus.text = label})
    }
    
    // Display appropriate button from the mutually exclusive list {record, pause, resume}
    // and the matching state for the play button
    func refreshButtons (displayRecordButton: Bool, displayPauseButton: Bool, displayResumeButton: Bool)
    {
        print("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        print(" (displayRecordButton=")
        print(displayRecordButton)
        print(", displayPauseButton=")
        print(displayPauseButton)
        println(")")
        
        // Defaults - hide all buttons
        var microphoneButtonEnabled = false
        var microphoneButtonHidden = true
        var pauseButtonEnabled = false
        var pauseButtonHidden = true
        var resumeButtonEnabled = false
        var resumeButtonHidden = true
        var stopButtonEnabled = false
        var stopButtonHidden = true
        
        // Decide which button to display
        if (displayRecordButton)
        {
            // Record ON
            // Would have been code review task 4 if not already handled
            updateInstructions ("Tap to Record")
            
            microphoneButtonEnabled = true
            microphoneButtonHidden = false
        }
        else if (displayPauseButton)
        {
            // Pause ON
            updateInstructions ("Tap to Pause or Press Play Button")
            
            pauseButtonEnabled = true
            pauseButtonHidden = false

            stopButtonEnabled = true
            stopButtonHidden = false
        }
        else if (displayResumeButton)
        {
            // Resume ON
            updateInstructions ("Tap to Resume")
            
            resumeButtonEnabled = true
            resumeButtonHidden = false
        }
        // else NO buttons ON
        
        // Set resulting values
        MicrophoneButton.enabled = microphoneButtonEnabled
        MicrophoneButton.hidden = microphoneButtonHidden

        PauseButton.enabled = pauseButtonEnabled
        PauseButton.hidden = pauseButtonHidden
        
        ResumeButton.enabled = resumeButtonEnabled
        ResumeButton.hidden = resumeButtonHidden
        
        stopButton.enabled = stopButtonEnabled
        stopButton.hidden = stopButtonHidden
    }
    
    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // NOTE: This is too early to access the buttons
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
    }
    
    // Method where we show/hide things
    override func viewWillAppear(animated: Bool)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        refreshButtons(true, displayPauseButton: false, displayResumeButton: false)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        refreshButtons(true, displayPauseButton: false, displayResumeButton: false)
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
    }
    
    // State 1 -> 2
    // Start recording (toggle for start recording button) - go to pause with stop
    @IBAction func StartRecording(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        refreshButtons(false, displayPauseButton: true, displayResumeButton: false)

        // Create a unique filename for the recording and convert to a URL with path
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        // Start recording users voice
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self // So we can detect when audio recording has finished
        audioRecorder.meteringEnabled = true
        audioRecorder.record()
    }
    
    // State 2 -> 3
    // This is called when the pause button is pressed - go to resume without stop
    @IBAction func pause(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        refreshButtons(false, displayPauseButton: false, displayResumeButton: true)

        audioRecorder.pause()
    }
    

    // State 3 -> 2
    // This is called when resume button pressed - go back to pause with stop
    @IBAction func resume(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")

        refreshButtons(false, displayPauseButton: true, displayResumeButton: false)
        
        audioRecorder.record()
    }
    
    // This is called when audio stops recording - time to switch views
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        refreshButtons(false, displayPauseButton: false, displayResumeButton: false)

        if (flag)
        {
            // Recording complete
            updateInstructions ("Recording Complete")

            // Load the recorded audio file path
            // Code Review Item 1
            #if CLASS_WITH_SIMPLE_CONTRUCTOR
                recordedAudio = RecordedAudio()
                recordedAudio.filePathUrl = recorder.url
                recordedAudio.title = recorder.url.lastPathComponent
            #else
                let recordedAudio = RecordedAudio (filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            #endif
    
            // Move to the next scene aka pass via segue
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else
        {
            // Recording failed
            updateInstructions ("Recording Failed")
        }
    }
    
    // This is called when stop recording button pressed - need to wait until audio recording done
    // before switching views
    @IBAction func StopRecording(sender: UIButton)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        
        updateInstructions ("Waiting Until Recording Complete")
        refreshButtons(false, displayPauseButton: false, displayResumeButton: false)

        // Stop recording users voice
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    // Called right before switch to next view - sets up data to pass to next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        println(segue.identifier)
        
        if (segue.identifier == "stopRecording")
        {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    #if INCLUDED_FOR_FLOW_DEBUGGING__
        override func viewWillDisappear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
            
        }
        
        override func viewDidDisappear(animated: Bool)
        {
            println("\(__FUNCTION__) in \(__FILE__.lastPathComponent.stringByDeletingPathExtension)")
        }
    #endif
}

