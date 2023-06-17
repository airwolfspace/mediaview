import Cocoa


extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentRect(forFrameRect: frame).height
    }
}


extension Notification.Name {
    static let mouseEntered = Notification.Name("ASMediaViewMouseEnteredNotification")
    static let mouseExited = Notification.Name("ASMediaViewMouseExitedNotification")
    
    static func viewSizeChanged(byID id: UUID) -> Notification.Name {
        return Notification.Name("ASMediaViewSizeChangedNotification" + "-" + id.uuidString)
    }
}
