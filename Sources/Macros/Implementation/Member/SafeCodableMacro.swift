//
//  SafeCodableMacro.swift
//  Macros
//
//  Created by El Mostafa El Ouatri on 19/05/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

/// A macro that synthesizes a resilient `Codable` conformance for a struct:
/// - Automatically generates a `CodingKeys` enum
/// - Implements a `public init(from:)` decoder with default values for decoding failures
/// - Fallback for:
///   - Optionals: `nil`
///   - Strings/Int/etc: empty string/zero
///   - Custom enums: first case
///   - Structs: synthesized memberwise init with default values
/// - Also synthesizes a memberwise `init(...)` with default values (if one doesn’t exist)
///
/// ### Example:
/// ```swift
/// @SafeCodable
/// public struct User: Codable {
///     public let name: String
///     public let age: Int
///     public let role: Role?
/// }
///
/// public enum Role: String, Codable {
///     case admin, user
/// }
/// ```
/// Becomes:
/// ```swift
/// enum CodingKeys: String, CodingKey { ... }
/// public init(from decoder: Decoder) throws { ... }
/// public init(name: String = "", age: Int = 0, role: Role? = nil) { ... }
/// ```
public enum SafeCodableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = decl.as(StructDeclSyntax.self) else { return [] }

        let members = structDecl.memberBlock.members

        // Extract properties: (name, type, isOptional)
        let properties = members.compactMap { member -> (name: String, type: String, isOptional: Bool)? in
            guard
                let varDecl = member.decl.as(VariableDeclSyntax.self),
                let binding = varDecl.bindings.first,
                let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                let type = binding.typeAnnotation?.type.description
            else { return nil }

            let cleanType = type.trimmingCharacters(in: .whitespacesAndNewlines)
            let isOptional = cleanType.hasSuffix("?")
            let baseType = cleanType.replacingOccurrences(of: "?", with: "").trimmingCharacters(in: .whitespaces)
            return (name, baseType, isOptional)
        }

        // CodingKeys enum
        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
        \(raw: properties.map { "case \($0.name)" }.joined(separator: "\n"))
        }
        """

        // Decoder init
        let decoderLines = properties.map { prop -> String in
            let decodeStmt = prop.isOptional
                ? "try? container.decodeIfPresent(\(prop.type).self, forKey: .\(prop.name)) ?? nil"
                : "(try? container.decode(\(prop.type).self, forKey: .\(prop.name))) ?? \(fallbackValue(for: prop.type, in: members, context: context, node: node, propertyName: prop.name))"
            return "\(prop.name) = \(decodeStmt)"
        }

        let decoderInit: DeclSyntax = """
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            \(raw: decoderLines.joined(separator: "\n"))
        }
        """

        let memberwiseInit: DeclSyntax =  DeclSyntax(stringLiteral:
            """
            public init(\(properties.map {
                "\($0.name): \($0.type)\($0.isOptional ? "? = nil" : " = \(fallbackValue(for: $0.type, in: members, context: context, node: node, propertyName: $0.name, defaultArgs: true))")"
            }.joined(separator: ", "))) {
                \(properties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))
            }
            """
        )

        return [codingKeys, decoderInit, memberwiseInit]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [TypeSyntax] {
        return ["Codable"]
    }
    
    // MARK: - Fallback value logic

    private static func fallbackValue(
        for typeName: String,
        in memberList: MemberBlockItemListSyntax,
        context: some MacroExpansionContext,
        node: AttributeSyntax,
        propertyName: String,
        defaultArgs: Bool = false
    ) -> String {
        let trimmedType = typeName.trimmingCharacters(in: .whitespacesAndNewlines)

        switch trimmedType {
            // Primitives
            case "String": return "\"\""
            case "Int": return "0"
            case "Double": return "0.0"
            case "Float": return "0.0"
            case "Bool": return "false"
                
            // Common Foundation types
            case "Date": return "Date(timeIntervalSince1970: 0)"
            case "Data": return "Data()"
            case "Decimal": return "Decimal(0)"
            case "UUID": return "UUID()"
            case "URL": return "URL(string: \"about:blank\")!"
                
            // Collection types
            case let t where isArray(type: t): return "[]"
            case let t where isSet(type: t): return "Set()"
            case let t where isDictionary(type: t): return "[:]"
                
            default:
                
                guard let enumValue = checkCodableEnum(for: propertyName, in: memberList) else {
                    return "\(trimmedType)()"
                }
                
                return enumValue
        }
    }

    private static func isArray(type: String) -> Bool {
        type.hasPrefix("[") && type.hasSuffix("]")
    }

    private static func isSet(type: String) -> Bool {
        type.hasPrefix("Set<") && type.hasSuffix(">")
    }

    private static func isDictionary(type: String) -> Bool {
        // Dictionary<Key, Value> or shorthand [Key: Value]
        type.hasPrefix("Dictionary<") && type.hasSuffix(">")
        || (type.hasPrefix("[") && type.contains(":") && type.hasSuffix("]"))
    }
    
    private static func checkCodableEnum(
        for name: String,
        in memberList: MemberBlockItemListSyntax
    ) -> String? {
        for member in memberList {
            guard
              let propertyName = member
                .decl.as(VariableDeclSyntax.self)?
                .bindings.first?
                .pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
              return nil
            }
            
            guard propertyName == name else { continue }
            
            if let enumMacro = member.decl.as(VariableDeclSyntax.self)?.attributes.first(where: { element in
              element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "CodableEnum"
            }) {

              // Uses the value in the Macro
              let enumValue = enumMacro.as(AttributeSyntax.self)!
                .arguments!.as(LabeledExprListSyntax.self)!
                .first!
                .expression

              return "\(enumValue)"
            }
        }

        return nil
    }
}


public struct CodableEnum: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // Does nothing, used only to decorate members with data
    return []
  }
}
