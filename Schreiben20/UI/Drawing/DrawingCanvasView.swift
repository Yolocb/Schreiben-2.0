//
//  DrawingCanvasView.swift
//  Schreiben 2.0
//
//  PencilKit-Zeichenfläche als UIViewRepresentable
//

import SwiftUI
import PencilKit

/// SwiftUI-Wrapper für PKCanvasView
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var toolPickerIsActive: Bool
    var backgroundColor: UIColor = .white
    var onDrawingChanged: ((PKDrawing) -> Void)?

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = backgroundColor
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput // Finger + Apple Pencil
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)

        // Tool Picker
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            context.coordinator.toolPicker = toolPicker

            if toolPickerIsActive {
                canvasView.becomeFirstResponder()
            }
        }

        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if canvasView.drawing != drawing {
            canvasView.drawing = drawing
        }

        if let toolPicker = context.coordinator.toolPicker {
            toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvasView)
            if toolPickerIsActive {
                canvasView.becomeFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        var toolPicker: PKToolPicker?

        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
            parent.onDrawingChanged?(canvasView.drawing)
        }
    }
}
