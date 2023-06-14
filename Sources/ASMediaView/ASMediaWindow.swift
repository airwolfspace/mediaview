import Cocoa


class ASMediaWindow: NSWindow {
    init(withMediaItem item: ASMediaItem, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.title = item.title
        self.setFrameAutosaveName(title + "-" + item.id.uuidString)
        self.delegate = self
    }
}


extension ASMediaWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
