//
//  SpeechSynthesizerTests.swift
//  SpeechKit
//
//  Created by Michael Borgmann on 09/07/2025.
//

import Testing
@testable import SpeechKit

struct SpeechSynthesizerTests {

    @Test func speak_setsUtteranceAndSpeakingState() {
        let synth = SpeechSynthesizer()
        synth.language = "en-US"
        synth.speak(text: "Hello!")

        #expect(synth.currentUtterance == "Hello!")
        #expect(synth.isSpeaking == true)
    }

    @Test func speak_ignoresEmptyText() {
        let synth = SpeechSynthesizer()
        synth.speak(text: "")

        #expect(synth.currentUtterance == nil)
        #expect(synth.isSpeaking == false)
    }

    @Test func pause_setsSpeakingToFalse() {
        let synth = SpeechSynthesizer()
        synth.pause()
        #expect(synth.isSpeaking == false)
    }

    @Test func stop_setsSpeakingToFalse() {
        let synth = SpeechSynthesizer()
        synth.stop()
        #expect(synth.isSpeaking == false)
    }

    @Test func speak_firesVoiceUnavailableError_forMissingLanguage() {
        let synth = SpeechSynthesizer()
        synth.language = "zz-ZZ" // known to be unavailable
        var capturedError: SpeechSynthesisError?
        synth.onError = { capturedError = $0 }

        synth.speak(text: "Hello")

        if case .voiceUnavailable(let lang) = capturedError {
            debugPrint(lang)
            #expect(lang == "zz-ZZ")
        } else {
            Issue.record("Expected .voiceUnavailable error, got \(String(describing: capturedError))")
        }
    }
}
