import SwiftUI
import AVKit


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentIndex: Int
    @State private var currentImage: NSImage?
    
    init(withItem item: ASMediaItem) {
        self.item = item
        _currentMinSize = State(initialValue: item.bestWindowMinSize())
        _currentIndex = State(initialValue: 0)
    }

    var body: some View {
        Group {
            if item.photoURLs == nil && item.audioURLs == nil && item.videoURLs == nil {
                ASMediaViewPlaceholderView()
            } else {
                containerView()
            }
        }
        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    private func containerView() -> some View {
        if let urls = item.photoURLs {
            photosView(urls: urls)
        } else if let urls = item.videoURLs {
            videosView(urls: urls)
        } else {
            ASMediaViewPlaceholderView()
        }
    }
    
    @ViewBuilder
    private func photosView(urls: [URL]) -> some View {
        ZStack {
            if let image = NSImage(contentsOfFile: urls[currentIndex].path) {
                if image.isGIFImage() {
                    ASMediaViewGIFAnimationView(image: image)
                        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
                } else {
                    ASMediaViewStaticView(image: currentImage)
                }
                if urls.count > 1 {
                    ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentPhotoIndex: $currentIndex)
                }
            } else {
                ASMediaViewPlaceholderView()
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            if let image = NSImage(contentsOfFile: urls[newValue].path) {
                currentImage = image
            } else {
                currentImage = nil
            }
        }
        .task {
            if let image = NSImage(contentsOfFile: urls[currentIndex].path) {
                currentImage = image
            }
        }
    }
    
    @ViewBuilder
    private func videosView(urls: [URL]) -> some View {
        ZStack {
            VideoPlayer(player: AVPlayer(url: urls[currentIndex]))
                .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
            if urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentPhotoIndex: $currentIndex)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            Task {
                do {
                    try await calculateBestVideoPlayerSize(forURL: urls[newValue])
                } catch {
                    debugPrint("failed to calculate best video size: \(error)")
                }
            }
        }
        .task {
            do {
                try await calculateBestVideoPlayerSize(forURL: urls[currentIndex])
            } catch {
                debugPrint("failed to calculate best video size: \(error)")
            }
        }
    }
    
    private func calculateBestVideoPlayerSize(forURL url: URL) async throws {
        guard let track = try await AVURLAsset(url: url).loadTracks(withMediaType: .video).first else { return }
        let size = try await track.load(.naturalSize).applying(track.load(.preferredTransform))
        let ratio = NSScreen.main?.backingScaleFactor ?? 1.0
        let videoSize = NSSize(width: size.width / ratio, height: size.height / ratio)
        let videoRatio = size.width / size.height
        guard let windowMaxSize = NSScreen.main?.frame.size else { return }
        let bestSize: NSSize
        if videoSize.width > windowMaxSize.width / 2.0 || videoSize.height > windowMaxSize.height / 2.0 {
            bestSize = NSSize(width: windowMaxSize.width / 2.0, height: windowMaxSize.width / 2.0 / videoRatio)
        } else {
            bestSize = videoSize
        }
        Task { @MainActor in
            self.currentMinSize = bestSize
        }
    }
}
