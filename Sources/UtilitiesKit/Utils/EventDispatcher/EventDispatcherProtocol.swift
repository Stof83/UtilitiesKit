//
//  EventDispatcherProtocol.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 06/05/25.
//

import Foundation

/// A protocol defining a generic event dispatcher for decoupled communication.
/// Listeners can register for specific events or all events, and will be notified when events are dispatched.
public protocol EventDispatcherProtocol {
    /// The associated event type. Must conform to `Hashable`.
    associatedtype Event: Hashable

    /// Registers a listener for specific or all events.
    ///
    /// - Parameters:
    ///   - events: A set of specific events to filter for. If `nil`, all events are dispatched to the listener.
    ///   - listener: The closure to execute when the event is dispatched.
    /// - Returns: A `SubscriptionToken` for managing the lifecycle of the listener.
    @discardableResult
    func register(
        for events: Set<Event>?,
        listener: @Sendable @escaping (Event) -> Void
    ) async -> SubscriptionToken<Event>

    /// Dispatches a single event to all matching listeners.
    ///
    /// - Parameter event: The event to dispatch.
    func dispatch(_ event: Event) async

    /// Dispatches multiple events in sequence to matching listeners.
    ///
    /// - Parameter events: An array of events to dispatch.
    func dispatch(_ events: [Event]) async

    /// Unregisters a listener associated with a subscription token.
    ///
    /// - Parameter token: The subscription token.
    func unregister(token: SubscriptionToken<Event>) async
}
