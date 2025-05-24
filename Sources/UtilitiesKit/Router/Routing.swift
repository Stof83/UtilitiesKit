//
//  Routing.swift
//
//  Created by El Mostafa El Ouatri on 04/08/23.
//


import Foundation
import SwiftUI

/// A SwiftUI view that handles the navigation and presentation of screens based on the navigation stack.
///
/// - Parameters:
///   - Screen: The type of screen conforming to `ScreenProtocol`.
///   - ScreenView: The SwiftUI view representing the associated view for the screen.
///
/// The `Routing` view takes a binding to the navigation stack and a closure that generates the SwiftUI view for a given screen based on the `ScreenProtocol`. It iterates through the navigation stack, constructing a navigation hierarchy using `NavigationNode` and the provided `buildView` closure. The last screen in the navigation stack is the topmost screen and will be the one presented to the user.
///
/// Example Usage:
///
/// ```swift
/// let rootScreen = MyScreen()
/// let stackBinding = Binding(get: { return [RouterContext(screen: rootScreen, presentationType: .push)] }, set: { _ in })
/// let routingView = Routing(stack: stackBinding) { screen in
///     MyScreenView(screen: screen)
/// }
/// ```
public struct Routing<Screen: ScreenProtocol, ScreenView: View>: View {
    @Binding var stack: [RouterContext<Screen>]
    var buildView: (Screen) -> ScreenView

    /// Initializes the `Routing` view with a binding to the navigation stack, a closure to generate the SwiftUI view for a given screen, and an array of environment objects.
    ///
    /// - Parameters:
    ///   - stack: A binding to the navigation stack.
    ///   - buildView: A closure that generates the SwiftUI view for a given screen based on the `ScreenProtocol`.
    public init(stack: Binding<[RouterContext<Screen>]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = stack
        self.buildView = buildView
    }

    /// The body of the `Routing` view.
    ///
    /// This constructs the navigation hierarchy based on the navigation stack and the provided `buildView` closure.
    ///
    /// - Returns: A SwiftUI view.
    public var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(NavigationNode<Screen, ScreenView>.end) { pushedNode, new in
                let (index, screenContext) = new

                return NavigationNode<Screen, ScreenView>.view(
                    buildView(screenContext.screen),
                    context: screenContext,
                    pushing: pushedNode,
                    stack: $stack,
                    index: index
                )
            }
    }
}


