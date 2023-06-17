import SwiftUI


struct ASMediaItem: Identifiable {
    let id: UUID
    let title: String
    var photoURLs: [URL]?
    var videoURLs: [URL]?
    var audioURLs: [URL]?

    func bestWindowMinSize(forTargetSize size: NSSize = .zero) -> NSSize {
        let windowMinSize = NSSize(width: 480, height: 320)
        if let firstPhotoURL = photoURLs?.first, let firstPhoto = NSImage(contentsOf: firstPhotoURL) {
            let ratio = NSScreen.main?.backingScaleFactor ?? 1.0
            let normalWindow = NSWindow(contentRect: .init(origin: .zero, size: windowMinSize), styleMask: [.titled], backing: .buffered, defer: true)
            let titlebarHeight = normalWindow.titlebarHeight
            if ratio > 1.0 {
                if CGSizeEqualToSize(size, .zero) {
                    return NSSize(width: firstPhoto.size.width / ratio, height: firstPhoto.size.height / ratio - titlebarHeight)
                } else {
                    return NSSize(width: size.width / ratio, height: size.height / ratio - titlebarHeight)
                }
            } else {
                if CGSizeEqualToSize(size, .zero) {
                    return NSSize(width: firstPhoto.size.width, height: firstPhoto.size.height - titlebarHeight)
                } else {
                    return NSSize(width: size.width, height: size.height - titlebarHeight)
                }
            }
        }
        return windowMinSize
    }
}
