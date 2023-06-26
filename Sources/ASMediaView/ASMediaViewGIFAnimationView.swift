import Cocoa
import SwiftUI


struct ASMediaViewGIFAnimationView: NSViewRepresentable {
    var image: NSImage

    func makeNSView(context: Context) -> some NSView {
        let imageView = NSImageView(image: image)
        imageView.animates = true
        return imageView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}
