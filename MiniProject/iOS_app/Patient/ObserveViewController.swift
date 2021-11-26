//
//  ObserveViewController.swift
//  Patient
//
//  Created by Watcharavit Lapinee on 23/11/2564 BE.
//

import UIKit
import CoreMotion
import CocoaMQTT
import AVFoundation

enum Topic: String {
    case alertMove
    case alertFalling
    case activity
}

class ObserveViewController: UIViewController {

    @IBOutlet private var eventLabel: UILabel!
    @IBOutlet private var activityLabel: UILabel!
    private var mqtt: CocoaMQTT!
    private var player: AVAudioPlayer?
    var resetEventTimer: Timer!
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mqttSetting()
        eventLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playSound()
    }
    
    private func mqttSetting() {
        let clientID = "boom"
        let host = "qa18afea.ap-southeast-1.emqx.cloud"
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: 15198)
        mqtt.username = "boom"
        mqtt.password = "123456"
        mqtt.keepAlive = 360
        mqtt.delegate = self
        _ = mqtt.connect()
        
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "alert01", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)

            audioPlayer.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func resetEvent() {
        eventLabel.text = ""
    }

}

extension ObserveViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        mqtt.subscribe([("alertMove", CocoaMQTTQoS.qos0),
                        ("alertFalling", CocoaMQTTQoS.qos0),
                        ("activity", CocoaMQTTQoS.qos0)])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let string = String(bytes: message.payload, encoding: .utf8) else { return }
        
        if message.topic == Topic.alertMove.rawValue {
            eventLabel.text = "Time to move"
            playSound()
            self.perform(#selector(resetEvent), with: nil, afterDelay: 7)
        } else if message.topic == Topic.alertFalling.rawValue {
            eventLabel.text = "Fall from bed"
            playSound()
            self.perform(#selector(resetEvent), with: nil, afterDelay: 7)
        } else if message.topic == Topic.activity.rawValue {
            activityLabel.text = string
        }
    }
}
