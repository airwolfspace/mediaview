import SwiftUI
import AVKit


struct ASMediaItem: Identifiable {
    let id: UUID
    let title: String
    var photoURLs: [URL]?
    var videoURLs: [URL]?
    var audioURLs: [URL]?
    
    init(id: UUID, title: String, photoURLs: [URL]? = nil, videoURLs: [URL]? = nil, audioURLs: [URL]? = nil) {
        self.id = id
        self.title = title
        self.photoURLs = photoURLs
        self.videoURLs = videoURLs
        self.audioURLs = audioURLs
    }
    
    func calculateAudioViewSize(forURLIndex index: Int) -> NSSize {
        return NSSize(width: 480, height: 320)
    }
    
    func calculatePhotoViewSize(forURLIndex index: Int) -> NSSize {
        guard let urls = self.photoURLs, urls.count > 0, urls.count > index, let photo = NSImage(contentsOfFile: urls[index].path) else { return .windowMinSize }
        let screenSize = NSScreen.main?.frame.size ?? .windowMinSize
        let photoRatio = photo.size.width / photo.size.height
        let photoIsLandscape: Bool = photo.size.width > photo.size.height
        if !CGSizeEqualToSize(screenSize, .windowMinSize) {
            if photoIsLandscape {
                if photo.size.width <= screenSize.width / 2.0 {
                    return NSSize(width: photo.size.width, height: photo.size.height)
                } else {
                    return NSSize(width: screenSize.width / 2.0, height: screenSize.width / 2.0 / photoRatio)
                }
            } else {
                if photo.size.height <= screenSize.height / 2.0 {
                    return NSSize(width: photo.size.width, height: photo.size.height)
                } else {
                    return NSSize(width: screenSize.height / 2.0 * photoRatio, height: screenSize.height / 2.0)
                }
            }
        }
        return .windowMinSize
    }
    
    func calculateVideoPlayerSize(forURLIndex index: Int) async throws -> NSSize {
        guard let urls = self.videoURLs, urls.count > 0, urls.count > index else { return .windowMinSize }
        let url = urls[index]
        guard let track = try await AVURLAsset(url: url).loadTracks(withMediaType: .video).first else { return .windowMinSize }
        let size = try await track.load(.naturalSize).applying(track.load(.preferredTransform))
        let ratio = NSScreen.main?.backingScaleFactor ?? 1.0
        let videoSize = NSSize(width: abs(size.width / ratio), height: abs(size.height / ratio))
        let videoRatio = abs(size.width / size.height)
        guard let windowMaxSize = NSScreen.main?.frame.size else { return .windowMinSize }
        let bestSize: NSSize
        if videoRatio > 1.0 {
            if videoSize.width > windowMaxSize.width / 2.0 {
                bestSize = NSSize(width: windowMaxSize.width / 2.0, height: windowMaxSize.width / 2.0 / videoRatio)
            } else {
                bestSize = videoSize
            }
        } else {
            if videoSize.height > windowMaxSize.height / 2.0 {
                bestSize = NSSize(width: windowMaxSize.height / 2.0 * videoRatio, height: windowMaxSize.height / 2.0)
            } else {
                bestSize = videoSize
            }
        }
        return NSSize(width: bestSize.width, height: bestSize.height)
    }
    
    func getVideoThumbnail(forURLIndex index: Int) -> NSImage? {
        guard let urls = self.videoURLs, urls.count > 0, urls.count > index else { return nil }
        let url = urls[index]
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        if let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) {
            return NSImage(cgImage: cgImage, size: .zero)
        }
        return nil
    }
}
