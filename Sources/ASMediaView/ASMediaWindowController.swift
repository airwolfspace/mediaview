import Cocoa


class ASMediaWindowController: NSWindowController {
    let mediaItem: ASMediaItem

    init(withMediaItem item: ASMediaItem) {
        self.mediaItem = item
        let windowMinSize = item.bestWindowMinSize()
        let windowMaxSize = NSScreen.main?.frame.size ?? windowMinSize
        let windowRect = NSMakeRect(0, 0, windowMinSize.width, windowMinSize.height)
        let aWindow = ASMediaWindow(withMediaItem: item, contentRect: windowRect)
        aWindow.minSize = windowMinSize
        aWindow.maxSize = windowMaxSize
        super.init(window: aWindow)
        self.window?.center()
        self.window?.setFrameAutosaveName(item.id.uuidString)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func windowID() -> UUID {
        return mediaItem.id
    }
}
