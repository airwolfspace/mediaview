import SwiftUI


struct ASMediaView: View {
    var item: ASMediaItem
    
    @State private var currentMinSize: NSSize = .zero
    @State private var currentPhotoIndex: Int = 0
    @State private var isHover: Bool = false

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
            currentMinSize = self.item.bestWindowMinSize()
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
            .onReceive(NotificationCenter.default.publisher(for: .mouseEntered), perform: { _ in
                guard self.isHover == false else { return }
                Task { @MainActor in
                    self.isHover = true
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .mouseExited), perform: { _ in
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
        if updatedCurrentIndex > urls.count - 1 {
            currentPhotoIndex = 0
        } else if updatedCurrentIndex < 0 {
            currentPhotoIndex = urls.count - 1
        } else {
            currentPhotoIndex = updatedCurrentIndex
        }
        Task { @MainActor in
            /*
             * Disabled window resizing animation
            if let image = NSImage(contentsOf: urls[currentPhotoIndex]) {
                currentMinSize = self.item.bestWindowMinSize(forTargetSize: image.size)
            } else {
                currentMinSize = self.item.bestWindowMinSize()
            }
             */
            let value = NSValue(size: currentMinSize)
            NotificationCenter.default.post(name: .viewSizeChanged(byID: self.item.id), object: value)
        }
    }
}
