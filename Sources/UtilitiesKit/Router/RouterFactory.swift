//
//  RouterFactory.swift
//
//  Created by El Mostafa El Ouatri on 04/08/23.
//


import Foundation
import SwiftUI

/// Protocol defining the blueprint for a factory that creates SwiftUI views for router screens.
public protocol RouterFactory {
    /// The associated type representing the SwiftUI view body.
    associatedtype Body: View
    /// The associated type representing the screen type conforming to `ScreenProtocol`.
    associatedtype Screen: ScreenProtocol

    /// Creates the SwiftUI view body for the given screen.
    ///
    /// - Parameter screen: The screen for which the view body needs to be created.
    /// - Returns: The SwiftUI view body for the screen.
    @ViewBuilder func makeBody(for screen: Screen) -> Self.Body
}

