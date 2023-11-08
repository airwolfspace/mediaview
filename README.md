# ASMediaView

A window controller based media viewer for local photos, videos and audios, for macOS.

![](https://github.com/airwolfspace/mediaview/blob/main/media-view-1.1.gif)

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
            
            // Launch media view for single audio:
            Button {
                ASMediaManager.shared.activateAudioView(withAudios: [mp3], title: "One MP3", id: Self.oneID8)
            } label: {
                Text("One MP3")
            }
            
            // Launch media view for multiple audios:
            Button {
                ASMediaManager.shared.activateAudioView(withAudios: [mp3, otherMp3], title: "Two MP3", id: Self.multipleID14)
            } label: {
                Text("Two MP3")
            }
            
            // Launch media view for mixed media types, and init window size:
            Button {
                ASMediaManager.shared.activateMediaView(withURLs: [mp3, video, gif1, png, gif3, unsupported], title: "Mixed Videos, Photos and Audios", id: Self.multipleID17, defaultSize: NSSize(width: 480, height: 320))
            } label: {
                Text("Mixed Videos, Photos and Audios")
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
