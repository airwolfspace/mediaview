import Cocoa
import SwiftUI
import Quartz


struct ASMediaViewGIFAnimationView: NSViewRepresentable {
    var imageURL: URL

    func makeNSView(context: Context) -> some NSView {
        let preview = ASMediaGIFImageView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = imageURL as QLPreviewItem
        return preview ?? ASMediaGIFImageView()
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let preview = nsView as? ASMediaGIFImageView else { return }
        preview.previewItem = imageURL as QLPreviewItem
    }
}
