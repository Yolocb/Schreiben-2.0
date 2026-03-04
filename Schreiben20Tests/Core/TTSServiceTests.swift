//
//  TTSServiceTests.swift
//  Schreiben20Tests
//
//  Unit-Tests für den TTSService
//

import XCTest
import Combine
@testable import Schreiben20

final class TTSServiceTests: XCTestCase {

    var ttsService: TTSService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // UserDefaults für Tests zurücksetzen
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsEnabled")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsRate")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsReadingMode")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsVoiceID")

        ttsService = TTSService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        ttsService.stop()
        ttsService = nil
        cancellables = nil

        // Aufräumen
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsEnabled")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsRate")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsReadingMode")
        UserDefaults.standard.removeObject(forKey: "schreiben20.ttsVoiceID")
    }

    // MARK: - Initialization Tests

    func testTTSServiceInitialization() {
        // Assert: Standardwerte
        XCTAssertTrue(ttsService.isEnabled)
        XCTAssertEqual(ttsService.rate, 0.4, accuracy: 0.01)
        XCTAssertEqual(ttsService.readingMode, .letter)
        XCTAssertFalse(ttsService.isSpeaking)
        XCTAssertNil(ttsService.selectedVoiceID)
    }

    // MARK: - Toggle Tests

    func testTTSEnabledToggle() {
        // Act
        ttsService.isEnabled = false

        // Assert
        XCTAssertFalse(ttsService.isEnabled)

        // Act
        ttsService.isEnabled = true

        // Assert
        XCTAssertTrue(ttsService.isEnabled)
    }

    func testTTSRateChange() {
        // Act
        ttsService.rate = 0.8

        // Assert
        XCTAssertEqual(ttsService.rate, 0.8, accuracy: 0.01)
    }

    func testTTSRateClampedToMinimum() {
        // Act
        ttsService.rate = 0.0

        // Assert: Sollte auf 0.1 geclampt werden
        XCTAssertEqual(ttsService.rate, 0.1, accuracy: 0.01)
    }

    func testTTSRateClampedToMaximum() {
        // Act
        ttsService.rate = 2.0

        // Assert: Sollte auf 1.0 geclampt werden
        XCTAssertEqual(ttsService.rate, 1.0, accuracy: 0.01)
    }

    // MARK: - Persistence Tests

    func testTTSEnabledPersistence() {
        // Act
        ttsService.isEnabled = false

        // Assert: Wert in UserDefaults gespeichert
        let saved = UserDefaults.standard.bool(forKey: "schreiben20.ttsEnabled")
        XCTAssertFalse(saved)

        // Neuer Service sollte gespeicherten Wert laden
        let newService = TTSService()
        XCTAssertFalse(newService.isEnabled)
    }

    func testTTSRatePersistence() {
        // Act
        ttsService.rate = 0.7

        // Assert: Wert in UserDefaults gespeichert
        let saved = UserDefaults.standard.double(forKey: "schreiben20.ttsRate")
        XCTAssertEqual(saved, 0.7, accuracy: 0.01)

        // Neuer Service sollte gespeicherten Wert laden
        let newService = TTSService()
        XCTAssertEqual(newService.rate, 0.7, accuracy: 0.01)
    }

    func testTTSReadingModePersistence() {
        // Act
        ttsService.readingMode = .word

        // Assert
        let saved = UserDefaults.standard.string(forKey: "schreiben20.ttsReadingMode")
        XCTAssertEqual(saved, "Wort")

        // Neuer Service sollte gespeicherten Wert laden
        let newService = TTSService()
        XCTAssertEqual(newService.readingMode, .word)
    }

    func testTTSVoiceIDPersistence() {
        // Act
        ttsService.selectedVoiceID = "com.apple.voice.compact.de-DE.Anna"

        // Assert
        let saved = UserDefaults.standard.string(forKey: "schreiben20.ttsVoiceID")
        XCTAssertEqual(saved, "com.apple.voice.compact.de-DE.Anna")
    }

    // MARK: - Disabled State Tests

    func testSpeakLetterWhenDisabled() {
        // Arrange
        ttsService.isEnabled = false

        // Act: Sollte nicht abstürzen
        ttsService.speakLetter("A")

        // Assert: Kein Crash, nicht sprechend
        XCTAssertFalse(ttsService.isSpeaking)
    }

    func testSpeakWordWhenDisabled() {
        // Arrange
        ttsService.isEnabled = false

        // Act: Sollte nicht abstürzen
        ttsService.speakWord("Hallo")

        // Assert
        XCTAssertFalse(ttsService.isSpeaking)
    }

    func testSpeakTextWhenDisabled() {
        // Arrange
        ttsService.isEnabled = false

        // Act
        ttsService.speakText("Dies ist ein Test")

        // Assert
        XCTAssertFalse(ttsService.isSpeaking)
    }

    // MARK: - Edge Case Tests

    func testSpeakEmptyLetter() {
        // Act: Leerer String sollte nicht abstürzen
        ttsService.speakLetter("")

        // Assert
        XCTAssertFalse(ttsService.isSpeaking)
    }

    func testSpeakEmptyWord() {
        // Act
        ttsService.speakWord("   ")

        // Assert
        XCTAssertFalse(ttsService.isSpeaking)
    }

    func testStopWhenNotSpeaking() {
        // Act: Stop ohne aktive Sprache sollte nicht abstürzen
        ttsService.stop()

        // Assert
        XCTAssertFalse(ttsService.isSpeaking)
    }

    // MARK: - Reading Mode Tests

    func testReadingModeAllCases() {
        XCTAssertEqual(ReadingMode.allCases.count, 3)
        XCTAssertEqual(ReadingMode.letter.rawValue, "Buchstabe")
        XCTAssertEqual(ReadingMode.word.rawValue, "Wort")
        XCTAssertEqual(ReadingMode.off.rawValue, "Aus")
    }

    // MARK: - Available Voices Test

    func testAvailableGermanVoices() {
        // Act
        let voices = ttsService.availableGermanVoices()

        // Assert: Auf echtem Gerät sollten deutsche Stimmen vorhanden sein
        // In CI/Tests kann dies leer sein, daher nur prüfen dass kein Crash
        XCTAssertNotNil(voices)
    }
}
