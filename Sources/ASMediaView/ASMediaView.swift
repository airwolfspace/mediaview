import SwiftUI


struct ASMediaView: View {
    var item: ASMediaItem

    var body: some View {
        let minSize = item.bestWindowMinSize()
        Group {
            if let urls = item.photoURLs {
                ScrollView(.horizontal, showsIndicators: false) {
                    ForEach(urls, id: \.self) { url in
                        if let image = NSImage(contentsOf: url) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            } else {
                VStack {
                    Text("No content.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .frame(minWidth: minSize.width, minHeight: minSize.height)
        .edgesIgnoringSafeArea(.top)
    }
}
