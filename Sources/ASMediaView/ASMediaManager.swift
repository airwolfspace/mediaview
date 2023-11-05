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
        if let window = controller.window, window.frame.origin.x == 0 {
            window.positionCenter()
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
}
