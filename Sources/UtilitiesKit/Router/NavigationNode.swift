//
//  NavigationNode.swift
//
//  Created by El Mostafa El Ouatri on 04/08/23.
//

import SwiftUI

/// An indirect enum representing a navigation node that can handle navigation between SwiftUI screens.
///
/// - Parameters:
///   - Screen: A type that conforms to `ScreenProtocol`.
///   - ScreenView: A SwiftUI `View` type that represents the associated view for the screen.
///
/// The `NavigationNode` allows you to define a navigation hierarchy by specifying a screen view along with its context. It provides navigation capabilities such as pushing a new screen, presenting a modal view, or covering the screen entirely with a new view.
///
/// Example Usage:
///
/// ```swift
/// let rootNode = NavigationNode<MyScreen, MyScreenView>.view(
///     MyScreenView(),
///     context: RouterContext<MyScreen>(),
///     pushing: .end,
///     stack: Binding(get: { return [] }, set: { _ in }),
///     index: 0
/// )
/// ```
public indirect enum NavigationNode<Screen: ScreenProtocol, ScreenView: View>: View {
    /// A case representing a view node in the navigation hierarchy.
    ///
    /// - Parameters:
    ///   - view: The SwiftUI `View` representing the current node's screen.
    ///   - context: The router context associated with the current view node.
    ///   - pushing: The next navigation node to be presented when navigating forward.
    ///   - stack: The binding to the navigation stack used for managing the navigation history.
    ///   - index: The index of the current node in the navigation stack.
    case view(
        _ view: ScreenView,
        context: RouterContext<Screen>,
        pushing: NavigationNode<Screen, ScreenView>,
        stack: Binding<[RouterContext<Screen>]>,
        index: Int
    )
    
    /// A case representing the end of the navigation hierarchy.
    case end
    
    /// The binding to indicate whether the current navigation node is active.
    private var isActiveBinding: Binding<Bool> {
        switch self {
            case .end, .view(_, _, pushing: .end, _, _):
                return .constant(false)
            case .view(_, _, .view, let allRoutes, let index):
                return Binding(
                    get: {
                        allRoutes.wrappedValue.count > index + 1
                    },
                    set: { isShowing in
                        guard !isShowing else { return }
                        guard allRoutes.wrappedValue.count > index + 1 else { return }
                        allRoutes.wrappedValue = Array(allRoutes.wrappedValue.prefix(index + 1))
                    }
                )
        }
    }
    
    /// The next navigation node to be presented when navigating forward.
    private var pushedNode: NavigationNode? {
        switch self {
            case .end:
                return nil
            case .view(_, _, let pushedNode, _, _):
                return pushedNode
        }
    }
    
    /// The router context associated with the current view node.
    private var routerContext: RouterContext<Screen>? {
        switch self {
            case .view(_, let context, _, _, _):
                return context
            case .end:
                return nil
        }
    }
    
    /// The binding to indicate whether a modal sheet should be presented.
    private var sheetBinding: Binding<Bool> {
        switch pushedNode {
            case .view(_, let context, _, _, _):
                return context.presentationType == .modal ? isActiveBinding : .constant(false)
            default:
                return .constant(false)
        }
    }
    
    /// The binding to indicate whether a full-screen cover should be presented.
    private var fullCoverBinding: Binding<Bool> {
        switch pushedNode {
            case .view(_, let context, _, _, _):
                return context.presentationType == .full ? isActiveBinding : .constant(false)
            default:
                return .constant(false)
        }
    }
    
    /// The binding to indicate whether a navigation link should be presented.
    private var pushBinding: Binding<Bool> {
        switch pushedNode {
            case .view(_, let context, _, _, _):
                return context.presentationType == .push ? isActiveBinding : .constant(false)
            default:
                return .constant(false)
        }
    }
    
    /// The main body of the `NavigationNode`.
    ///
    /// This computes the SwiftUI `View` body to handle the presentation of the current view.
    ///
    /// - Returns: A SwiftUI `View`.
    @ViewBuilder var viewBody: some View {
        let asSheet = pushedNode?.routerContext?.presentationType == .modal
        if case .view(let view, _, let pushedNode, _, _) = self {
            view
                .background(
                    NavigationLink(
                        destination: pushedNode,
                        isActive: pushBinding,
                        label: EmptyView.init
                    )
                    .hidden()
                )
                .present(
                    asSheet: asSheet,
                    isPresented: asSheet ? sheetBinding : fullCoverBinding,
                    onDismiss: pushedNode.routerContext?.onDismiss,
                    content: { pushedNode }
                )
        } else {
            EmptyView()
        }
    }
    
    /// The SwiftUI `View` body, handling the navigation hierarchy.
    ///
    /// It can be wrapped in a `NavigationView` if the associated screen prefers a navigation view style.
    ///
    /// - Returns: A SwiftUI `View`.
    public var body: some View {
        if let routerContext {
            if routerContext.screen.embedInNavigationView || routerContext.embedInNavigationView {
                NavigationView {
                    viewBody
                }
                .navigationViewStyle(.stack)
            } else {
                viewBody
            }
        } else {
            EmptyView()
        }
    }
}
