//
//  Alarm.swift
//  Prey
//
//  Created by Javier Cala Uribe on 16/05/16.
//  Copyright © 2016 Fork Ltd. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class Alarm : PreyAction, AVAudioPlayerDelegate {
 
    // MARK: Properties

    var audioPlayer: AVAudioPlayer {
        
        let musicFile   = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("siren", ofType: "mp3")!)
        var player      = AVAudioPlayer()
        
        do {
            player =  try AVAudioPlayer.init(contentsOfURL: musicFile)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            
        } catch let error as NSError {
            print("AVAudioPlayer error reading file: \(error.localizedDescription)")
        }
        
        return player
    }
    
    // MARK: Functions

    // Prey command
    override func start() {
        print("Playing alarm now")
        
        do {
            // Config AVAudioSession on device
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

            // Play sound
            audioPlayer.play()
            
            // Send start action
            let params = getParamsTo(kAction.ALARM.rawValue, command: kCommand.START.rawValue, status: kStatus.STARTED.rawValue)
            self.sendData(params, toEndpoint: responseDeviceEndpoint)
            
        } catch let error as NSError {
            print("AVAudioSession error: \(error.localizedDescription)")
        }
    }
    
    // MARK: AVAudioPlayerDelegate

    // Did Finish Playing
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        // Send stop action
        let params = getParamsTo(kAction.ALARM.rawValue, command: kCommand.STOP.rawValue, status: kStatus.STOPPED.rawValue)
        self.sendData(params, toEndpoint: responseDeviceEndpoint)
    }
    
    // Player Decode Error Did Occur
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        // Send stop action
        let params = getParamsTo(kAction.ALARM.rawValue, command: kCommand.STOP.rawValue, status: kStatus.STOPPED.rawValue)
        self.sendData(params, toEndpoint: responseDeviceEndpoint)
    }
}