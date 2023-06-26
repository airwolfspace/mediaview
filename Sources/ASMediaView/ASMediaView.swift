import SwiftUI


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentPhotoIndex: Int
    
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
                noContentView()
            }
        }
        .frame(minWidth: currentMinSize.width, minHeight: currentMinSize.height)
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    private func photosView(urls: [URL]) -> some View {
        if let image = NSImage(contentsOf: urls[currentPhotoIndex]) {
            ZStack {
                VStack {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                if urls.count > 1 {
                    ASMediaViewControlView(id: item.id, urls: urls, currentMinSize: $currentMinSize, currentPhotoIndex: $currentPhotoIndex)
                }
            }
        } else {
            noContentView()
        }
    }

    @ViewBuilder
    private func noContentView() -> some View {
        VStack {
            Text("No content.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
