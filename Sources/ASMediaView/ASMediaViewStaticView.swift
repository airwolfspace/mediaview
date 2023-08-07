import SwiftUI


struct ASMediaViewStaticView: View {
    var image: NSImage?

    var body: some View {
        if let image {
            VStack {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            ASMediaViewPlaceholderView(placeholder: "Loading...")
        }
    }
}

struct ASMediaViewStaticView_Previews: PreviewProvider {
    static var previews: some View {
        ASMediaViewStaticView()
    }
}
