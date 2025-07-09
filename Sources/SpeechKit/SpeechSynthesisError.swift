//
//  SpeechSynthesisError.swift
//  SpeechKit
//
//  Created by Michael Borgmann on 09/07/2025.
//

import Foundation

public enum SpeechSynthesisError: LocalizedError {
    
    case voiceUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .voiceUnavailable:
            return NSLocalizedString("This language is not supported for speech.", comment: "")
        }
    }

    public var failureReason: String? {
        switch self {
        case .voiceUnavailable(let lang):
            return NSLocalizedString("No speech voice is available for the language code '\(lang)'.", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .voiceUnavailable:
            return NSLocalizedString("Try selecting another language in the app settings.", comment: "")
        }
    }
}
