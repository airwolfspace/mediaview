import SwiftUI


struct ASMediaItem: Identifiable {
    let id: UUID
    let title: String
    var photoURLs: [URL]?
    var videoURLs: [URL]?
    var audioURLs: [URL]?
    
    func bestWindowMinSize() -> NSSize {
        let windowMinSize = NSSize(width: 480, height: 320)
        if let firstPhotoURL = photoURLs?.first, let firstPhoto = NSImage(contentsOf: firstPhotoURL) {
            let ratio = NSScreen.main?.backingScaleFactor ?? 1.0
            if ratio > 1.0 {
                return NSSize(width: firstPhoto.size.width / ratio, height: firstPhoto.size.height / ratio)
            } else {
                return firstPhoto.size
            }
        }
        return windowMinSize
    }
}
