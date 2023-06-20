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
