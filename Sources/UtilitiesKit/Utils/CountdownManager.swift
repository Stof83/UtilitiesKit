//
//  CountdownManager.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 28/06/23.
//

import Foundation

public struct CountdownManager {
    private static var countdownTimer: Timer?
    
    public static func startCountdown(to endDate: Date?, updateHandler: ((TimeInterval) -> Void)? = nil, completion: @escaping () -> Void) {
        guard let endDate = endDate else { return }
        
        stopCountdown()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let remainingTime = max(endDate.timeIntervalSinceNow, 0)
            
            updateHandler?(remainingTime)
            
            if remainingTime <= 0 {
                timer.invalidate()
                completion()
            }
        }
        
        RunLoop.current.add(countdownTimer!, forMode: .common)
    }
    
    public static func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

