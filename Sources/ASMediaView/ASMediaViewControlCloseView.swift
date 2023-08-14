import SwiftUI


struct ASMediaViewControlCloseView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var id: UUID
    
    @State private var isHover: Bool = false {
        didSet {
            opacity = isHover ? 1.0 : 0.0
        }
    }
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                ASMediaViewControlBackgroundView(withControlType: .close)
                    .onTapGesture {
                        NotificationCenter.default.post(name: .closed(byID: self.id), object: nil)
                    }
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
                Spacer()
            }
            Spacer()
        }
        .padding(16)
        .onAppear {
            opacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideControlView()
            }
        }
    }
    
    private func hideControlView() {
        guard !isHover else { return }
        withAnimation {
            self.opacity = 0.0
        }
    }
}
