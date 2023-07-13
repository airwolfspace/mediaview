import SwiftUI


struct ASMediaViewControlCloseView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var id: UUID
    
    @State private var isHover: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                ASMediaViewControlBackgroundView(withControlType: .close)
                    .onTapGesture {
                        NotificationCenter.default.post(name: .closed(byID: self.id), object: nil)
                    }
                    .opacity(isHover ? 1.0 : 0.0)
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
    }
}
