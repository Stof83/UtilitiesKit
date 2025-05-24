//
//  Router.swift
//
//  Created by El Mostafa El Ouatri on 04/08/23.
//


import Foundation
import SwiftUI

/// Enum representing different presentation types for views in the router.
public enum PresentationType {
    case push
    case full
    case modal
}

/// Protocol defining the required properties for a screen.
public protocol ScreenProtocol {
    /// A boolean indicating whether the screen should be embedded in a navigation view.
    var embedInNavigationView: Bool { get }
}

/// Protocol defining the required properties and functions for a router object.
public protocol RouterObject: AnyObject {
    /// Associated type for the screen conforming to `ScreenProtocol`.
    associatedtype Screen: ScreenProtocol
    /// Associated type for the SwiftUI view body.
    associatedtype Body: View

    /// Function to start the router and return the SwiftUI view body.
    func start() -> Body
    /// Updates the root screen dynamically and resets the navigation stack.
    func updateRootScreen(_ screen: Screen)
    /// Function to navigate to a specific screen.
    func navigateTo(_ screen: Screen, embedInNavigationView: Bool)
    /// Function to present a sheet for a specific screen.
    func presentSheet(_ screen: Screen, embedInNavigationView: Bool, onDismiss: (() -> Void)?)
    /// Function to present a full-screen view for a specific screen.
    func presentFullScreen(_ screen: Screen, embedInNavigationView: Bool, onDismiss: (() -> Void)?)
    /// Function to dismiss the last presented view.
    func dismissLast()
    /// Function to pop back to the root view in the navigation stack.
    func popToRoot()
}

/// Struct representing the context of a router screen with its associated presentation type.
public struct RouterContext<ScreenType: ScreenProtocol> {
    public let screen: ScreenType
    public let presentationType: PresentationType
    public let embedInNavigationView: Bool
    public let onDismiss: (() -> Void)?

    public init(
        screen: ScreenType,
        presentationType: PresentationType,
        embedInNavigationView: Bool = false,
        onDismiss: (() -> Void)? = nil
    ) {
        self.screen = screen
        self.presentationType = presentationType
        self.embedInNavigationView = embedInNavigationView
        self.onDismiss = onDismiss
    }
}

/// A class representing a router that manages navigation between different screens.
public class Router<ScreenType, Factory: RouterFactory>: ObservableObject, RouterObject where Factory.Screen == ScreenType {

    /// The navigation stack containing `RouterContext` objects.
    @Published public private(set) var stack: [RouterContext<ScreenType>] = []
    /// The factory used to create the SwiftUI views for each screen.
    public var factory: Factory
    
    /// Initializes the router with a root screen, presentation type, factory, and embed option.
    ///
    /// - Parameters:
    ///   - rootScreen: The initial screen for the router.
    ///   - presentationType: The default presentation type for screens.
    ///   - factory: The factory used to create SwiftUI views for each screen.
    ///   - embedInNavigationView: Boolean to determine if the screen should be embedded in a NavigationView.
    public init(
        rootScreen: ScreenType,
        presentationType: PresentationType = .push,
        factory: Factory,
        embedInNavigationView: Bool = false
    ) {
        self.stack = [
            RouterContext(
                screen: rootScreen,
                presentationType: presentationType,
                embedInNavigationView: embedInNavigationView
            )
        ]
        self.factory = factory
    }
    
    internal func updateStack(with stack: [RouterContext<ScreenType>]) {
        self.stack = stack
    }
    
    /// The starting point of the router.
    ///
    /// - Returns: A SwiftUI view body for the router.
    @ViewBuilder public func start() -> some View {
        let bindingScreens = Binding(get: {
            return self.stack
        }, set: {
            self.stack = $0
        })

        Routing(stack: bindingScreens) { screen in
            self.factory.makeBody(for: screen)
        }
    }
}

extension Router {
    /// Updates the root screen dynamically and resets the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The new screen to be set as the root.
    public func updateRootScreen(_ screen: ScreenType) {
        if var routerContext = stack.first {
            updateStack(with: [
                RouterContext(
                    screen: screen,
                    presentationType: routerContext.presentationType,
                    embedInNavigationView: routerContext.embedInNavigationView
                )
            ])
        }
    }
    
    /// Presents a sheet for a specific screen.
    ///
    /// - Parameter screen: The screen to be presented as a sheet.
    /// 
    public func presentSheet(_ screen: ScreenType, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
        self.stack.append(RouterContext(screen: screen, presentationType: .modal, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss))
    }

    /// Dismisses the last presented view.
    public func dismissLast() {
        self.stack.removeLast()
    }

    /// Navigates to a specific screen.
    ///
    /// - Parameter screen: The screen to navigate to.
    public func navigateTo(_ screen: ScreenType, embedInNavigationView: Bool = false) {
        self.stack.append(RouterContext(screen: screen, presentationType: .push, embedInNavigationView: embedInNavigationView))
    }

    /// Presents a full-screen view for a specific screen.
    ///
    /// - Parameter screen: The screen to be presented as a full-screen view.
    public func presentFullScreen(_ screen: ScreenType, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
        self.stack.append(RouterContext(screen: screen, presentationType: .full, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss))
    }

    /// Pops back to the root view in the navigation stack.
    public func popToRoot() {
        self.stack.removeLast(self.stack.count - 1)
    }
}
