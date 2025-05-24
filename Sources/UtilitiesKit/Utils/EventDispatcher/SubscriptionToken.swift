//
//  SubscriptionToken.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 06/05/25.
//


import Foundation

/// A token representing a subscription to an event dispatcher.
/// Automatically unregisters the listener when deallocated.
public final class SubscriptionToken<Event: Hashable> {
    /// Unique identifier for the subscription.
    let id: UUID

    /// Weak type-erased reference to the dispatcher to allow auto-unregister.
    private let box: AnyEventDispatcherBox<Event>?

    /// Initializes a subscription token.
    ///
    /// - Parameters:
    ///   - id: Unique listener ID.
    ///   - dispatcher: The dispatcher managing this listener.
    public init<Dispatcher: EventDispatcherProtocol>(
        id: UUID,
        dispatcher: Dispatcher
    ) where Dispatcher.Event == Event {
        self.id = id
        self.box = AnyEventDispatcherBox(dispatcher)
    }

    /// Automatically removes the listener from the dispatcher upon deallocation.
    deinit {
        box?.unregister(id: id)
    }
}
