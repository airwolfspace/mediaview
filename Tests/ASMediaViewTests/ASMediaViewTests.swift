import XCTest
@testable import ASMediaView


final class ASMediaViewTests: XCTestCase {
    static let testMediaItemID: UUID = UUID()
    static let testMediaItemPhotosTitle: String = "Test Media Photos"
    static let testMediaItemPhotos: [URL] = []
    static let mediaViewMinSize: NSSize = NSSize(width: 480, height: 320)
    
    func makeTestMediaItemPhotos() -> ASMediaItem {
        let item = ASMediaItem(id: Self.testMediaItemID, title: Self.testMediaItemPhotosTitle, photoURLs: Self.testMediaItemPhotos)
        return item
    }

    func testMediaViewPhotos() throws {
        let mediaItem = makeTestMediaItemPhotos()
        let mediaWindowController = ASMediaWindowController(withMediaItem: mediaItem)
        mediaWindowController.showWindow(nil)
        let window = mediaWindowController.window
        XCTAssertNil(window)
        XCTAssertEqual(mediaWindowController.windowID(), mediaItem.id)
        XCTAssertEqual(window?.title, mediaItem.title)
        XCTAssertEqual(window?.minSize, Self.mediaViewMinSize)
    }
    
    func testMediaViewActivationAndDeactivation() async throws {
        await ASMediaManager.shared.activatePhotoView(withPhotos: Self.testMediaItemPhotos, title: Self.testMediaItemPhotosTitle, andID: Self.testMediaItemID)
        let openWindow = await ASMediaManager.shared.windowControllers.first?.window
        XCTAssertNotNil(openWindow)
        await ASMediaManager.shared.deactivateView(byID: Self.testMediaItemID)
        let closeWindow = await ASMediaManager.shared.windowControllers.first?.window
        XCTAssertNil(closeWindow)
    }
    
    func testMediaViewVideos() throws {
    }
    
    func testMediaViewAudios() throws {
    }
}
