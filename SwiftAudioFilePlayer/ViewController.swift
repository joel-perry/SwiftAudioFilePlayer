//
//  ViewController.swift
//  SwiftAudioFilePlayer
//
//  Created by Joel Perry on 1/16/15.
//  Copyright (c) 2015 Joel Perry. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    var audio = Audio()
    
    @IBAction func playPressed() {
        audio.playFile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class Audio: NSObject {
    var graph: AUGraph
    var filePlayerAU: AudioUnit
    var outputAU: AudioUnit
    
    override init () {
        graph = AUGraph()
        filePlayerAU = AudioUnit()
        outputAU = AudioUnit()
        
        super.init()
        
        NewAUGraph(&graph)
        
        // Add file player node
        var filePlayerNode = AUNode()
        var cd = AudioComponentDescription(componentType: OSType(kAudioUnitType_Generator),
                                            componentSubType: OSType(kAudioUnitSubType_AudioFilePlayer),
                                            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
                                            componentFlags: 0, componentFlagsMask: 0)
        AUGraphAddNode(graph, &cd, &filePlayerNode)
        
        // Add output node
        var outputNode = AUNode()

        cd.componentType = OSType(kAudioUnitType_Output)
        cd.componentSubType = OSType(kAudioUnitSubType_RemoteIO)
        AUGraphAddNode(graph, &cd, &outputNode)
        
        // Graph must be opened before we can get node info!
        AUGraphOpen(graph)
        AUGraphNodeInfo(graph, filePlayerNode, nil, &filePlayerAU)
        AUGraphNodeInfo(graph, outputNode, nil, &outputAU)
        
        
        AUGraphConnectNodeInput(graph, filePlayerNode, 0, outputNode, 0)
        AUGraphInitialize(graph)
        AUGraphStart(graph)
    }
    
    func playFile() {
        let url = NSBundle.mainBundle().URLForResource("Devil On A Good Day", withExtension: "mp3")
        
        var fileID = AudioFileID()
        AudioFileOpenURL(url, 1, 0, &fileID)
        
        // Step 1: schedule the file(s)
        // kAudioUnitProperty_ScheduledFileIDs takes an array of AudioFileIDs
        var filesToSchedule = [fileID]
        AudioUnitSetProperty(filePlayerAU,
                                AudioUnitPropertyID(kAudioUnitProperty_ScheduledFileIDs),
                                AudioUnitScope(kAudioUnitScope_Global), 0, filesToSchedule,
                                UInt32(sizeof(AudioFileID)))
        
        // Step 2: Schedule the regions of the file(s) to play
        // Swift forces us to fill out the structs completely, even if they are not used
        let smpteTime = SMPTETime(mSubframes: 0, mSubframeDivisor: 0,
                                    mCounter: 0, mType: 0, mFlags: 0,
                                    mHours: 0, mMinutes: 0, mSeconds: 0, mFrames: 0)
        
        var timeStamp = AudioTimeStamp(mSampleTime: 0, mHostTime: 0, mRateScalar: 0,
                                        mWordClockTime: 0, mSMPTETime: smpteTime,
                                        mFlags: UInt32(kAudioTimeStampSampleTimeValid), mReserved: 0)
        
        var region = ScheduledAudioFileRegion(mTimeStamp: timeStamp, mCompletionProc: nil,
                                                mCompletionProcUserData: nil, mAudioFile: fileID,
                                                mLoopCount: 0, mStartFrame: 0,
                                                mFramesToPlay: UInt32.max)
        
        AudioUnitSetProperty(filePlayerAU,
                                AudioUnitPropertyID(kAudioUnitProperty_ScheduledFileRegion),
                                AudioUnitScope(kAudioUnitScope_Global), 0, &region,
                                UInt32(sizeof(ScheduledAudioFileRegion)))
        
        // Step 3: Prime the file player
        var primeFrames: UInt32 = 0
        AudioUnitSetProperty(filePlayerAU,
                                AudioUnitPropertyID(kAudioUnitProperty_ScheduledFilePrime),
                                AudioUnitScope(kAudioUnitScope_Global), 0, &primeFrames,
                                UInt32(sizeof(UInt32)))
        
        // Step 4: Schedule the start time (-1 = now)
        timeStamp.mSampleTime = -1
        AudioUnitSetProperty(filePlayerAU,
                                AudioUnitPropertyID(kAudioUnitProperty_ScheduleStartTimeStamp),
                                AudioUnitScope(kAudioUnitScope_Global), 0,  &timeStamp,
                                UInt32(sizeof(AudioTimeStamp)))
    }
}
