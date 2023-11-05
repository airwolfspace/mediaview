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
        self.contentAspectRatio = contentRect.size
        self.aspectRatio = contentRect.size
        self.setFrame(contentRect, display: false, animate: false)
        var finalSize = contentRect.size
        if finalSize.width < NSSize.windowMinSize.width {
            finalSize.width = NSSize.windowMinSize.width
        }
        if finalSize.height < NSSize.windowMinSize.height {
            finalSize.height = NSSize.windowMinSize.height
        }
        let minRatio = 0.4
        self.minSize = CGSize(width: max(finalSize.width * minRatio, NSSize.windowMinSize.width), height: max(finalSize.height * minRatio, NSSize.windowMinSize.height))
        let topOffset: CGFloat
        if let top =  self.contentView?.safeAreaInsets.top, top > 0 {
            let sampleWindow = NSWindow(contentRect: .init(x: 0, y: 0, width: 1, height: 1), styleMask: .titled, backing: .buffered, defer: true)
            topOffset = sampleWindow.titlebarHeight
        } else {
            topOffset = 0
        }
        self.contentView?.additionalSafeAreaInsets = .init(top: -topOffset, left: 0, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(forName: .viewSizeChanged(byID: item.id), object: nil, queue: nil) { [weak self] n in
            guard let value = n.object as? NSValue else { return }
            var finalSize = value.sizeValue
            if finalSize.width < NSSize.windowMinSize.width {
                finalSize.width = NSSize.windowMinSize.width
            }
            if finalSize.height < NSSize.windowMinSize.height {
                finalSize.height = NSSize.windowMinSize.height
            }
            guard let selfFrame = self?.frame else { return }
            guard let updatedFrame = self?.calculateCenteredFrame(fromFrame: selfFrame, andSize: finalSize) else { return }
            DispatchQueue.main.async {
                self?.contentAspectRatio = finalSize
                self?.aspectRatio = finalSize
                self?.minSize = CGSize(width: max(finalSize.width * minRatio, NSSize.windowMinSize.width), height: max(finalSize.height * minRatio, NSSize.windowMinSize.height))
                self?.setFrame(updatedFrame, display: true, animate: true)
            }
        }
        NotificationCenter.default.addObserver(forName: .closed(byID: item.id), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                ASMediaManager.shared.deactivateView(byID: item.id)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func calculateCenteredFrame(fromFrame frame: NSRect, andSize size: NSSize) -> NSRect {
        let x = frame.origin.x + (frame.size.width - size.width) / 2
        let y = frame.origin.y + (frame.size.height - size.height) / 2
        return NSRect(origin: .init(x: x, y: y), size: size)
    }
}


extension ASMediaWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        ASMediaManager.shared.deactivateView(byID: self.mediaItemID)
        return true
    }
}
