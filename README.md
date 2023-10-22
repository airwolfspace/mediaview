# ASMediaView

A window controller based media viewer for local photos, videos and audios, for macOS.


## How to use
```
import SwiftUI
import ASMediaView


struct ContentView: View {
    static let oneID: UUID = UUID()
    static let multipleID: UUID = UUID()
    static let oneVideoID: UUID = UUID()
    static let multipleVideoID: UUID = UUID()

    var body: some View {
        let earthDay = Bundle.main.urlForImageResource("earth-day")!
        let ph = Bundle.main.urlForImageResource("PH")!
        let video = Bundle.main.url(forResource: "IMG_0243", withExtension: "MOV")!
        let video2 = Bundle.main.url(forResource: "IMG_0255", withExtension: "mov")!

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
            
            // Launch media view for single video:
            Button {
                ASMediaManager.shared.activateVideoView(withVideos: [video], title: "One Video", andID: Self.oneVideoID)
            } label: {
                Text("One Video")
            }
            
            // Launch media view for multiple videos:
            Button {
                ASMediaManager.shared.activateVideoView(withVideos: [video, video2], title: "Multiple Videos", andID: Self.multipleVideoID)
            } label: {
                Text("Multiple Videos")
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
- [x] Video support
- [x] Audio support
- [x] Tests including UI Tests
