import SwiftUI
import AVKit


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentIndex: Int
    @State private var currentImage: NSImage?
    
    init(withItem item: ASMediaItem) {
        self.item = item
        _currentIndex = State(initialValue: 0)
        if item.photoURLs != nil {
            _currentMinSize = State(wrappedValue: self.item.calculatePhotoViewSize(forURLIndex: 0))
        } else {
            _currentMinSize = State(wrappedValue: item.windowMinSize)
        }
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
        ZStack {
            Color.secondary.opacity(0.25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let urls = item.photoURLs {
                photosView(urls: urls)
            } else if let urls = item.videoURLs {
                videosView(urls: urls)
            } else {
                ASMediaViewPlaceholderView()
            }
        }
        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
    }
    
    @ViewBuilder
    private func photosView(urls: [URL]) -> some View {
        ZStack {
            let targetURL = urls[currentIndex]
            if targetURL.isSupportedPhoto(), let image = NSImage(contentsOfFile: targetURL.path) {
                if image.isGIFImage() {
                    ASMediaViewGIFAnimationView(image: image)
                        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
                } else {
                    ASMediaViewStaticView(image: currentImage)
                }
            } else {
                ASMediaViewUnsupportedView(fileURL: targetURL)
            }
            if urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
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
            let targetURL = urls[currentIndex]
            if targetURL.isSupportedVideo() {
                VideoPlayer(player: AVPlayer(url: urls[currentIndex]))
                    .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
            } else {
                ASMediaViewUnsupportedView(fileURL: targetURL)
            }
            if urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            Task {
                do {
                    let videoItemSize = try await self.item.calculateVideoPlayerSize(forURLIndex: self.currentIndex)
                    await MainActor.run {
                        self.currentMinSize = videoItemSize
                    }
                } catch {
                    debugPrint("failed to calculate best video size: \(error)")
                }
            }
        }
        .task {
            do {
                let videoItemSize = try await self.item.calculateVideoPlayerSize(forURLIndex: self.currentIndex)
                await MainActor.run {
                    self.currentMinSize = videoItemSize
                }
            } catch {
                debugPrint("failed to calculate best video size: \(error)")
            }
        }
    }
    
}
