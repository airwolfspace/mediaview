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
            if item.mixedURLs != nil {
                mixedContainerView()
            } else if item.photoURLs == nil && item.audioURLs == nil && item.videoURLs == nil {
                ASMediaViewPlaceholderView()
            } else {
                containerView()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    // MARK: -

    @ViewBuilder
    private func mixedContainerView() -> some View {
        ZStack {
            Color.secondary
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let url = item.mixedURLs?[currentIndex] {
                if url.isSupportedPhoto() {
                    photoView(url: url)
                } else if url.isSupportedVideo() {
                    videoView(url: url)
                } else if url.isSupportedAudio() {
                    audioView(url: url)
                } else {
                    ASMediaViewUnsupportedView(fileURL: url)
                    ASMediaViewControlCloseView(id: item.id)
                }
            } else {
                ASMediaViewPlaceholderView()
            }
            if let urls = item.mixedURLs, urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
                pageControl(urls: urls)
            }
        }
        .opacity(viewOpacity)
        .frame(idealWidth: currentMinSize.width, idealHeight: currentMinSize.height)
        .onChange(of: currentIndex) { [currentIndex] newValue in
            guard let previousURL = item.mixedURLs?[currentIndex], let currentURL = item.mixedURLs?[newValue] else { return }

            let wasPhoto = previousURL.isSupportedPhoto()
            let wasVideo = previousURL.isSupportedVideo()
            let wasAudio = previousURL.isSupportedAudio()

            let isPhoto = currentURL.isSupportedPhoto()
            let isVideo = currentURL.isSupportedVideo()
            let isAudio = currentURL.isSupportedAudio()

            let offset: UInt64 = 25000000

            if wasPhoto && isPhoto {
                withAnimation(.linear(duration: 0.125)) {
                    viewOpacity = 0.5
                    Task {
                        try? await Task.sleep(nanoseconds: offset)
                        withAnimation(.linear(duration: 0.125)) {
                            viewOpacity = 1.0
                        }
                    }
                }
            }

            if wasPhoto && !isPhoto {
                currentImage = nil
            }
            if isPhoto {
                currentImage = NSImage(contentsOfFile: currentURL.path)
            }

            if wasVideo {
                currentPlayer?.pause()
            }
            if isVideo {
                currentPlayer?.pause()
                currentPlayer = AVPlayer(url: currentURL)
            }

            if wasAudio {
                currentPlayer?.pause()
            }
            if isAudio {
                currentPlayer?.pause()
                currentPlayer = AVPlayer(url: currentURL)
            }

            Task(priority: .userInitiated) {
                if wasPhoto && isPhoto {
                    try? await Task.sleep(nanoseconds: offset)
                }

                if isPhoto {
                    let size: NSSize = self.item.calculatePhotoViewSize(forURL: currentURL)
                    await MainActor.run {
                        self.currentMinSize = size
                    }
                }

                if isVideo {
                    do {
                        let size: NSSize = try await self.item.calculateVideoPlayerSize(forURL: currentURL)
                        await MainActor.run {
                            self.currentMinSize = size
                        }
                    } catch {
                        debugPrint("failed to calculate best video size: \(error)")
                    }
                }

                if isAudio {
                    let size: NSSize = self.item.calculateAudioViewSize(forURL: currentURL)
                    await MainActor.run {
                        self.currentMinSize = size
                    }
                }
            }
        }
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
            if item.mixedURLs == nil, urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
                pageControl(urls: urls)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            currentPlayer?.pause()
            if let url = self.item.mixedURLs?[newValue] {
                currentPlayer = AVPlayer(url: url)
            } else {
                currentPlayer = AVPlayer(url: urls[newValue])
            }
            Task {
                let size: NSSize
                if let url = self.item.mixedURLs?[self.currentIndex] {
                    size = self.item.calculateAudioViewSize(forURL: url)
                } else {
                    size = self.item.calculateAudioViewSize(forURLIndex: self.currentIndex)
                }
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
    private func audioView(url: URL) -> some View {
        ZStack {
            if url.isSupportedAudio() {
                VideoPlayer(player: AVPlayer(url: url))
            } else {
                ASMediaViewUnsupportedView(fileURL: url)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .task {
            currentPlayer = AVPlayer(url: url)
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
            if item.mixedURLs == nil, urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
                pageControl(urls: urls)
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
                let size: NSSize
                if let url = self.item.mixedURLs?[self.currentIndex] {
                    size = self.item.calculatePhotoViewSize(forURL: url)
                } else {
                    size = self.item.calculatePhotoViewSize(forURLIndex: self.currentIndex)
                }
                await MainActor.run {
                    self.currentMinSize = size
                }
            }
        }
        .task {
            currentImage = NSImage(contentsOfFile: urls[currentIndex].path)
        }
    }

    @ViewBuilder
    private func photoView(url: URL) -> some View {
        ZStack {
            if url.isSupportedPhoto(), let image = NSImage(contentsOfFile: url.path) {
                if image.isGIFImage() {
                    ASMediaViewGIFAnimationView(imageURL: url)
                } else {
                    ASMediaViewStaticView(image: currentImage)
                }
            } else {
                ASMediaViewUnsupportedView(fileURL: url)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .task {
            currentImage = NSImage(contentsOfFile: url.path)
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
            if item.mixedURLs == nil, urls.count > 1 {
                ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentIndex: $currentIndex)
                pageControl(urls: urls)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            currentPlayer?.pause()
            if let url = self.item.mixedURLs?[newValue] {
                currentPlayer = AVPlayer(url: url)
            } else {
                currentPlayer = AVPlayer(url: urls[newValue])
            }
            Task {
                do {
                    let size: NSSize
                    if let url = self.item.mixedURLs?[self.currentIndex] {
                        size = try await self.item.calculateVideoPlayerSize(forURL: url)
                    } else {
                        size = try await self.item.calculateVideoPlayerSize(forURLIndex: self.currentIndex)
                    }
                    await MainActor.run {
                        self.currentMinSize = size
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

    @ViewBuilder
    private func videoView(url: URL) -> some View {
        ZStack {
            if url.isSupportedVideo(), let currentPlayer {
                VideoPlayer(player: currentPlayer)
            } else {
                ASMediaViewUnsupportedView(fileURL: url)
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .task {
            currentPlayer = AVPlayer(url: url)
        }
    }

    @ViewBuilder
    private func pageControl(urls: [URL]) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ForEach(0..<urls.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index == currentIndex ? 1.0 : 0.5))
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            currentIndex = index
                        }
                }
                Spacer()
            }
            .padding(.bottom, 10)
        }
    }
}
