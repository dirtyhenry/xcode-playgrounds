//: Pixel Perfect Line Height With UIKit

// 📜 Read the blog post at: https://bootstragram.com/blog/line-height-with-uikit/

import PlaygroundSupport
import UIKit

// MARK: - Utils for snapshots

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIImage {
    func saveAs() {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("playground-snapshot.png")
        try! pngData()?.write(to: destinationURL)
        print("Written to \(destinationURL.path)")
    }
}

// MARK: - Line Heights

let titleText = "My Definitive Front Matter"
let bodyText = """
With every static site generator, you can write your posts or pages with Markdown or CommonMark files in which you can include some structured metadata called a Front Matter.
"""

struct TextStyle {
    let font: UIFont
    let lineHeight: CGFloat
}

class LineHeightedLabel: UIView {
    // MARK: - Creating a LineHeightedLabel

    init(text: String?, textStyle: TextStyle) {
        wrappedLabel = UILabel()
        self.textStyle = textStyle
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViewAndConstraints()
        setText(text: text)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Inspecting the view

    let wrappedLabel: UILabel
    let textStyle: TextStyle

    var text: String? {
        get {
            wrappedLabel.text
        }

        set {
            setText(text: newValue)
        }
    }

    private var topYAxisConstraint: NSLayoutConstraint?

    private func setupViewAndConstraints() {
        wrappedLabel.translatesAutoresizingMaskIntoConstraints = false
        wrappedLabel.font = textStyle.font
        addSubview(wrappedLabel)

        let safeTopYAxisConstraint = topAnchor.constraint(equalTo: wrappedLabel.topAnchor)
        topYAxisConstraint = safeTopYAxisConstraint

        NSLayoutConstraint.activate([
            safeTopYAxisConstraint,
            leadingAnchor.constraint(equalTo: wrappedLabel.leadingAnchor),
            trailingAnchor.constraint(equalTo: wrappedLabel.trailingAnchor),
            centerYAnchor.constraint(equalTo: wrappedLabel.centerYAnchor)
        ])
    }

    func setText(text: String?) {
        guard let text = text else {
            topYAxisConstraint?.constant = 0.0
            wrappedLabel.text = nil
            return
        }

        let lineSpacing = textStyle.lineHeight - textStyle.font.lineHeight

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = wrappedLabel.textAlignment

        // Build an attributed string
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        topYAxisConstraint?.constant = -(lineSpacing / 2.0)
        wrappedLabel.attributedText = attributedString
    }
}

class MyViewController: UIViewController {
    let imageView: UIImageView = {
        let res = UIImageView()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.alpha = 0.2
        res.image = UIImage(named: "CardDesignSketch")
        return res
    }()

    let titleLabel: LineHeightedLabel = {
        let res = LineHeightedLabel(
            text: titleText,
            textStyle: TextStyle(
                font: .preferredFont(forTextStyle: .title1),
                lineHeight: 38.0
            )
        )
        res.wrappedLabel.textColor = .systemBlue
        return res
    }()

    let bodyLabel: LineHeightedLabel = {
        let res = LineHeightedLabel(
            text: bodyText,
            textStyle: TextStyle(
                font: .preferredFont(forTextStyle: .body),
                lineHeight: 24.0
            )
        )
        res.translatesAutoresizingMaskIntoConstraints = false
        res.wrappedLabel.numberOfLines = 0
        return res
    }()

    let borderBottomView: UIView = {
        let res = UIView()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.backgroundColor = .black
        return res
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(borderBottomView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),

            // Either the appropriate constraints for text views.
            // titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            // Or a common top anchor constraint
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),

            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            bodyLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor, multiplier: 1),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            borderBottomView.topAnchor.constraint(equalToSystemSpacingBelow: bodyLabel.bottomAnchor, multiplier: 1),
            borderBottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            borderBottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            borderBottomView.heightAnchor.constraint(equalToConstant: 1)
        ])

        self.view = view
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.asImage().saveAs()
    }
}

let useLineSpacing = false
class MyViewControllerWithoutLineHeights: UIViewController {
    let imageView: UIImageView = {
        let res = UIImageView()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.alpha = 0.2
        res.image = UIImage(named: "CardDesignSketch")
        return res
    }()

    let titleLabel: UILabel = {
        let res = UILabel()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.font = .preferredFont(forTextStyle: .title1)
        res.textColor = .systemBlue

        if useLineSpacing {
            let attributedString = NSMutableAttributedString(string: titleText)
            let lineSpacing = 38.0 - res.font.lineHeight
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing

            attributedString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
            )

            res.attributedText = attributedString
        } else {
            res.text = titleText
        }

        return res
    }()

    let bodyLabel: UILabel = {
        let res = UILabel()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.numberOfLines = 0

        if useLineSpacing {
            let attributedString = NSMutableAttributedString(string: bodyText)
            let lineSpacing = 24.0 - res.font.lineHeight
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing

            attributedString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
            )

            res.attributedText = attributedString
        } else {
            // Use a font with tuned metrics
            res.font = .init(
                descriptor: UIFontDescriptor
                    .preferredFontDescriptor(withTextStyle: .body)
                    .withSymbolicTraits(.traitLooseLeading)!,
                size: 0
            )
            res.text = bodyText
        }

        return res
    }()

    let borderBottomView: UIView = {
        let res = UIView()
        res.translatesAutoresizingMaskIntoConstraints = false
        res.backgroundColor = .black
        return res
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(borderBottomView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),

            // Either the appropriate constraints for text views.

            titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            // Or a common top anchor constraint
            // titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            bodyLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor, multiplier: 1.4),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            borderBottomView.topAnchor.constraint(equalToSystemSpacingBelow: bodyLabel.lastBaselineAnchor, multiplier: 1),
            borderBottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            borderBottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            borderBottomView.heightAnchor.constraint(equalToConstant: 1)
        ])

        self.view = view
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.asImage().saveAs()
    }
}

// Present the view controller in the Live View window
let viewController = MyViewControllerWithoutLineHeights()
PlaygroundPage.current.liveView = viewController
