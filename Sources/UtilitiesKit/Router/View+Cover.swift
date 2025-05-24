//
//  View+Cover.swift
//
//  Created by El Mostafa El Ouatri on 04/08/23.
//


import Foundation
import SwiftUI

/// An extension on `View` to enhance it with a method for presenting another view as a modal sheet or full-screen cover.
extension View {
    /// Presents another view as a modal sheet or full-screen cover based on the `asSheet` parameter.
    ///
    /// - Parameters:
    ///   - asSheet: A boolean indicating whether to present the view as a modal sheet (`true`) or full-screen cover (`false`).
    ///   - isPresented: A binding to a boolean variable that controls the presentation of the view.
    ///   - content: A closure returning the content of the view to be presented.
    /// - Returns: A modified view with the presentation logic.
    @ViewBuilder func present<Content: View>(asSheet: Bool, isPresented: Binding<Bool>, onDismiss: (() -> Void)?, @ViewBuilder content: @escaping () -> Content) -> some View {
        if asSheet {
            self.sheet(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        } else {
            self.fullScreenCover(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        }
    }
}

