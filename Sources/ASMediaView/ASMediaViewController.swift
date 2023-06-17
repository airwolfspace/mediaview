import Cocoa
import SwiftUI


class ASMediaViewController: NSViewController {
    let mediaItem: ASMediaItem

    init(withMediaItem item: ASMediaItem) {
        self.mediaItem = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = NSHostingView(rootView: ASMediaView(item: mediaItem))
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
    
    override func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(name: .mouseEntered, object: nil)
    }
    
    override func mouseExited(with event: NSEvent) {
        NotificationCenter.default.post(name: .mouseExited, object: nil)
    }
}
