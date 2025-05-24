//
//  AnyEventDispatcherBox.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 06/05/25.
//


import Foundation

/// Type-erased wrapper used to weakly reference any concrete `EventDispatcherProtocol`.
/// Solves the associated type existential limitation.
final class AnyEventDispatcherBox<Event: Hashable> {
    private let _unregister: (UUID) -> Void

    /// Creates a box for the given dispatcher.
    ///
    /// - Parameter dispatcher: The dispatcher to wrap.
    init<Dispatcher: EventDispatcherProtocol>(_ dispatcher: Dispatcher) where Dispatcher.Event == Event {
        _unregister = { id in
            Task { await dispatcher.unregister(token: .init(id: id, dispatcher: dispatcher)) }
        }
    }

    /// Calls unregister on the underlying dispatcher.
    ///
    /// - Parameter id: The ID of the subscription to remove.
    func unregister(id: UUID) {
        _unregister(id)
    }
}
