import Cocoa


extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentRect(forFrameRect: frame).height
    }
}
