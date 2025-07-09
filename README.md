# SpeechKit

![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg?logo=swift)
![iOS](https://img.shields.io/badge/iOS-17%2B-blue.svg?logo=apple)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen?logo=swift)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
![Version](https://img.shields.io/github/v/tag/michaelborgmann/SpeechKit?label=release)
![Tests](https://github.com/michaelborgmann/SpeechKit/actions/workflows/test.yml/badge.svg)

🎙 A lightweight Swift package for speech recognition and synthesis on iOS.  
Built for modern Swift apps, tested with Swift Testing, and ready for SwiftUI.

---

## Features

- ✅ `SpeechRecognizer` — handles speech-to-text with configurable language support and UI callbacks
- ✅ `SpeechSynthesizer` — speaks text aloud with adjustable pitch, rate, and language
- ✅ Child-friendly defaults for storytelling apps
- ✅ Modern `@Observable` state management (no delegates!)
- ✅ Safe fallback behavior and clear error reporting
- ✅ Fully documented with DocC-style comments
- ✅ Tested using Swift's native `import Testing` framework

---

## Installation

Use **Swift Package Manager** to add the library:

```swift
.package(url: "https://github.com/michaelborgmann/SpeechKit.git", from: "0.1.0")
```

Then import it in your code:

```swift
import SpeechKit
```

---

## Usage

### 🗣 Speech Recognition

```swift
let recognizer = SpeechRecognizer()
recognizer.language = Locale(identifier: "en-US")
recognizer.onTranscriptUpdate = { print("Partial: \($0)") }
recognizer.onStop = { print("Final result: \($0 ?? "")") }

recognizer.startRecording()
// ...
recognizer.stopRecording()
```

### 🔊 Speech Synthesis

```swift
let speaker = SpeechSynthesizer()
speaker.language = "pt-PT"
speaker.pitch = 1.2
speaker.speak(text: "Olá! Bem-vindo ao nosso app.")
```

---

## Requirements

- iOS 17+ (due to `@Observable` macro support)
- Swift 5.9 or Swift 6
- Swift Concurrency-compatible
- Swift Package Manager (SPM)

---

## License

MIT License — see LICENSE

Please credit this project if you use it in commercial or open-source apps.

---

## About

Created by [Michael Borgmann](https://github.com/michaelborgmann) for the Wonder Tales storytelling engine.
Part of the [Vicentina Studios](https://github.com/VicentinaStudios) toolchain for creative, language-rich experiences.
