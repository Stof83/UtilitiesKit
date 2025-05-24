//
//  ViewController.swift
//  Example
//
//  Created by El Mostafa El Ouatri on 07/08/23.
//

import Foundation
import MacrosInterface
import UIKit
import UtilitiesKit

/// Describes the driver's parking status with associated color logic and state checks.
@CaseDetection
enum ParkingStatus {
    case insideDetected, insideVerified, insideConfirmed, outsideDetected, outsideConfirmed

    /// Associated UI color for each parking status.
    func color() -> UIColor {
        switch self {
            case .insideDetected: .orange
            case .insideVerified: .yellow
            case .insideConfirmed: .green
            case .outsideDetected: .lightGray
            case .outsideConfirmed: .black
        }
    }

}


class ViewController: UIViewController {

    var variable: String?
    var status: ParkingStatus = .insideConfirmed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        if variable.isNil {
            print("ok")
        }
        
    
        if status.isInsideDetected {
            
        }
        
    }

}
