# ASMediaView

A window controller based media viewer for photos, videos and audios, for macOS.


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

        VStack {
            Button {
                ASMediaManager.shared.activatePhotoView(withPhotos: [earthDay], title: "Hello, One Photo Sample", andID: Self.oneID)
            } label: {
                Text("One Photo Sample")
            }
            Button {
                ASMediaManager.shared.activatePhotoView(withPhotos: [earthDay, ph], title: "Hello, Multiple Photos Sample", andID: Self.multipleID)
            } label: {
                Text("Multiple Photos Sample")
            }
        }
        .padding()
        .frame(width: 480, height: 320)
    }
}
```


## Work in progress
- [ ] Documentation
- [x] Photo support
- [ ] Video support
- [ ] Audio support
- [ ] Tests including UI Tests
