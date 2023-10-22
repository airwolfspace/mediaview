import Cocoa


class ASMediaWindowController: NSWindowController {
    var mediaItem: ASMediaItem

    init(withMediaItem item: ASMediaItem) {
        self.mediaItem = item
        let windowMaxSize = NSScreen.main?.frame.size ?? .windowMinSize
        let windowRect = NSRect.zero
        let aWindow = ASMediaWindow(withMediaItem: item, contentRect: windowRect)
        aWindow.maxSize = windowMaxSize
        aWindow.minSize = .windowMinSize
        super.init(window: aWindow)
        self.window?.setFrameAutosaveName(item.id.uuidString)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        self.window?.contentViewController = nil
        self.window?.windowController = nil
        self.window = nil
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.positionCenter()
    }
    
    func windowID() -> UUID {
        return mediaItem.id
    }
}
