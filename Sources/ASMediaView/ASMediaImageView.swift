import Cocoa


class ASMediaImageView: NSImageView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.animates = true
    }
    
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
