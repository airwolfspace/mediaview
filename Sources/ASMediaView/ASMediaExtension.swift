import Cocoa
import ImageIO
import UniformTypeIdentifiers


extension NSWindow {
    var titlebarHeight: CGFloat {
        return self.frame.height - self.contentRect(forFrameRect: frame).height
    }
    
    func positionCenter() {
        if let screenSize = screen?.visibleFrame.size {
            self.setFrameOrigin(NSPoint(x: (screenSize.width - frame.size.width) / 2.0, y: (screenSize.height - frame.size.height) / 2.0))
        }
    }
}


extension NSSize {
    static let windowMinSize = NSSize(width: 180, height: 180)
}


extension URL {
    func isSupportedPhoto() -> Bool {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            return (
                type.conforms(to: .image) ||
                type.conforms(to: .rawImage)
            )
        }
        return false
    }
    
    func isSupportedVideo() -> Bool {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            return (
                type.conforms(to: .movie) ||
                type.conforms(to: .mpeg4Movie) ||
                type.conforms(to: .quickTimeMovie) ||
                type.conforms(to: .video) ||
                type.conforms(to: .mpeg2Video) ||
                type.conforms(to: .appleProtectedMPEG4Video)
            )
        }
        return false
    }
    
    func isSupportedAudio() -> Bool {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            return (
                type.conforms(to: .audio) ||
                type.conforms(to: .mpeg4Audio) ||
                type.conforms(to: .appleProtectedMPEG4Audio)
            )
        }
        return false
    }
}


extension NSImage {
    func isGIFImage() -> Bool {
        let reps = self.representations
        for rep in reps {
            if let bitmapRep = rep as? NSBitmapImageRep {
                let numFrame = bitmapRep.value(forProperty: NSBitmapImageRep.PropertyKey.frameCount) as? Int ?? 0
                return numFrame > 1
            }
        }
        return false
    }
}


extension Notification.Name {
    static func mouseEntered(byID id: UUID) -> Notification.Name {
        return Notification.Name("ASMediaViewMouseEnteredNotification" + "-" + id.uuidString)
    }
    static func mouseExited(byID id: UUID) -> Notification.Name {
        return Notification.Name("ASMediaViewMouseExitedNotification" + "-" + id.uuidString)
    }
    static func viewSizeChanged(byID id: UUID) -> Notification.Name {
        return Notification.Name("ASMediaViewSizeChangedNotification" + "-" + id.uuidString)
    }
    static func closed(byID id: UUID) -> Notification.Name {
        return Notification.Name("ASMediaViewClosedNotification" + "-" + id.uuidString)
    }
}
