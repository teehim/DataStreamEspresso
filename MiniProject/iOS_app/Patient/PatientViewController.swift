//
//  ViewController.swift
//  Patient
//
//  Created by Watcharavit Lapinee on 7/11/2564 BE.
//

import UIKit
import CoreMotion
import CocoaMQTT
import AVFoundation

class PatientViewController: UIViewController {
    
    private let motion = CMMotionManager()
    private let deviceMotion = CMDeviceMotion()
    private var timer: Timer!
    private var mqtt: CocoaMQTT!
    private var player: AVAudioPlayer?
    
    private var isStart: Bool = false
    
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var sensorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mqttSetting()
        statusLabel.text = ""
    }

    private func startAccelerometers() {

        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 0.3
            self.motion.startAccelerometerUpdates()
            motion.startGyroUpdates()
            motion.startDeviceMotionUpdates()
            
            var accelerometerSensor = ""
            
           // Configure a timer to fetch the data.
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                
                if let data = self.motion.accelerometerData {
                   let x = data.acceleration.x
                   let y = data.acceleration.y
                   let z = data.acceleration.z
                   accelerometerSensor = "\(x),\(y),\(z)"

                }
                
                if let gyroData = self.motion.gyroData {
                    let x = gyroData.rotationRate.x
                    let y = gyroData.rotationRate.y
                    let z = gyroData.rotationRate.z
                    
                    let pitch = self.motion.deviceMotion?.attitude.pitch ?? 0
                    let yaw = self.motion.deviceMotion?.attitude.yaw ?? 0
                    let roll = self.motion.deviceMotion?.attitude.roll ?? 0
                    
                    let timestamp = NSDate().timeIntervalSince1970
                    let sensorMessage = "\(timestamp),\(accelerometerSensor),\(x),\(y),\(z),\(pitch),\(yaw),\(roll),0"

                    self.sensorLabel.text = sensorMessage
                    let message = CocoaMQTTMessage(topic: "sensorData", string: sensorMessage)
                    self.mqtt.publish(message)

                }
            }
        }
     }
    
    private func stopSensor() {
        motion.stopGyroUpdates()
        motion.stopDeviceMotionUpdates()
        motion.stopAccelerometerUpdates()
    }
    
    private func mqttSetting() {
        let clientID = "watcharavit"
        let host = "qa18afea.ap-southeast-1.emqx.cloud"
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: 15198)
        mqtt.username = "watcharavit"
        mqtt.password = "bm07739200"
        mqtt.keepAlive = 360
        mqtt.delegate = self
        _ = mqtt.connect()
    }
    
    @IBAction func connectAction(_ sender: Any) {
        

        if isStart {
            isStart = false
            stopSensor()
        } else {
            isStart = true
            startAccelerometers()
        }
        
        statusLabel.text = isStart ? "Started": "Stoped"

    }
    
    @IBAction func stopAction(_ sender: Any) {
        stopSensor()
        statusLabel.text = "Stoped"
    }
    
}

extension PatientViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
    
}

