import Cocoa
import JavaScriptCore

// 📜: https://bootstragram.com/blog/json-dates-swift/
// 📜: https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/

/*:

 # How I Decode Dates from JSON APIs in Swift

 ## The Problem with `Codable`'s JSON Support

 Swift has 1st-party support for JavaScript script execution. Let's create a
 simple JSON payload including a date field in Swift:

 */
let javaScriptContext = JSContext()!
let jsonPayload = javaScriptContext.evaluateScript("""
const payload = { message: '👋', creationDate: new Date() };
JSON.stringify(payload)
""")
dump(jsonPayload!.toString())

/*:

 Now let's decode this JSON string with Swift:

 */
struct PayloadStruct: Codable {
    let message: String
    let creationDate: Date
}

do {
    _ = try jsonPayload?.toString()?.data(using: .utf8).map {
        try JSONDecoder().decode(PayloadStruct.self, from: $0)
    }
} catch let DecodingError.typeMismatch(type, context) {
    dump(type)
    dump(context) // creationDate: Expected to decode Double but found a string/data instead.
}

/*:

 This code throws a `DecodingError.typeMismatch` error with the following
 description: `Expected to decode Double but found a string/data instead.`

 This is because, by default, a `Date` type is expected to be a `Double`
 specifying the number of seconds since 00:00:00 UTC on 1 January 2001. But the
 date in our JSON string is formatted as ISO 8601.

 Let's use `JSONDecoder`'s built-in `.iso8601` configuration of
 `DateDecodingStrategy`.

 */

do {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .iso8601

    _ = try jsonPayload?.toString()?.data(using: .utf8).map {
        try jsonDecoder.decode(PayloadStruct.self, from: $0)
    }
} catch let DecodingError.dataCorrupted(context) {
    dump(context)
}

/*:

 Another error? This time, the code throws a `DecodingError.dataCorrupted` error
 with the following description: `Expected date string to be ISO8601-formatted`.
 What is going on? 🤔

 */

//: [Next](@next)
