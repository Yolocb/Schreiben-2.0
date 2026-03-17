//
//  DrawingCanvasViewModelTests.swift
//  Schreiben 2.0
//
//  Tests für DrawingCanvasViewModel
//

import XCTest
import PencilKit
@testable import Schreiben20

final class DrawingCanvasViewModelTests: XCTestCase {

    var sut: DrawingCanvasViewModel!

    override func setUp() {
        super.setUp()
        sut = DrawingCanvasViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialState() {
        XCTAssertEqual(sut.drawing.strokes.count, 0, "Initiale Zeichnung sollte leer sein")
        XCTAssertTrue(sut.showToolPicker, "Tool Picker sollte initial sichtbar sein")
        XCTAssertFalse(sut.hasUnsavedChanges, "Keine ungespeicherten Änderungen initial")
        XCTAssertEqual(sut.selectedTool, .pen, "Standard-Werkzeug sollte Stift sein")
        XCTAssertFalse(sut.canUndo, "Undo sollte initial nicht möglich sein")
        XCTAssertFalse(sut.canRedo, "Redo sollte initial nicht möglich sein")
    }

    func testInitWithMediaItemID() {
        let id = UUID()
        let vm = DrawingCanvasViewModel(mediaItemID: id)
        XCTAssertEqual(vm.mediaItemID, id, "MediaItem-ID sollte gesetzt sein")
    }

    func testDrawingChanged() {
        let newDrawing = PKDrawing()
        sut.drawingDidChange(newDrawing)

        XCTAssertTrue(sut.hasUnsavedChanges, "Änderung sollte markiert werden")
        XCTAssertTrue(sut.canUndo, "Undo sollte nach Änderung möglich sein")
    }

    func testUndo() {
        let drawing1 = PKDrawing()
        let drawing2 = PKDrawing()

        sut.drawingDidChange(drawing1)
        sut.drawingDidChange(drawing2)

        sut.undo()

        XCTAssertTrue(sut.canRedo, "Redo sollte nach Undo möglich sein")
        XCTAssertTrue(sut.canUndo, "Weiteres Undo sollte möglich sein")
    }

    func testRedo() {
        let drawing1 = PKDrawing()

        sut.drawingDidChange(drawing1)
        sut.undo()
        sut.redo()

        XCTAssertFalse(sut.canRedo, "Redo sollte nach letztem Redo nicht mehr möglich sein")
    }

    func testClearCanvas() {
        let drawing1 = PKDrawing()
        sut.drawingDidChange(drawing1)

        sut.clearCanvas()

        XCTAssertEqual(sut.drawing.strokes.count, 0, "Canvas sollte leer sein")
        XCTAssertTrue(sut.hasUnsavedChanges, "Löschen sollte als Änderung gelten")
        XCTAssertTrue(sut.canUndo, "Undo nach Löschen sollte möglich sein")
    }

    func testSetInitialDrawing() {
        let drawing = PKDrawing()
        sut.drawingDidChange(drawing) // Create some history

        let initialDrawing = PKDrawing()
        sut.setInitialDrawing(initialDrawing)

        XCTAssertFalse(sut.hasUnsavedChanges, "Nach setInitialDrawing keine ungespeicherten Änderungen")
        XCTAssertFalse(sut.canUndo, "Undo-Stack sollte gelöscht sein")
        XCTAssertFalse(sut.canRedo, "Redo-Stack sollte gelöscht sein")
    }

    func testMarkAsSaved() {
        let drawing = PKDrawing()
        sut.drawingDidChange(drawing)
        XCTAssertTrue(sut.hasUnsavedChanges)

        sut.markAsSaved()
        XCTAssertFalse(sut.hasUnsavedChanges, "Nach Speichern keine ungespeicherten Änderungen")
    }
}
