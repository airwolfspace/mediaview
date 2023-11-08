import SwiftUI
import AVKit


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize {
        didSet {
            let value = NSValue(size: currentMinSize)
            NotificationCenter.default.post(name: .viewSizeChanged(byID: self.item.id), object: value)
        }
    }
    @State private var currentIndex: Int
    @State private var currentImage: NSImage?
    @State private var currentPlayer: AVPlayer?
    @State private var viewOpacity: CGFloat = 1.0

    init(withItem item: ASMediaItem) {
        self.item = item
        _currentIndex = State(initialValue: 0)
        _currentMinSize = State(wrappedValue: .windowMinSize)
    }

    var body: some View {
        Group {
            if item.photoURLs == nil && item.audioURLs == nil && item.videoURLs == nil {
                ASMediaViewPlaceholderView()
            } else {
                containerView()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder
    private func mixedContainerView() -> some View {
        ZStack {
            Color.secondary
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let url = item.mixedURLs?[currentIndex] {
                if url.isSupportedPhoto() {
                    photosView(urls: [url])
                        .opacity(viewOpacity)
                } else if url.isSupportedVideo() {
                    videosView(urls: [url])
                } else if url.isSupportedAudio() {
                    audiosView(urls: [url])
                } else {
                    ASMediaViewUnsupportedView(fileURL: url)
                }
            } else {
                ASMediaViewPlaceholderView()
            }
        }
        .frame(idealWidth: currentMinSize.width, idealHeight: currentMinSize.height)
    }

    @ViewBuilder
    private func containerView() -> some View {
        ZStack {
            Color.secondary
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let urls = item.photoURLs {
                photosView(urls: urls)
                    .opacity(viewOpacity)
            } else if let urls = item.videoURLs {
                videosView(urls: urls)
            } else if let urls = item.audioURLs {
                audiosView(urls: urls)
            } else {
                ASMediaViewPlaceholderView()
            }
        }
        .frame(idealWidth: currentMinSize.width, idealHeight: currentMinSize.height)
    }
    
    @ViewBuilder
    private func audiosView(urls: [URL]) -> some View {
        ZStack {
            let targetURL = urls[currentIndex]
            if targetURL.isSupportedAudio() {
                VideoPlayer(player: AVPlayer(url: urls[currentIndex]))
            } else {
                ASMediaViewUnsupportedView(fileURL: targetURL)
            }
            if urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            currentPlayer?.pause()
            currentPlayer = AVPlayer(url: urls[newValue])
            Task {
                let size = self.item.calculateAudioViewSize(forURLIndex: self.currentIndex)
                await MainActor.run {
                    self.currentMinSize = size
                }
            }
        }
        .task {
            currentPlayer = AVPlayer(url: urls[currentIndex])
        }
    }

    @ViewBuilder
    private func photosView(urls: [URL]) -> some View {
        ZStack {
            let targetURL = urls[currentIndex]
            if targetURL.isSupportedPhoto(), let image = NSImage(contentsOfFile: targetURL.path) {
                if image.isGIFImage() {
                    ASMediaViewGIFAnimationView(imageURL: targetURL)
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
            let offset: UInt64 = 25000000
            withAnimation(.linear(duration: 0.125)) {
                viewOpacity = 0.5
                Task {
                    try? await Task.sleep(nanoseconds: offset)
                    withAnimation(.linear(duration: 0.125)) {
                        viewOpacity = 1.0
                    }
                }
            }
            if let image = NSImage(contentsOfFile: urls[newValue].path) {
                currentImage = image
            } else {
                currentImage = nil
            }
            Task {
                try? await Task.sleep(nanoseconds: offset)
                let size = self.item.calculatePhotoViewSize(forURLIndex: self.currentIndex)
                await MainActor.run {
                    self.currentMinSize = size
                }
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
            if targetURL.isSupportedVideo(), let currentPlayer {
                VideoPlayer(player: currentPlayer)
            } else {
                ASMediaViewUnsupportedView(fileURL: targetURL)
            }
            if urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            currentPlayer?.pause()
            currentPlayer = AVPlayer(url: urls[newValue])
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
            currentPlayer = AVPlayer(url: urls[currentIndex])
        }
    }
}
