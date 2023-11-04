import Cocoa
import Quartz


class ASMediaGIFImageView: QLPreviewView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
    }
}
