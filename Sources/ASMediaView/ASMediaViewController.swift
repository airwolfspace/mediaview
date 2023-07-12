import Cocoa
import SwiftUI


class ASMediaViewController: NSViewController {
    let mediaItem: ASMediaItem
    
    private var closeButton: NSButton?

    init(withMediaItem item: ASMediaItem) {
        self.mediaItem = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = NSHostingView(rootView: ASMediaView(withItem: mediaItem))
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let trackingArea = NSTrackingArea(rect: self.view.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil)
        contentView.addTrackingArea(trackingArea)
    }

    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .clear
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if let btn = self.view.window?.standardWindowButton(.miniaturizeButton) {
            btn.removeFromSuperview()
        }
        if let btn = self.view.window?.standardWindowButton(.zoomButton) {
            btn.removeFromSuperview()
        }
        if let btn = self.view.window?.standardWindowButton(.closeButton) {
            btn.removeFromSuperview()
        }
        if closeButton == nil {
            if let closeImage = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "Close Window") {
                let button = NSButton(image: closeImage, target: self, action: #selector(closeAction))
                button.frame = closeButtonFrame()
                button.image?.isTemplate = true
                button.imageScaling = .scaleProportionallyUpOrDown
                button.bezelStyle = .inline
                button.isBordered = false
                button.contentTintColor = NSColor.white
                button.isHidden = true
                self.view.addSubview(button)
                closeButton = button
            }
        } else {
            closeButton?.frame = closeButtonFrame()
        }
    }

    // MARK: -

    override func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(name: .mouseEntered(byID: self.mediaItem.id), object: nil)
        self.closeButton?.isHidden = false
    }
    
    override func mouseExited(with event: NSEvent) {
        NotificationCenter.default.post(name: .mouseExited(byID: self.mediaItem.id), object: nil)
        self.closeButton?.isHidden = true
    }
    
    // MARK: -
    
    private func closeButtonFrame() -> NSRect {
        let height = self.view.bounds.size.height
        var rect = NSRect.zero
        rect.size = CGSize(width: 30, height: 30)
        rect.origin = CGPoint(x: 12, y: height - 30 - 12)
        return rect
    }
    
    @objc private func closeAction() {
        self.view.window?.orderOut(nil)
    }
}
