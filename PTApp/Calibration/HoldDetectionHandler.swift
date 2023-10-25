//
//  HoldDetectionHandler.swift
//  PTApp
//
//  Created by Sonya Jin on 10/25/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import UIKit
import Vision
import Foundation
class HoldDetectionHandler {
    
    var previousPose: VNHumanBodyPoseObservation?
    var holdStartTime: Date?
    let holdDuration: TimeInterval = 2.0 // for example, 2 seconds


    func detectHold(currentPose: VNHumanBodyPoseObservation) -> Bool {
        guard let previousPose = previousPose else {
            self.previousPose = currentPose
            return false
        }
        
        if posesAreSimilar(pose1: previousPose, pose2: currentPose) {
            if holdStartTime == nil {
                holdStartTime = Date()
            } else if Date().timeIntervalSince(holdStartTime!) >= holdDuration {
                resetHoldDetection()
                return true // Successful hold detected
            }
        } else {
            resetHoldDetection()
        }
        
        self.previousPose = currentPose
        return false
    }


    func resetHoldDetection() {
        previousPose = nil
        holdStartTime = nil
    }
    
    func posesAreSimilar(pose1: VNHumanBodyPoseObservation, pose2: VNHumanBodyPoseObservation) -> Bool {
        // Extract joint points from the poses
        var joints1: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        var joints2: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        for jointName in pose1.availableJointNames {
            if let point1 = try? pose1.recognizedPoint(jointName), point1.confidence > 0.5 {
                joints1[jointName] = point1.location
            }
            if let point2 = try? pose2.recognizedPoint(jointName), point2.confidence > 0.5 {
                joints2[jointName] = point2.location
            }
        }
        
        return comparePoses(joints1: joints1, joints2: joints2)
    }

    func comparePoses(joints1: [VNHumanBodyPoseObservation.JointName: CGPoint], joints2: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> Bool {
        let threshold: CGFloat = 0.05 // This threshold determines how much difference between poses is acceptable
        
        for (jointName, point1) in joints1 {
            if let point2 = joints2[jointName] {
                let dx = point1.x - point2.x
                let dy = point1.y - point2.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance > threshold {
                    return false
                }
            }
        }
        
        return true
    }

}
