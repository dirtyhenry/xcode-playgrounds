import CryptoKit
import Foundation

/*:

 # PKCE in Swift: Generating Cryptographically Secure Code Verifiers and Code Challenges

 I am making an app that uses the Spotify API. As for most other public API, the
 first step to successfully fetch a public API endpoint is to complete the
 authorization flow. The Spotify API uses the _Proof Key for Code Exchange_
 extension to OAuth 2.0 (_PKCE_) to do so. This post will provide tips to
 implement the code to get an access token from this API, but it should work as
 well for any other API using PKCE.

 First some utils code: this is using a pipe-forward operator to compose functions with ease.
 Check out https://www.pointfree.co/episodes/ep1-functions for more details.

 */

// MARK: - Pipe Forward operator

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    f(a)
}

func |> <A, B>(a: A, f: (A) throws -> B) throws -> B {
    try f(a)
}

// MARK: - PKCE Code Verifier & Code Challenge

enum PKCEError: Error {
    case failedToGenerateRandomOctets
    case failedToCreateChallengeForVerifier
}

/*:

 ## Creating a code verifier

 Reading [the RFC for PKCE](https://tools.ietf.org/html/rfc7636), the first step is to create a _code verifier_, ie
 a random string that must meet the following requirements:

 - with characters in the set: [A-Z] / [a-z] / [0-9] / "-" / "." / "\_" / "~";
 - with a minimum length of 43 characters and a maximum length of 128 characters;
 - with enough _entropy_.

 Entropy is a term coming from thermodynamics to quantify states of disorder,
 randomness and uncertainty. The higher the entropy, the higher the
 unpredictability of the state. Applied to PKCE, the higher the entropy, the
 harder would it be for a potential attacker to learn or guess how code verifiers
 are created.

 In Swift's [Security framework](https://developer.apple.com/documentation/security), the `SecRandomCopyBytes` function will
 help us comply to these requirements.

 We first create an array of blank 32 octets, that we will feed into
 `SecRandomCopyBytes`

 */

func generateCryptographicallySecureRandomOctets(count: Int) throws -> [UInt8] {
    var octets = [UInt8](repeating: 0, count: count)
    let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
    if status == errSecSuccess { // Always test the status.
        return octets
    } else {
        throw PKCEError.failedToGenerateRandomOctets
    }
}

/*:

 Calling `generateCryptographicallySecureRandomOctets` multiple times will return
 different results, that should be unpredictable.

 Next, we need to transform these octets into a Base64-URL encoded string.
 Beware, this is different than a Base64 encoded string. Different but quite
 close, so as recommended by the RFC's Appendix A, a convenient way to generate
 our code verifier is to use an altered version of the Base64 encoding that Swift
 knows all about. Like so:

 */

// func base64URLEncode(octets: [UInt8]) -> String {
//    let data = Data(octets)
//    return data
//        .base64EncodedString() // Regular base64 encoder
//        .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
//        .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
//        .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
//        .trimmingCharacters(in: .whitespaces)
// }

func base64URLEncode<S>(octets: S) -> String where S: Sequence, UInt8 == S.Element {
    let data = Data(octets)
    return data
        .base64EncodedString() // Regular base64 encoder
        .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
        .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
        .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
        .trimmingCharacters(in: .whitespaces)
}

/*:
 We have a code verifier:
 */

let codeVerifier = try 32
    |> generateCryptographicallySecureRandomOctets
    |> base64URLEncode

/*:

 Wait: why did we use 32 octets to generate a string of 43 characters? Since our
 resulting string is using an alphabet of 64 letters, ie `2^6`, each character
 will code 6 bits. So since 32 octets are 256 bits, it requires 43 characters to
 be represented.

 ## Creating the code challenge

 Creating the challenge is a matter of transforming the verifier with a series of
 operations.

 */

func challenge(for verifier: String) throws -> String {
    let challenge = verifier // String
        .data(using: .ascii) // Decode back to [UInt8] -> Data?
        .map { SHA256.hash(data: $0) } // Hash -> SHA256.Digest?
        .map { base64URLEncode(octets: $0) } // base64URLEncode

    if let challenge = challenge {
        return challenge
    } else {
        throw PKCEError.failedToCreateChallengeForVerifier
    }
}

/*:

 The operations are as follow:

 - (a) convert the verifier string back into a collection of octets;
 - (b) create a SHA-256 hash of that data with `SHA256`, that is available either
   from Apple CryptoKit on supported platforms or [Swift Crypto](   https://apple.github.io/swift-crypto/docs/current/Crypto/Structs/SHA256.html) for
   others.
 - (c) transform into a Base64-URL encoded string.

 ## Testing our code

 The RFC provides some testing samples so let's use this provided data set to
 validate this code:

 */

func assertEqual<S>(_ a: S, _ b: S) where S: Equatable {
    if a == b {
        print("✅ \(a) == \(b)")
    } else {
        fatalError("Assertion failed.")
    }
}

assertEqual(base64URLEncode(octets: [3, 236, 255, 224, 193]), "A-z_4ME")

let verifier = base64URLEncode(octets: [
    116, 24, 223, 180, 151, 153, 224, 37, 79, 250, 96, 125, 216, 173,
    187, 186, 22, 212, 37, 77, 105, 214, 191, 240, 91, 88, 5, 88, 83,
    132, 141, 121
])
assertEqual(verifier, "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
assertEqual(try! challenge(for: verifier), "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")

/*:

 And let's validate as well that we can create verifiers of lengthes that can
 cover the whole range:

 */

let codeVerifier43 = try 32
    |> generateCryptographicallySecureRandomOctets
    |> base64URLEncode
assertEqual(codeVerifier43.count, 43)

let codeVerifier128 = try 96
    |> generateCryptographicallySecureRandomOctets
    |> base64URLEncode
assertEqual(codeVerifier128.count, 128)

/*:

 🎉 A lot of green in the output!

 */
