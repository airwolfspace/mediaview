import SwiftUI


struct ASMediaViewPlaceholderView: View {
    var placeholder: String?

    var body: some View {
        VStack {
            if let placeholder {
                Text(placeholder)
            } else {
                Text("No content.")
            }
        }
        .foregroundColor(.secondary)
        .padding()
    }
}
