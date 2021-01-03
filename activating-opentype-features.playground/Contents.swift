//: Activating OpenType Features in iOS

import PlaygroundSupport
import UIKit

// Load "Inter Bold" in the playground
guard let interFontURL: CFURL = Bundle.main.url(forResource: "Inter-Bold", withExtension: "otf") as CFURL? else {
    fatalError("Could not load resource from playground.")
}

CTFontManagerRegisterFontsForURL(interFontURL, .process, nil)

extension UIFont {
    static func printAllFontNames() {
        print("# All Font Names\n")
        for familyName in UIFont.familyNames {
            print("- \(familyName)")
            for font in UIFont.fontNames(forFamilyName: familyName) {
                print("  - \(font)")
            }
        }
    }
}

extension UIFont {
    typealias FontFeatureInfo = [String: Any]

    func listFeatures() {
        guard let fontFeatures = CTFontCopyFeatures(self) as? [FontFeatureInfo] else {
            debugPrint("Could not copy font features.")
            return
        }

        fontFeatures.forEach { fontFeatureInfo in
            print(fontFeatureInfo)
        }
    }
}

UIFont.printAllFontNames()
UIFont(name: "Inter-Bold", size: 16.0)?.listFeatures()

/// Font feature pairs.
///
/// For inspiration of the naming, cf. https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html
private enum FeatureTypeSelectorPair {
    typealias PairDescriptor = (Int, Int)

    static let stylisticAlternativesStylisticAltOne: PairDescriptor = (35, 2)

    static func attributeValue(for pairDescriptor: PairDescriptor) -> Any {
        [
            UIFontDescriptor.FeatureKey.featureIdentifier: pairDescriptor.0,
            UIFontDescriptor.FeatureKey.typeIdentifier: pairDescriptor.1,
        ]
    }
}

func createFontWithOptions(fontName: String, size: CGFloat) -> UIFont {
    let resultFont = UIFontDescriptor(name: fontName, size: size)
        .addingAttributes([
            .featureSettings: [
                FeatureTypeSelectorPair.attributeValue(
                    for: FeatureTypeSelectorPair.stylisticAlternativesStylisticAltOne
                ),
            ],
        ])

    // 0.0 means the size from the descriptor will prevail.
    return UIFont(descriptor: resultFont, size: 0.0)
}

class MyViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Inter-Bold", size: 32.0)
        label.text = "0123456789"
        label.textColor = .black

        let labelWithFeatures = UILabel()
        labelWithFeatures.translatesAutoresizingMaskIntoConstraints = false
        labelWithFeatures.font = createFontWithOptions(fontName: "Inter-Bold", size: 32.0)
        labelWithFeatures.text = "0123456789"
        labelWithFeatures.textColor = .black

        view.addSubview(label)
        view.addSubview(labelWithFeatures)

        NSLayoutConstraint.activate([
            label.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelWithFeatures.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: label.lastBaselineAnchor, multiplier: 1.0),
            labelWithFeatures.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        self.view = view
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
