//
//  SpeechRecognizerTests.swift
//  SpeechKitTests
//
//  Created by Michael Borgmann on 09/07/2025.
//

import Testing
@testable import SpeechKit
import Speech

#if TESTING
extension SpeechRecognizer {
    func testableReset() {
        self.reset()
    }

    func testableBeginTranscription() throws {
        try self.beginTranscription()
    }
}
#endif

final class MockSpeechRecognizer: SFSpeechRecognizer {
    override var isAvailable: Bool { true }
}

struct WonderTalesTests {

    @Test func reset_clearsTranscriptAndError() {
        let recognizer = SpeechRecognizer()
        recognizer.transcript = "Old transcript"
        recognizer.error = .notAuthorized

        recognizer.testableReset()

        #expect(recognizer.transcript == "")
        #expect(recognizer.error == nil)
    }

    @Test func startRecording_doesNotProceedWhenAlreadyListening() {
        let recognizer = SpeechRecognizer()
        recognizer.isListening = true

        recognizer.startRecording()

        #expect(recognizer.isListening == true) // Should not change
        // We can't test much more here without mocking audio
    }
    
    @Test func onStartCallback_isCalledInBeginTranscription() throws {
        let recognizer = SpeechRecognizer(recognizer: MockSpeechRecognizer())
        var wasCalled = false
        recognizer.onStart = { wasCalled = true }

        try recognizer.testableBeginTranscription()

        #expect(wasCalled)
        #expect(recognizer.isListening)
    }
}
