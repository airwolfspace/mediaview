import Cocoa


class ASMediaWindow: NSWindow {
    var mediaItemID: UUID
    
    init(withMediaItem item: ASMediaItem, contentRect: NSRect) {
        self.mediaItemID = item.id
        super.init(contentRect: contentRect, styleMask: [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView], backing: .buffered, defer: true)
        self.title = item.title
        if item.title == "" {
            self.title = item.id.uuidString
        }
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = .fullScreenNone
        self.contentViewController = ASMediaViewController(withMediaItem: item)
        self.delegate = self
        NotificationCenter.default.addObserver(forName: .viewSizeChanged(byID: item.id), object: nil, queue: nil) { [weak self] n in
            guard let value = n.object as? NSValue else { return }
            let selfFrame = self?.frame ?? .zero
            let deltaWidth = selfFrame.size.width - value.sizeValue.width
            let deltaHeight = selfFrame.size.height - value.sizeValue.height
            let updatedOrigin: NSPoint
            if deltaWidth > 0 {
                if deltaHeight > 0 {
                    updatedOrigin = NSPoint(x: selfFrame.origin.x, y: selfFrame.origin.y + deltaHeight)
                } else {
                    updatedOrigin = NSPoint(x: selfFrame.origin.x, y: selfFrame.origin.y - deltaHeight)
                }
            } else {
                if deltaHeight > 0 {
                    updatedOrigin = NSPoint(x: selfFrame.origin.x, y: selfFrame.origin.y + deltaHeight)
                } else {
                    updatedOrigin = NSPoint(x: selfFrame.origin.x, y: selfFrame.origin.y - deltaHeight)
                }
            }
            let updatedFrame = NSRect(origin: updatedOrigin, size: value.sizeValue)
            DispatchQueue.main.async {
                self?.setFrame(updatedFrame, display: true, animate: true)
            }
        }
        NotificationCenter.default.addObserver(forName: .closed(byID: item.id), object: nil, queue: .main) { _ in
            ASMediaManager.shared.deactivateView(byID: item.id)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension ASMediaWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        ASMediaManager.shared.deactivateView(byID: self.mediaItemID)
        return true
    }
}
