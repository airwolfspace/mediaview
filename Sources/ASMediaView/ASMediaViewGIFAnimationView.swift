import Cocoa
import SwiftUI


struct ASMediaViewGIFAnimationView: NSViewRepresentable {
    var image: NSImage

    func makeNSView(context: Context) -> some NSView {
        let imageView = ASMediaImageView(image: image)
        return imageView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let imageView = nsView as? ASMediaImageView else { return }
        imageView.image = image
    }
}
