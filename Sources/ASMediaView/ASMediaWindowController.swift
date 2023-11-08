import Cocoa


class ASMediaWindowController: NSWindowController {
    var mediaItem: ASMediaItem

    init(withMediaItem item: ASMediaItem, andDefaultSize size: NSSize = CGSizeZero) {
        self.mediaItem = item
        let windowMaxSize = NSScreen.main?.frame.size ?? .windowMinSize
        let targetSize: CGSize
        if CGSizeEqualToSize(size, .zero) {
            if let urls = item.mixedURLs, let url = urls.first {
                if url.isSupportedPhoto() {
                    targetSize = item.calculatePhotoViewSize(forURL: url)
                } else if url.isSupportedAudio() {
                    targetSize = item.calculateAudioViewSize(forURL: url)
                } else {
                    targetSize = .windowMinSize
                }
            } else {
                if item.photoURLs != nil {
                    targetSize = item.calculatePhotoViewSize(forURLIndex: 0)
                } else if item.audioURLs != nil {
                    targetSize = item.calculateAudioViewSize(forURLIndex: 0)
                } else {
                    targetSize = .windowMinSize
                }
            }
        } else {
            targetSize = size
        }
        let targetRatio = targetSize.width / targetSize.height
        var targetWidth: CGFloat
        var shouldAdjustSizeByTargetRatio: Bool = false
        if targetSize.width >= windowMaxSize.width {
            targetWidth = windowMaxSize.width
            shouldAdjustSizeByTargetRatio = true
        } else {
            targetWidth = targetSize.width
        }
        var targetHeight: CGFloat
        if targetSize.height >= windowMaxSize.height {
            targetHeight = windowMaxSize.height * 0.5
            shouldAdjustSizeByTargetRatio = true
        } else {
            targetHeight = targetSize.height
        }
        if shouldAdjustSizeByTargetRatio {
            if targetWidth > targetHeight {
                targetHeight = targetHeight / targetRatio
            } else {
                targetWidth = targetHeight * targetRatio
            }
            let currentRatio = targetWidth / targetHeight
            if currentRatio != targetRatio {
                if currentRatio > targetRatio {
                    targetWidth = targetHeight * targetRatio
                } else {
                    targetHeight = targetWidth / targetRatio
                }
            }
        }
        let finalSize = NSSize(width: targetWidth, height: targetHeight)
        let windowRect: NSRect = NSRect(origin: .zero, size: finalSize)
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
        self.window?.setFrameAutosaveName(mediaItem.id.uuidString)
    }
    
    func windowID() -> UUID {
        return mediaItem.id
    }
}
