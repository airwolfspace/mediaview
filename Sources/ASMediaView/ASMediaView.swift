import SwiftUI
import AVKit


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentIndex: Int
    @State private var currentImage: NSImage?
    @State private var currentVideo: AVPlayerItem?
    
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
            if let currentVideo {
                let player = AVPlayer(playerItem: currentVideo)
                VideoPlayer(player: player)
                    .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
                if urls.count > 1 {
                    ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentPhotoIndex: $currentIndex)
                }
            } else {
                ASMediaViewPlaceholderView()
            }
            ASMediaViewControlCloseView(id: item.id)
        }
        .onChange(of: currentIndex) { newValue in
            currentVideo = AVPlayerItem(url: urls[newValue])
        }
        .task {
            currentVideo = AVPlayerItem(url: urls[currentIndex])
        }
    }
}
