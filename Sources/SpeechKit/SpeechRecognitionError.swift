//
//  SpeechRecognitionError.swift
//  SpeechKit
//
//  Created by Michael Borgmann on 09/07/2025.
//

import Foundation

public enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case unavailable
    case audioEngineError
    case recognitionError(Error)

    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return NSLocalizedString("Oops! We can't hear you.", comment: "")
        case .unavailable:
            return NSLocalizedString("Speech isn’t available on this device.", comment: "")
        case .audioEngineError:
            return NSLocalizedString("Something went wrong with the microphone.", comment: "")
        case .recognitionError(let error):
            return error.localizedDescription
        }
    }

    public var failureReason: String? {
        switch self {
        case .notAuthorized:
            return NSLocalizedString("The app doesn’t have permission to use the microphone.", comment: "")
        case .unavailable:
            return NSLocalizedString("Speech recognition might be turned off or unsupported on this device.", comment: "")
        case .audioEngineError:
            return NSLocalizedString("Audio input couldn’t start or stopped unexpectedly.", comment: "")
        case .recognitionError:
            return NSLocalizedString("The speech recognition process encountered a problem.", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notAuthorized:
            return NSLocalizedString("Please allow microphone access in Settings.", comment: "")
        case .unavailable:
            return NSLocalizedString("Try updating your device or checking region settings.", comment: "")
        case .audioEngineError:
            return NSLocalizedString("Try restarting the app or checking microphone access.", comment: "")
        case .recognitionError:
            return NSLocalizedString("Please try speaking again or check your internet connection.", comment: "")
        }
    }
}
