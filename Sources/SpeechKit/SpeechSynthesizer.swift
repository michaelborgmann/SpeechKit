//
//  SpeechSynthesizer.swift
//  SpeechKit
//
//  Created by Michael Borgmann on 09/07/2025.
//

import AVFoundation

@Observable
public final class SpeechSynthesizer {
    
    // MARK: - Properties
    
    /// The underlying Apple speech synthesizer instance.
    @ObservationIgnored
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Enables debug logging during development.
    private let debug = false
    
    // MARK: - State
    
    /// Whether the synthesizer is actively speaking.
    public var isSpeaking = false
    
    /// The last spoken text (if any).
    public var currentUtterance: String?
    
    /// The most recent error, if any occurred during synthesis.
    public var error: SpeechSynthesisError?
    
    // MARK: - Callbacks
    
    /// Called when a synthesis error occurs (optional for UI updates).
    public var onError: ((SpeechSynthesisError) -> Void)?
    
    // MARK: - Configuration
    
    /// Speech rate (0.1–1.0). Default: 0.45 (slower for kids).
    public var rate: Float = 0.45
    
    /// Pitch multiplier (0.5–2.0). Default: 1.2 (child-like).
    public var pitch: Float = 1.2
    
    /// Volume (0.0–1.0). Default: 1.0 (full).
    public var volume: Float = 1.0

    /// The default language to use (e.g., "en-US", "pt-PT").
    public var language: String = "en-US"
    
    // MARK: - Lifecycle
    
    /// Creates a new speech synthesizer instance.
    public init() {}

    // MARK: - Actions
    
    /// Speaks the given text using the current speech configuration.
    ///
    /// - Parameters:
    ///   - text: The text to be spoken aloud.
    ///   - language: (Optional) Overrides the default language for this utterance, e.g. `"pt-PT"`.
    public func speak(text: String, language: String? = nil) {
        guard !text.isEmpty else { return }

        // Stop any ongoing speech to avoid queuing
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let selectedLanguage = language ?? self.language
        
        // Check if the language is actually available on this device
        let availableLanguages = Set(AVSpeechSynthesisVoice.speechVoices().map(\.language))
        let isAvailable = availableLanguages.contains(selectedLanguage)

        if !isAvailable {
            if debug {
                print("[SpeechSynthesizer] No installed voice for language: \(selectedLanguage). iOS may fall back.")
            }

            let err = SpeechSynthesisError.voiceUnavailable(selectedLanguage)
            self.error = err
            self.onError?(err)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language ?? self.language)
        utterance.volume = volume
        utterance.rate = rate
        utterance.pitchMultiplier = pitch

        currentUtterance = text
        isSpeaking = true
        
        if debug {
            print("[SpeechSynthesizer] Speaking: \"\(text)\" in \(utterance.voice?.language ?? "unknown")")
        }
        
        synthesizer.speak(utterance)
    }
    
    /// Pauses the current speech at the next word boundary.
    public func pause() {
        synthesizer.pauseSpeaking(at: .word)
        isSpeaking = false
        if debug {
            print("[SpeechSynthesizer] Paused")
        }
    }

    /// Resumes speech that was previously paused.
    public func resume() {
        synthesizer.continueSpeaking()
        isSpeaking = true
        if debug {
            print("[SpeechSynthesizer] Resumed")
        }
    }

    /// Stops all ongoing speech immediately.
    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        if debug {
            print("[SpeechSynthesizer] Stopped")
        }
    }
}
