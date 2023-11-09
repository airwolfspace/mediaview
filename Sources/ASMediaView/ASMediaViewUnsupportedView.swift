//
//  ASMediaViewUnsupportedView.swift
//  

import SwiftUI


struct ASMediaViewUnsupportedView: View {
    var fileURL: URL

    var body: some View {
        VStack {
            if let icon = fileIcon() {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64)
            } else {
                Image(systemName: "doc")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
            Text(fileURL.lastPathComponent)
                .foregroundColor(.secondary)
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            } label: {
                Text("Reveal in Finder")
            }
            .help(fileURL.absoluteString)
            .buttonStyle(.link)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // TODO: If set a idealWidth/idealHeight, when mixing with GIFs, the window would move in unexpected ways.
    }
    
    private func fileIcon() -> NSImage? {
        if let rep = NSWorkspace.shared.icon(forFile: fileURL.path)
            .bestRepresentation(for: NSRect(x: 0, y: 0, width: 128, height: 128), context: nil, hints: nil) {
            let image = NSImage(size: rep.size)
            image.addRepresentation(rep)
            return image
        }
        return nil
    }
}
