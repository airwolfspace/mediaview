import SwiftUI


struct ASMediaItem: Identifiable {
    let id: UUID
    let title: String
    var photoURLs: [URL]?
    var videoURLs: [URL]?
    var audioURLs: [URL]?

    func bestWindowMinSize(forTargetSize targetSize: NSSize = .zero) -> NSSize {
        let windowMinSize = NSSize(width: 480, height: 320)
        if let firstPhotoURL = photoURLs?.first, let firstPhoto = NSImage(contentsOf: firstPhotoURL) {
            let normalWindow = NSWindow(contentRect: .init(origin: .zero, size: windowMinSize), styleMask: [.titled], backing: .buffered, defer: true)
            let titlebarHeight = normalWindow.titlebarHeight
            if CGSizeEqualToSize(targetSize, .zero) {
                let screenSize = NSScreen.main?.frame.size ?? windowMinSize
                let photoRatio = firstPhoto.size.width / firstPhoto.size.height
                let photoIsLandscape: Bool = firstPhoto.size.width > firstPhoto.size.height
                if !CGSizeEqualToSize(screenSize, windowMinSize) {
                    if photoIsLandscape {
                        if firstPhoto.size.width <= screenSize.width / 2.0 {
                            return NSSize(width: firstPhoto.size.width, height: firstPhoto.size.height - titlebarHeight)
                        } else {
                            return NSSize(width: screenSize.width / 2.0, height: screenSize.width / 2.0 / photoRatio - titlebarHeight)
                        }
                    } else {
                        if firstPhoto.size.height <= screenSize.height / 2.0 {
                            return NSSize(width: firstPhoto.size.width, height: firstPhoto.size.height - titlebarHeight)
                        } else {
                            return NSSize(width: screenSize.height / 2.0 * photoRatio, height: screenSize.height / 2.0 - titlebarHeight)
                        }
                    }
                }
            } else {
                return NSSize(width: targetSize.width, height: targetSize.height - titlebarHeight)
            }
        }
        return windowMinSize
    }
}
