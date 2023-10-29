import Cocoa


class ASMediaWindowController: NSWindowController {
    var mediaItem: ASMediaItem

    init(withMediaItem item: ASMediaItem, andDefaultSize size: NSSize = CGSizeZero) {
        self.mediaItem = item
        let windowMaxSize = NSScreen.main?.frame.size ?? .windowMinSize
        let targetSize: CGSize
        if CGSizeEqualToSize(size, .zero) {
            if item.photoURLs != nil {
                targetSize = item.calculatePhotoViewSize(forURLIndex: 0)
            } else if item.audioURLs != nil {
                targetSize = item.calculateAudioViewSize(forURLIndex: 0)
            } else {
                targetSize = .windowMinSize
            }
        } else {
            targetSize = size
        }
        let targetWidth: CGFloat
        if targetSize.width >= windowMaxSize.width {
            targetWidth = windowMaxSize.width
        } else {
            targetWidth = targetSize.width
        }
        let targetHeight: CGFloat
        if targetSize.height >= windowMaxSize.height {
            targetHeight = windowMaxSize.height
        } else {
            targetHeight = targetSize.height
        }
        let windowRect: NSRect = NSRect(origin: .zero, size: CGSize(width: targetWidth, height: targetHeight))
        let aWindow = ASMediaWindow(withMediaItem: item, contentRect: windowRect)
        super.init(window: aWindow)
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
