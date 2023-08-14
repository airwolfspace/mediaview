import SwiftUI


struct ASMediaViewControlView: View {
    var id: UUID
    var urls: [URL]
    
    @Binding var currentMinSize: NSSize
    @Binding var currentPhotoIndex: Int

    @State private var isHover: Bool = false {
        didSet {
            opacity = isHover ? 1.0 : 0.0
        }
    }
    @State private var opacity: Double = 0

    var body: some View {
        HStack {
            ZStack {
                Button {
                    updateIndex(byValue: -1, forURLs: urls)
                } label: {
                    Text("")
                }
                .opacity(0)
                .keyboardShortcut(.leftArrow, modifiers: [])
                ASMediaViewControlBackgroundView(withControlType: .previous)
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
                ASMediaViewControlBackgroundView(withControlType: .next)
            }
            .onTapGesture {
                updateIndex(byValue: 1, forURLs: urls)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .opacity(opacity)
        .onReceive(NotificationCenter.default.publisher(for: .mouseEntered(byID: id)), perform: { _ in
            Task { @MainActor in
                guard self.isHover == false else { return }
                self.isHover = true
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .mouseExited(byID: id)), perform: { _ in
            Task { @MainActor in
                guard self.isHover == true else { return }
                self.isHover = false
            }
        })
        .onAppear {
            opacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideControlView()
            }
        }
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
            NotificationCenter.default.post(name: .viewSizeChanged(byID: self.id), object: value)
        }
    }
    
    private func hideControlView() {
        guard !isHover else { return }
        withAnimation {
            self.opacity = 0.0
        }
    }
}
