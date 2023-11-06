import Cocoa


public class ASMediaManager: NSObject {
    public static let shared = ASMediaManager()
    
    private(set) var windowControllers: [ASMediaWindowController] = []
    
    @MainActor
    public func activatePhotoView(withPhotos photoURLs: [URL], title: String, id: UUID, defaultSize: NSSize = .zero) {
        if let controller = windowControllers.first(where: { $0.windowID() == id }) {
            controller.window?.makeKeyAndOrderFront(nil)
        } else {
            addWindowController(withPhotoURLs: photoURLs, videoURLs: nil, audioURLs: nil, title: title, id: id, defaultSize: defaultSize)
        }
    }
    
    @MainActor
    public func activateVideoView(withVideos videoURLs: [URL], title: String, id: UUID, defaultSize: NSSize = .zero) {
        if let controller = windowControllers.first(where: { $0.windowID() == id }) {
            controller.window?.makeKeyAndOrderFront(nil)
        } else {
            addWindowController(withPhotoURLs: nil, videoURLs: videoURLs, audioURLs: nil, title: title, id: id, defaultSize: defaultSize)
        }
    }
    
    @MainActor
    public func activateAudioView(withAudios audioURLs: [URL], title: String, id: UUID, defaultSize: NSSize = .zero) {
        if let controller = windowControllers.first(where: { $0.windowID() == id }) {
            controller.window?.makeKeyAndOrderFront(nil)
        } else {
            addWindowController(withPhotoURLs: nil, videoURLs: nil, audioURLs: audioURLs, title: title, id: id, defaultSize: defaultSize)
        }
    }

    @MainActor
    public func deactivateView(byID id: UUID) {
        guard windowControllers.first(where: { $0.windowID() == id }) != nil else { return }
        destroyWindowController(byID: id)
    }
    
    @MainActor
    public func deactivateAll() {
        windowControllers = windowControllers.filter({ controller in
            controller.contentViewController = nil
            controller.window?.close()
            controller.window = nil
            return false
        })
    }
    
    public func imageIsGIF(image: NSImage) -> Bool {
        return image.isGIFImage()
    }

    // MARK: - private

    private func addWindowController(withPhotoURLs photoURLs: [URL]?, videoURLs: [URL]?, audioURLs: [URL]?, title: String, id: UUID, defaultSize: NSSize) {
        guard windowControllers.first(where: { $0.windowID() == id }) == nil else { return }
        let mediaItem = ASMediaItem(id: id, title: title, photoURLs: photoURLs, videoURLs: videoURLs, audioURLs: audioURLs)
        let controller = ASMediaWindowController(withMediaItem: mediaItem, andDefaultSize: defaultSize)
        windowControllers.append(controller)
        controller.showWindow(nil)
        if let w = controller.window {
            adjustInitialPosition(forWindow: w)
        }
    }
    
    private func destroyWindowController(byID id: UUID) {
        windowControllers = windowControllers.filter({ controller in
            if controller.windowID() == id {
                controller.close()
                return false
            }
            return true
        })
    }

    private func adjustInitialPosition(forWindow w: NSWindow) {
        if dockIsHidden() {
            if w.frame.origin == .zero {
                w.positionCenter()
            }
        } else {
            let position = currentDockPosition()
            if position == .bottom {
                if w.frame.origin.x == 0 && w.frame.origin.y == currentDockHeight() {
                    w.positionCenter()
                }
            } else if position == .left {
                if w.frame.origin.y == 0 && w.frame.origin.x == currentDockHeight() {
                    w.positionCenter()
                }
            } else if position == .right {
                if w.frame.origin == .zero {
                    w.positionCenter()
                }
            }
        }
    }

    private func currentDockPosition() -> DockPosition {
        guard let screen = NSScreen.main else {
            return .bottom
        }
        if screen.visibleFrame.origin.y == 0 {
            if screen.visibleFrame.origin.x == 0 {
                return .right
            } else {
                return .left
            }
        } else {
            return .bottom
        }
    }

    private func currentDockHeight() -> CGFloat {
        guard let screen = NSScreen.main else {
            return 0
        }
        switch currentDockPosition() {
        case .bottom:
            return screen.visibleFrame.origin.y
        case .left:
            return screen.visibleFrame.origin.x
        case .right:
            return screen.frame.width - screen.visibleFrame.width
        }
    }

    private func dockIsHidden() -> Bool {
        return currentDockHeight() < 25
    }
}


private enum DockPosition: Int {
    case left = 0
    case right = 1
    case bottom = 2
}
