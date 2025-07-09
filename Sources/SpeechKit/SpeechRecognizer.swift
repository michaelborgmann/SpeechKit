//
//  SpeechRecognizer.swift
//  SpeechKit
//
//  Created by Michael Borgmann on 09/07/2025.
//

import Speech

@Observable
public final class SpeechRecognizer {
    
    // MARK: Properties
    
    /// The speech recognizer instance for the configured locale.
    private var speechRecognizer = SFSpeechRecognizer()
    
    /// The live audio stream request sent to the recognizer.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// The current speech recognition task handling results and errors.
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// The audio engine used to capture microphone input.
    private let audioEngine: AVAudioEngine
    
    /// Enables internal debug logging when set to `true`.
    private var debug = false

    // MARK: Exposed Properties
    
    /// The transcribed text from the current or most recent recording.
    public var transcript: String = ""
    
    /// Indicates whether the recognizer is actively listening.
    public var isListening = false
    
    /// The most recent error, if any occurred during recognition.
    public var error: SpeechRecognitionError?
    
    /// Change to desired locale, e.g. Locale(identifier: "pt-PT")
    public var language: Locale = Locale(identifier: "en-US") {
        didSet {
            speechRecognizer = SFSpeechRecognizer(locale: language)
        }
    }
    
    /// Whether speech recognition is available for the selected language.
    public var isAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }
    
    // MARK: Callbacks
    
    /// Called whenever the transcript is updated with partial or final results.
    public var onTranscriptUpdate: ((String) -> Void)?

    /// Called when a recognition error occurs.
    public var onError: ((SpeechRecognitionError) -> Void)?

    /// Called when recording successfully begins.
    public var onStart: (() -> Void)?

    /// Called when recording stops. Provides the final transcript, if any.
    public var onStop: ((String?) -> Void)?
    
    // MARK: Lifecycle
    
    /// Creates a new instance of `SpeechRecognizer`.
    /// - Parameters:
    ///   - locale: The language locale for recognition (default is `"en-US"`).
    ///   - recognizer: Optional custom recognizer (used for testing or configuration).
    ///   - debug: Whether to print debug logs during recognition.
    public init(
        locale: Locale = Locale(identifier: "en-US"),
        recognizer: SFSpeechRecognizer? = nil,
        debug: Bool = false
    ) {
        self.language = locale
        self.speechRecognizer = recognizer ?? SFSpeechRecognizer(locale: locale)
        self.audioEngine = AVAudioEngine()
        self.debug = debug
    }
    
    // MARK: Actions

    /// Begins speech recognition using the configured locale.
    ///
    /// If recognition is already running, this call does nothing.
    /// Will request authorization from the user if not yet granted.
    /// Any existing errors are cleared before starting.
    public func startRecording() {
        
        guard !isListening else { return } // Already recording
        stopRecording() // Cleanup in case already running
        reset()
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self else { return }
            
            switch status {
            case .authorized:
                do {
                    try self.beginTranscription()
                } catch let error as SpeechRecognitionError {
                    self.error = error
                    self.onError?(error)
                } catch {
                    let wrapped = SpeechRecognitionError.recognitionError(error)
                    self.error = wrapped
                    self.onError?(wrapped)
                }
            default:
                self.error = .notAuthorized
                self.onError?(.notAuthorized)
            }
        }
    }
    
    /// Stops the current speech recognition session.
    ///
    /// Ends the audio stream, cancels the recognition task,
    /// and deactivates the audio session. Also triggers `onStop`.
    public func stopRecording() {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil

        do {
            try configureAudioSession(category: .playback, mode: .default)
        } catch {
            if debug {
                print("[SpeechRecognizer] Failed to reconfigure session: \(error)")
            }
            
            // ⚠️ Optional: Surface this error to the user only if it impacts playback functionality.
            // Since recording has already completed successfully, this failure is usually harmless.
            // If playback fails later due to audio session issues, you may want to handle it there instead.
            
            // Uncomment if you decide to surface the error:
            // let err = SpeechRecognitionError.recognitionError(error)
            // self.error = err
            // self.onError?(err)
        }

        isListening = false
        
        onStop?(transcript.isEmpty ? nil : transcript)
        
        error = nil
    }
    
    // MARK: Helper
    
    /// Configures and starts the transcription process.
    ///
    /// - Throws: A `SpeechRecognitionError` if the recognizer is unavailable
    ///           or the audio engine cannot start.
    internal func beginTranscription() throws {
        
        // Ensure the selected speech recognizer is ready
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.unavailable
        }

        // Configure the audio session for recording mode
        try configureAudioSession(category: .record, mode: .measurement)

        // Reset state
        isListening = true

        // Create a request to stream audio to the recognizer
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        // Setup the audio input
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Ensure we don't double-attach taps
        inputNode.removeTap(onBus: 0)

        // Attach a tap to the audio stream and feed it to the recognition request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // Start the recognition task
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.audioEngineError
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                // Update the transcript with what was heard so far
                let text = result.bestTranscription.formattedString
                self.transcript = text
                self.onTranscriptUpdate?(text)
            }

            if let error {
                // Capture any errors and stop the session
                let err = SpeechRecognitionError.recognitionError(error)
                self.error = err
                self.onError?(err)
                self.stopRecording()
            }
        }

        // Start the audio engine to begin capturing microphone input
        audioEngine.prepare()
        do {
            try audioEngine.start()
            onStart?()
        } catch {
            throw SpeechRecognitionError.audioEngineError
        }
    }
    
    /// Resets the recognizer's output state.
    ///
    /// Clears the current transcript and error.
    /// Called before starting a new recording session to ensure a clean slate.
    internal func reset() {
        transcript = ""
        error = nil
    }
    
    /// Configures the `AVAudioSession` with the given category and mode.
    ///
    /// - Parameters:
    ///   - category: The audio session category to apply (e.g., `.record`, `.playback`).
    ///   - mode: The session mode (e.g., `.measurement`, `.default`).
    /// - Throws: An error if the session fails to configure or activate.
    private func configureAudioSession(category: AVAudioSession.Category, mode: AVAudioSession.Mode) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(category, mode: mode, options: .duckOthers)
        try session.setActive(true, options: [])
    }
}
