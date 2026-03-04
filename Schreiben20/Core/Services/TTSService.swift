//
//  TTSService.swift
//  Schreiben 2.0
//
//  Service für Text-to-Speech / Lautierende Tastatur
//  Nutzt AVSpeechSynthesizer für deutsche Sprachausgabe
//

import Foundation
import AVFoundation
import Combine

/// Vorlese-Modus für die Lautierung
enum ReadingMode: String, CaseIterable, Identifiable {
    case letter = "Buchstabe"
    case word = "Wort"
    case off = "Aus"

    var id: String { rawValue }
}

/// Service für Text-to-Speech mit AVSpeechSynthesizer
class TTSService: NSObject, ObservableObject {
    /// TTS aktiviert
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "schreiben20.ttsEnabled")
            if !isEnabled { stop() }
        }
    }

    /// Sprechgeschwindigkeit (0.0-1.0)
    @Published var rate: Float {
        didSet {
            let clamped = min(max(rate, 0.1), 1.0)
            if clamped != rate { rate = clamped }
            UserDefaults.standard.set(Double(rate), forKey: "schreiben20.ttsRate")
        }
    }

    /// Vorlese-Modus
    @Published var readingMode: ReadingMode {
        didSet {
            UserDefaults.standard.set(readingMode.rawValue, forKey: "schreiben20.ttsReadingMode")
        }
    }

    /// Wird gerade vorgelesen
    @Published private(set) var isSpeaking: Bool = false

    /// ID der gewählten Stimme (nil = System-Standard)
    @Published var selectedVoiceID: String? {
        didSet {
            UserDefaults.standard.set(selectedVoiceID, forKey: "schreiben20.ttsVoiceID")
        }
    }

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        // Lade gespeicherte Einstellungen
        self.isEnabled = UserDefaults.standard.object(forKey: "schreiben20.ttsEnabled") as? Bool ?? true
        let savedRate = UserDefaults.standard.double(forKey: "schreiben20.ttsRate")
        self.rate = savedRate > 0 ? Float(savedRate) : 0.4
        let savedMode = UserDefaults.standard.string(forKey: "schreiben20.ttsReadingMode")
        self.readingMode = ReadingMode(rawValue: savedMode ?? "") ?? .letter
        self.selectedVoiceID = UserDefaults.standard.string(forKey: "schreiben20.ttsVoiceID")

        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public Methods

    /// Spricht einen einzelnen Buchstaben aus
    func speakLetter(_ letter: String) {
        guard isEnabled, !letter.isEmpty else { return }
        let utterance = makeUtterance(letter)
        // Langsamere Rate für einzelne Buchstaben
        utterance.rate = max(rate * 0.7, AVSpeechUtteranceMinimumSpeechRate)
        speak(utterance)
    }

    /// Spricht ein Wort aus
    func speakWord(_ word: String) {
        guard isEnabled, !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let utterance = makeUtterance(word.trimmingCharacters(in: .whitespacesAndNewlines))
        speak(utterance)
    }

    /// Spricht den gesamten Text aus
    func speakText(_ text: String) {
        guard isEnabled, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let utterance = makeUtterance(text.trimmingCharacters(in: .whitespacesAndNewlines))
        speak(utterance)
    }

    /// Stoppt die aktuelle Sprachausgabe
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    /// Gibt verfügbare deutsche Stimmen zurück
    func availableGermanVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("de") }
    }

    // MARK: - Private Methods

    private func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate * (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate) + AVSpeechUtteranceMinimumSpeechRate

        // Stimme setzen
        if let voiceID = selectedVoiceID, let voice = AVSpeechSynthesisVoice(identifier: voiceID) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        }

        return utterance
    }

    private func speak(_ utterance: AVSpeechUtterance) {
        // Laufende Sprachausgabe stoppen
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension TTSService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}
