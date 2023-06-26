import Cocoa


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


extension NSImage {
    var isGIF: Bool {
        let data = self.tiffRepresentation ?? Data()
        if data.count > 3 {
            let bytes = [UInt8](data)
            let result = (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46)
            debugPrint("GIF result: \(result), image: \(self)")
            return true
            return result
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
}
