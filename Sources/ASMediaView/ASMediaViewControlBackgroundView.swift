import SwiftUI


enum ASMediaViewControlDirection {
    case previous
    case next
}


struct ASMediaViewControlBackgroundView: View {
    @State private var isOnHover: Bool
    
    var direction: ASMediaViewControlDirection
    
    init(withDirection direction: ASMediaViewControlDirection) {
        self.direction = direction
        _isOnHover = State(initialValue: false)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial.opacity(isOnHover ? 0.8 : 0.7))
                .frame(width: 44, height: 44)
                .shadow(color: isOnHover ? Color.secondary.opacity(0.25) : Color.clear, radius: isOnHover ? 1 : 0, x: 0, y: 0)
            Image(systemName: direction == .next ? "arrow.right" : "arrow.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.white)
                .frame(width: 22, height: 22, alignment: .center)
        }
        .onHover { hovering in
            self.isOnHover = hovering
        }
    }
}
