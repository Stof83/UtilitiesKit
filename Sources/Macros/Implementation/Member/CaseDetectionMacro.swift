//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxMacros

public enum CaseDetectionMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    declaration.memberBlock.members
      .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
      .flatMap { $0.elements }
      .map {
        """
        var is\(raw: $0.name.toPascalCase): Bool {
          if case .\(raw: $0.name) = self {
            return true
          }
          return false
        }
        """
      }
  }
}

extension TokenSyntax {
    fileprivate var toPascalCase: String {
        self.text
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression)
            .split(separator: "_")
            .map { $0.lowercased().capitalized }
            .joined()
    }
}
