import SwiftUI


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentPhotoIndex: Int
    @State private var currentImage: NSImage?
    
    init(withItem item: ASMediaItem) {
        self.item = item
        _currentMinSize = State(initialValue: item.bestWindowMinSize())
        _currentPhotoIndex = State(initialValue: 0)
    }

    var body: some View {
        Group {
            if let urls = item.photoURLs, urls.count > 0 {
                photosView(urls: urls)
            } else {
                ASMediaViewPlaceholderView()
            }
        }
        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
        .edgesIgnoringSafeArea(.top)
        .onDisappear {
            currentImage = nil
        }
    }
    
    @ViewBuilder
    private func photosView(urls: [URL]) -> some View {
        ZStack {
            if let image = NSImage(contentsOfFile: urls[currentPhotoIndex].path) {
                if image.isGIFImage() {
                    ASMediaViewGIFAnimationView(image: image)
                } else {
                    if let currentImage {
                        VStack {
                            Image(nsImage: currentImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    } else {
                        ASMediaViewPlaceholderView()
                    }
                }
                if urls.count > 1 {
                    ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentPhotoIndex: $currentPhotoIndex)
                }
                ASMediaViewControlCloseView(id: item.id)
            } else {
                ASMediaViewPlaceholderView()
                ASMediaViewControlCloseView(id: item.id)
            }
        }
        .onChange(of: currentPhotoIndex) { newValue in
            if let image = NSImage(contentsOfFile: urls[newValue].path) {
                currentImage = image
            } else {
                currentImage = nil
            }
        }
        .task {
            if let image = NSImage(contentsOfFile: urls[currentPhotoIndex].path) {
                currentImage = image
            }
        }
    }
}
