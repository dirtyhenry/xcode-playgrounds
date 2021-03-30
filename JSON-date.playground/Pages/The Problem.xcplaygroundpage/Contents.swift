import Cocoa
import JavaScriptCore

// 📜: https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/

/*:

 # TODO

 ## The Problem with Codable's JSON Support

 Swift has 1st-party support for JavaScript script execution. So let's create
 a simple JSON payload including a date field in Swift:

 */
let javaScriptContext = JSContext()!
let jsonPayload = javaScriptContext.evaluateScript("""
const payload = { message: '👋', creationDate: new Date() };
JSON.stringify(payload)
""")
dump(jsonPayload!.toString())

/*:

 What happens if we submit this JSON string to Codable?

 */
struct PayloadStruct: Codable {
    let message: String
    let creationDate: Date
}

do {
    _ = try jsonPayload?.toString()?.data(using: .utf8).map { try JSONDecoder().decode(PayloadStruct.self, from: $0)
    }
} catch let DecodingError.typeMismatch(type, context) {
    dump(type)
    dump(context) // creationDate: Expected to decode Double but found a string/data instead.
}

/*:

 We get a `typeMismatch` error.

 Let's try another time with a customized `JSONDecoder`.

 */

do {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .iso8601

    _ = try jsonPayload?.toString()?.data(using: .utf8).map { try jsonDecoder.decode(PayloadStruct.self, from: $0)
    }
} catch let DecodingError.dataCorrupted(context) {
    dump(context)
}

/*:

 Wait, what⁉︎ Nope. No luck. Let's try something else.

 */

//: [Next](@next)
