import SwiftUI


struct ASMediaViewControlBackgroundView: View {
    @State private var isOnHover: Bool
    
    init() {
        _isOnHover = State(initialValue: false)
    }
    
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial.opacity(isOnHover ? 0.95 : 0.7))
            .frame(width: 44, height: 44)
            .shadow(color: isOnHover ? Color.secondary.opacity(0.25) : Color.clear, radius: isOnHover ? 1 : 0, x: 0, y: 0)
            .onHover { hovering in
                self.isOnHover = hovering
            }
    }
}
