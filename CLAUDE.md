# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of Swift Xcode playgrounds demonstrating various Swift programming concepts and patterns, primarily used for blog posts on `mickf.net/tech`. Each playground is self-contained and focuses on a specific topic.

## Development Commands

### Linting and Formatting

```bash
./lintfix.sh  # Runs SwiftLint autocorrect and SwiftFormat
```

### Manual linting

```bash
swiftlint autocorrect .
swiftformat .
```

## Code Style Configuration

- **SwiftLint**: Configured in `.swiftlint.yml`

  - `id` is excluded from identifier naming rules
  - Line length ignores comments

- **SwiftFormat**: Configured in `.swiftformat`
  - Trailing commas are disabled
  - Multiline statement braces wrapping is disabled
  - Arguments wrap before first argument

## Playground Structure

Each playground is independent and typically contains:

- Main `Contents.swift` file with implementation and documentation
- Some playgrounds have multiple pages (e.g., `JSON-date.playground` has "The Problem" and "A Solution" pages)
- Inline documentation using Swift's markup format

## Key Playgrounds

- **PKCE.playground**: Implements OAuth PKCE flow with cryptographically secure code generation
- **JSON-date.playground**: Demonstrates date decoding challenges and solutions with Swift's Codable
- **line-height.playground**: UIKit line height implementation
- **activating-opentype-features.playground**: OpenType features in iOS
