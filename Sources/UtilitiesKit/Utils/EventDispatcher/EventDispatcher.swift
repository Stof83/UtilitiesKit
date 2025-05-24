//
//  EventDispatcher.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 06/05/25.
//


import Foundation

/// A default implementation of `EventDispatcherProtocol`.
/// Provides concurrency-safe, decoupled event dispatching using Swift actors.
public actor EventDispatcher<Event: Hashable>: EventDispatcherProtocol {
    public typealias Listener = @Sendable (Event) -> Void

    private struct ListenerBox {
        let id: UUID
        let filter: ((Event) -> Bool)?
        let listener: Listener
    }

    private var listeners: [UUID: ListenerBox] = [:]

    /// Initializes a new dispatcher.
    public init() {}

    /// Registers a listener for specific or all events.
    ///
    /// - Parameters:
    ///   - events: A set of specific events to filter for. If `nil`, all events are dispatched to the listener.
    ///   - listener: The closure to execute when the event is dispatched.
    /// - Returns: A `SubscriptionToken` for managing the lifecycle of the listener.
    @discardableResult
    public func register(
        for events: Set<Event>? = nil,
        listener: @escaping Listener
    ) async -> SubscriptionToken<Event> {
        let id = UUID()
        let filter = events.map { targets in
            return { targets.contains($0) }
        }

        listeners[id] = ListenerBox(id: id, filter: filter, listener: listener)
        return SubscriptionToken(id: id, dispatcher: self)
    }

    /// Dispatches a single event to all matching listeners.
    ///
    /// - Parameter event: The event to dispatch.
    public func dispatch(_ event: Event) async {
        for box in listeners.values {
            if box.filter?(event) ?? true {
                box.listener(event)
            }
        }
    }

    /// Dispatches multiple events to listeners in sequence.
    ///
    /// - Parameter events: The array of events to dispatch.
    public func dispatch(_ events: [Event]) async {
        for event in events {
            await dispatch(event)
        }
    }

    /// Unregisters a listener using the given token.
    ///
    /// - Parameter token: The token for the listener to unregister.
    public func unregister(token: SubscriptionToken<Event>) async {
        listeners.removeValue(forKey: token.id)
    }
}
