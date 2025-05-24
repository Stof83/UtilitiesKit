//
//  String.swift
//
//  Created by El Mostafa El Ouatri on 16/02/22.
//

import CommonCrypto
import Foundation
import SwiftUI
import UIKit

extension String {
    public var isNotEmpty: Bool {
        get {
            isEmpty == false
        }
    }
    
    public var toURL: URL? {
        URL(string: self)
    }
    
    public var toUIColor: UIColor? {
        guard self.hasPrefix("#") else { return nil }
        
        let start = self.index(self.startIndex, offsetBy: 1)
        let hexColor = String(self[start...])
        var hexNumber: UInt64 = 0
        let scanner = Scanner(string: hexColor)
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        let red, green, blue, alpha: CGFloat
        switch hexColor.count {
        case 6:
            red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            blue = CGFloat(hexNumber & 0x0000ff) / 255
            alpha = 1
        case 8:
            red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            alpha = CGFloat(hexNumber & 0x000000ff) / 255
        default:
            return nil
        }
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var toColor: Color? {
        Color(self.toUIColor ?? .white)
    }

    public var toBase64Encoded: Data {
        if let base64Encoded = self.data(using: .utf8) {
            if let data = Data(base64Encoded: base64Encoded) {
                return data
            }
        }
        return Data()
    }

    public func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }

    public func htmlToMarkdown() -> AttributedString {
        var markdownString = self

        let replacements: [(pattern: String, template: String)] = [
            ("<h1>(.*?)</h1>", "# $1\n\n"),
            ("<h2>(.*?)</h2>", "## $1\n\n"),
            ("<h3>(.*?)</h3>", "### $1\n\n"),
            ("<h4>(.*?)</h4>", "#### $1\n\n"),
            ("<h5>(.*?)</h5>", "##### $1\n\n"),
            ("<h6>(.*?)</h6>", "###### $1\n\n"),
            ("<strong>(.*?)</strong>", "**$1**"),
            ("<b>(.*?)</b>", "**$1**"),
            ("<em>(.*?)</em>", "_$1_"),
            ("<i>(.*?)</i>", "_$1_"),
            ("<p>(.*?)</p>", "$1\n\n"),
            ("<br\\s*/?>", "  \n"),
            ("<br>", "  \n"),
            ("<ul>(.*?)</ul>", "$1\n"),
            ("<ol>(.*?)</ol>", "$1\n"),
            ("<li>(.*?)</li>", "- $1\n"),
            ("<a\\s+href=\"(.*?)\">(.*?)</a>", "[$2]($1)"),
            ("<code>(.*?)</code>", "`$1`"),
            ("<pre>(.*?)</pre>", "```\n$1\n```")
        ]

        for replacement in replacements {
            markdownString = markdownString.replacingOccurrences(
                of: replacement.pattern,
                with: replacement.template,
                options: .regularExpression
            )
        }

        markdownString = markdownString.decodeHTMLEntities()

        let underlineStrings = markdownString.strings(from: "<u>", to: "</u>")
        
        markdownString = markdownString.removeHTMLTags()
        var attributedString = markdownString.toMarkdown()
        
        underlineStrings.forEach { string in
            markdownString = NSAttributedString(attributedString).string
            let ranges = markdownString.ranges(of: string)
            ranges.forEach { range in
                attributedString[range].underlineStyle = .single
            }
        }
        
        return attributedString
    }

    public func decodeHTMLEntities() -> String {
        var result = self
        let entities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'"
        ]

        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }

        return result
    }
    
    public func removeHTMLTags() -> String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    public func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))

        } catch {
            return AttributedString(self)
        }
    }
    
    public func strings(from: String, to: String) -> [String] {
        var wordsSet: Set<String> = []
        var startIndex = self.startIndex
        
        while let range1 = self[startIndex...].range(of: from), let range2 = self[range1.upperBound...].range(of: to) {
            let substring = self[range1.upperBound..<range2.lowerBound]
            wordsSet.insert(String(substring))
            startIndex = range2.upperBound
        }
        
        return Array(wordsSet)
    }
    
    public subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    

    public var toUIImage: UIImage? {
        if let url = URL(string: self) {
            if let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    public var isValidTaxCode: Bool {
        let regEx = "^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$"
        return NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: self)
    }
    
    public var isNumber: Bool {
        get {
            return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }

    public var stringWithoutWhitespaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    public var toNumber: String {
        let components = self.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return components.joined()
    }
    
    public var isValidRegionCode: Bool {
        return Locale.isoRegionCodes.contains(self.uppercased())
    }

    public var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    public var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
    
    public var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    public var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    public var isValidName: Bool {
        return self.trim().count > 0
    }
   
    public  var isValidFullname: Bool {
        let regEx = "^[A-Za-z]+(?:\\s[A-Za-z]+)"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: self)
    }
    
    public var isValidEmail: Bool {
        let emailRegEx = "^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    public var isValidURL: Bool {
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
    
    public var isValidPassword: Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-+.,|_~`'\"]).{8,}$")
        return passwordTest.evaluate(with: self)
    }
    
    public var isNumeric: Bool {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
    
    public var isValidMobile: Bool {
        return self.count > 7 && self.count < 15
    }
    
    public var isValidZipCode: Bool {
        return self.count > 2 && self.count < 10
    }
    
    public func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func randomizeString(toLength length: Int) -> String {
        var randomString = ""
        for _ in 1..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
            let randomCharacter = self[self.index(self.startIndex, offsetBy: randomIndex)]
            randomString.append(randomCharacter)
        }
        return randomString
    }

    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    public func decodeJSON<T: Decodable>() throws -> T {
        guard let data = self.data(using: .utf8) else {
            throw NSError(domain: "JSONDecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
    
    public func removingHTMLTags() -> String {
        let regexPattern = "<[^>]+>"
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "") ?? self
    }
    
}

extension NSMutableAttributedString {

    public convenience init?(html: String, font: UIFont) {
        let familyName = font.familyName
        let fontNames = UIFont.fontNames(forFamilyName: familyName)
        guard let data = html.data(using: .unicode) else {
            return nil
        }
        
        do {
            let attributedString = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)

            attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
                if let currentFont = value as? UIFont {

                    var matchedFontName: String?

                    if currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) && currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        matchedFontName = fontNames.first(where: { $0.contains("BoldItalic") })
                    } else if currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                        matchedFontName = fontNames.first(where: { $0.contains("Bold") && !$0.contains("Italic") })
                    } else if currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        matchedFontName = fontNames.first(where: { $0.contains("Italic") && !$0.contains("Bold") })
                    } else {
                        matchedFontName = fontNames.first { $0 == font.fontName }
                    }

                    if let matchedFontName, let newFont = UIFont(name: matchedFontName, size: font.pointSize) {
                        attributedString.addAttribute(.font, value: newFont, range: range)
                    } else {
                        attributedString.addAttribute(.font, value: font, range: range)
                    }

                }
            }

            self.init(attributedString: attributedString)
        } catch {
            return nil
        }
    }
}

extension StringProtocol {

    public func ranges<T: StringProtocol>(
        of stringToFind: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<AttributedString.Index>] {

        var ranges: [Range<String.Index>] = []
        var attributedRanges: [Range<AttributedString.Index>] = []
        let attributedString = AttributedString(self)

        while let result = range(
            of: stringToFind,
            options: options,
            range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
            locale: locale
        ) {
            ranges.append(result)
            let start = AttributedString.Index(result.lowerBound, within: attributedString)!
            let end = AttributedString.Index(result.upperBound, within: attributedString)!
            attributedRanges.append(start..<end)
        }
        return attributedRanges
    }
}
