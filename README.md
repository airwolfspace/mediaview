# ASMediaView

A window controller based media viewer for local photos, videos and audios, for macOS.


## How to use
```
import SwiftUI
import ASMediaView


struct ContentView: View {
    static let oneID: UUID = UUID()
    static let multipleID: UUID = UUID()

    var body: some View {
        let earthDay = Bundle.main.urlForImageResource("earth-day")!
        let ph = Bundle.main.urlForImageResource("PH")!

        VStack (spacing: 20) {
            // Launch media view for single image:
            Button {
                ASMediaManager.shared.activatePhotoView(withPhotos: [earthDay], title: "Hello, One Photo Sample", andID: Self.oneID)
            } label: {
                Text("One Photo Sample")
            }
            
            // Launch media view for multiple images:
            Button {
                ASMediaManager.shared.activatePhotoView(withPhotos: [earthDay, ph], title: "Hello, Multiple Photos Sample", andID: Self.multipleID)
            } label: {
                Text("Multiple Photos Sample")
            }
            
            Divider()
            
            // Close all media views:
            Button {
                ASMediaManager.shared.deactivateAll()
            } label: {
                Text("Close All Views")
            }
        }
        .padding()
        .frame(width: 480, height: 320)
    }
}
```


## Work in progress
- [x] Documentation
- [x] Photo support (GIF animation)
- [ ] Video support
- [ ] Audio support
- [x] Tests including UI Tests
