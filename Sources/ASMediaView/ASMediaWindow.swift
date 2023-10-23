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
        self.contentAspectRatio = .windowMinSize
        self.aspectRatio = .windowMinSize
        NotificationCenter.default.addObserver(forName: .viewSizeChanged(byID: item.id), object: nil, queue: nil) { [weak self] n in
            guard let value = n.object as? NSValue else { return }
            debugPrint("about to resize window to size: \(value)")
            var finalSize = value.sizeValue
            if finalSize.width < NSSize.windowMinSize.width {
                finalSize.width = NSSize.windowMinSize.width
            }
            if finalSize.height < NSSize.windowMinSize.height {
                finalSize.height = NSSize.windowMinSize.height
            }
            let selfFrame = self?.frame ?? .zero
            let updatedFrame = NSRect(origin: selfFrame.origin, size: finalSize)
            DispatchQueue.main.async {
                self?.setFrame(updatedFrame, display: true, animate: true)
                self?.contentAspectRatio = finalSize
                self?.aspectRatio = finalSize
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
