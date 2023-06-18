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
            let normalWindow = NSWindow(contentRect: .init(origin: .zero, size: windowMinSize), styleMask: [.titled], backing: .buffered, defer: true)
            let titlebarHeight = normalWindow.titlebarHeight
            if CGSizeEqualToSize(size, .zero) {
                return NSSize(width: firstPhoto.size.width, height: firstPhoto.size.height - titlebarHeight)
            } else {
                return NSSize(width: size.width, height: size.height - titlebarHeight)
            }
        }
        return windowMinSize
    }
}
