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

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.positionCenter()
    }
    
    func windowID() -> UUID {
        return mediaItem.id
    }
}
