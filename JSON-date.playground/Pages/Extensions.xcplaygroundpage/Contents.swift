//: [Previous](@previous)

import Foundation
import JavaScriptCore

/*:

 ## A class and some extensions to decode & encode JSON dates

 */

class JavaScriptISO8601DateFormatter {
    static let fractionalSecondsFormatter: ISO8601DateFormatter = {
        let res = ISO8601DateFormatter()
        // The default format options is .withInternetDateTime.
        // We need to add .withFractionalSeconds to parse dates with milliseconds.
        res.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return res
    }()

    static let defaultFormatter = ISO8601DateFormatter()

    static func decodedDate(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateAsString = try container.decode(String.self)

        for formatter in [fractionalSecondsFormatter, defaultFormatter] {
            if let res = formatter.date(from: dateAsString) {
                return res
            }
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Expected date string to be JavaScript-ISO8601-formatted."
        ))
    }

    static func encodeDate(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fractionalSecondsFormatter.string(from: date))
    }

    private init() {}
}

extension JSONDecoder.DateDecodingStrategy {
    static func javaScriptISO8601() -> JSONDecoder.DateDecodingStrategy {
        .custom(JavaScriptISO8601DateFormatter.decodedDate)
    }
}

extension JSONDecoder {
    static func javaScriptISO8601() -> JSONDecoder {
        let res = JSONDecoder()
        res.dateDecodingStrategy = .javaScriptISO8601()
        return res
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static func javaScriptISO8601() -> JSONEncoder.DateEncodingStrategy {
        .custom(JavaScriptISO8601DateFormatter.encodeDate)
    }
}

extension JSONEncoder {
    static func javaScriptISO8601() -> JSONEncoder {
        let res = JSONEncoder()
        res.dateEncodingStrategy = .javaScriptISO8601()
        return res
    }
}

/*:

 ## Usage

 */

let javaScriptContext = JSContext()!
let jsonPayload = javaScriptContext.evaluateScript("""
const payload = { message: '👋', creationDate: new Date() };
JSON.stringify(payload)
""")
dump(jsonPayload!.toString())

struct PayloadStruct: Codable {
    let message: String
    let creationDate: Date
}

let payload = try jsonPayload?.toString()?.data(using: .utf8).map { try JSONDecoder.javaScriptISO8601().decode(PayloadStruct.self, from: $0)
}

let reencodedJSONPayload = (try? JSONEncoder.javaScriptISO8601().encode(payload)).flatMap {
    String(data: $0, encoding: .utf8)
}

assert(jsonPayload?.toString() == reencodedJSONPayload)

//: [Next](@next)

let date = Date()
let encoded = (try? JSONEncoder().encode(date)).flatMap {
    String(data: $0, encoding: .utf8)
}

let now = Date(timeIntervalSinceReferenceDate: 638_832_175.28592002)
