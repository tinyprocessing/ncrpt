import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    init(show pdfDoc: PDFDocument) {
        pdfDocument = pdfDoc
    }

    func makeUIView(context: Context) -> ClearPDFView {
        let pdfView = ClearPDFView()
        pdfView.document = pdfDocument
        pdfView.enableDataDetectors = false
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: ClearPDFView, context: Context) {
        let allSubviews = pdfView.allSubViewsOf(type: UIView.self)
        for gestureRec in allSubviews.compactMap({ $0.gestureRecognizers }).flatMap({ $0 }) {
            if gestureRec is UILongPressGestureRecognizer {
                gestureRec.isEnabled = false
            }
        }
        pdfView.document = pdfDocument
    }
}

class ClearPDFView: PDFView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        currentSelection = nil
        clearSelection()
        return false
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - extension

extension PDFView {
    func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all: [T] = []
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard !view.subviews.isEmpty else { return }
            view.subviews.forEach { getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}
