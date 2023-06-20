import SwiftUI


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize
    @State private var currentPhotoIndex: Int
    @State private var isHover: Bool
    
    init(withItem item: ASMediaItem) {
        self.item = item
        _currentMinSize = State(initialValue: item.bestWindowMinSize())
        _currentPhotoIndex = State(initialValue: 0)
        _isHover = State(initialValue: false)
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
        .task {
            ASMediaManager.shared.centerWindowPosition(byID: self.item.id)
        }
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
                    controllerView(forURLs: urls)
                        .opacity(isHover ? 1.0 : 0.0)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .mouseEntered(byID: self.item.id)), perform: { _ in
                guard self.isHover == false else { return }
                Task { @MainActor in
                    self.isHover = true
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .mouseExited(byID: self.item.id)), perform: { _ in
                guard self.isHover == true else { return }
                Task { @MainActor in
                    self.isHover = false
                }
            })
        } else {
            noContentView()
        }
    }
    
    @ViewBuilder
    private func controllerView(forURLs urls: [URL]) -> some View {
        HStack {
            ZStack {
                Button {
                    updateIndex(byValue: -1, forURLs: urls)
                } label: {
                    Text("")
                }
                .opacity(0)
                .keyboardShortcut(.leftArrow, modifiers: [])
                controlBackgroundView()
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22, alignment: .center)
            }
            .onTapGesture {
                updateIndex(byValue: -1, forURLs: urls)
            }
            Spacer()
            ZStack {
                Button {
                    updateIndex(byValue: 1, forURLs: urls)
                } label: {
                    Text("")
                }
                .opacity(0)
                .keyboardShortcut(.rightArrow, modifiers: [])
                controlBackgroundView()
                Image(systemName: "arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22, alignment: .center)
            }
            .onTapGesture {
                updateIndex(byValue: 1, forURLs: urls)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func noContentView() -> some View {
        VStack {
            Text("No content.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private func controlBackgroundView() -> some View {
        Circle()
            .fill(Color.secondary.opacity(0.75))
            .frame(width: 44, height: 44)
    }
    
    private func updateIndex(byValue value: Int, forURLs urls: [URL]) {
        let currentIndex = currentPhotoIndex
        let updatedCurrentIndex = currentIndex + value
        Task { @MainActor in
            if updatedCurrentIndex > urls.count - 1 {
                currentPhotoIndex = 0
            } else if updatedCurrentIndex < 0 {
                currentPhotoIndex = urls.count - 1
            } else {
                currentPhotoIndex = updatedCurrentIndex
            }
            let value = NSValue(size: currentMinSize)
            NotificationCenter.default.post(name: .viewSizeChanged(byID: self.item.id), object: value)
        }
    }
}
