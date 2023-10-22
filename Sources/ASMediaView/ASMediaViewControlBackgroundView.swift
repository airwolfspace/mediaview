import SwiftUI


enum ASMediaViewControlType {
    case previous
    case next
    case close
}


struct ASMediaViewControlBackgroundView: View {
    @State private var isOnHover: Bool
    
    var controlType: ASMediaViewControlType
    
    init(withControlType type: ASMediaViewControlType) {
        self.controlType = type
        _isOnHover = State(initialValue: false)
    }

    var body: some View {
        let isCloseType = controlType == .close
        ZStack {
            Circle()
                .fill(.ultraThinMaterial.opacity(isOnHover ? 0.8 : 0.7))
                .frame(width: isCloseType ? 28 : 44, height: isCloseType ? 28 : 44)
                .shadow(color: isOnHover ? Color.secondary.opacity(0.25) : Color.clear, radius: isOnHover ? 1 : 0, x: 0, y: 0)
            Image(systemName: controlImageName())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.primary)
                .frame(width: isCloseType ? 11 : 22, height: isCloseType ? 11 : 22, alignment: .center)
        }
        .onHover { hovering in
            self.isOnHover = hovering
        }
    }
    
    private func controlImageName() -> String {
        switch controlType {
        case .previous:
            return "arrow.left"
        case .next:
            return "arrow.right"
        case .close:
            return "xmark"
        }
    }
}
