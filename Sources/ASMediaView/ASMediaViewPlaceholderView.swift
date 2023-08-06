import SwiftUI


struct ASMediaViewPlaceholderView: View {
    var placeholder: String?

    var body: some View {
        VStack {
            if let placeholder {
                Text(placeholder)
                    .foregroundColor(.secondary)
            } else {
                Text("No content.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
