//
//  TaskManager.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 06/05/25.
//

import Foundation

/// `TaskManager` is a generic actor that manages delayed asynchronous tasks identified by a unique hashable key.
///
/// It supports scheduling tasks with a time delay, automatically cancelling any previous task of the same key
/// before scheduling a new one. It can execute the task once, a fixed number of times, or indefinitely until cancelled.
///
/// This is ideal for debouncing, throttling, or repeating asynchronous actions in a concurrency-safe environment.
///
/// - Note: Internally uses `Task.sleep(_:)` and Swift Concurrency. All access is serialized by the actor.
public actor TaskManager<T: Hashable> {

    /// Defines how many times a task should repeat when scheduled in `TaskManager`.
    public enum TaskRepeats: Sendable {
        /// The task executes once.
        case once
        /// The task repeats indefinitely until cancelled.
        case indefinite
        /// The task repeats exactly the specified number of times.
        case times(Int)
    }

    /// Dictionary storing currently scheduled tasks, keyed by their unique identifier.
    private var tasks: [T: Task<Void, Never>] = [:]

    public init() {}

    /// Schedules a new asynchronous task of a given type to execute after a specified time interval.
    ///
    /// If a task with the same key is already scheduled, it is cancelled and replaced by the new one.
    ///
    /// - Parameters:
    ///   - type: The unique key representing the task category or identifier.
    ///   - interval: The time interval between consecutive executions, in seconds.
    ///               For single execution (`repeats == nil`), the task is executed immediately without delay.
    ///   - repeats: An optional value specifying how many times the task should repeat.
    ///              If `nil`, the task executes once.
    ///              If `.indefinite`, the task repeats until cancelled.
    ///              If `.times(n)`, the task repeats exactly `n` times.
    ///   - action: A `@Sendable` async closure that performs the desired work.
    public func scheduleTask(
        _ type: T,
        withTimeInterval interval: TimeInterval,
        repeats: TaskRepeats = .once,
        action: @Sendable @escaping () async -> Void
    ) {
        cancelTask(type)

        let task = Task {
            var executions = 0

            func shouldContinue() -> Bool {
                switch repeats {
                    case .once:
                        return executions == 0 // single execution
                    case .indefinite:
                        return true
                    case .times(let count):
                        return executions < count
                }
            }

            while shouldContinue(), !Task.isCancelled {
                // For repeats > 1, sleep before next execution, skip for the first run
                if executions > 0 {
                    try? await Task.sleep(seconds: interval)
                    guard !Task.isCancelled else { break }
                }

                await action()
                executions += 1
            }

            tasks.removeValue(forKey: type)
        }

        tasks[type] = task
    }

    /// Cancels a specific scheduled task by its key.
    ///
    /// - Parameter type: The key identifying the task to cancel.
    public func cancelTask(_ type: T) {
        tasks[type]?.cancel()
        tasks.removeValue(forKey: type)
    }

    /// Cancels all scheduled tasks managed by this instance.
    public func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }

    /// Checks if there is an active scheduled task for the given key.
    ///
    /// - Parameter type: The key identifying the task.
    /// - Returns: `true` if a task is scheduled, `false` otherwise.
    public func hasTask(for type: T) -> Bool {
        tasks[type] != nil
    }
}
