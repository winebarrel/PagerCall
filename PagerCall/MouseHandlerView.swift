// from https://github.com/orchetect/MenuBarExtraAccess/discussions/2#discussioncomment-5744323
import SwiftUI

class MouseHandlerView: NSView {
    var onRightMouseDown: (() -> Void)?
    var onMouseDown: (() -> Void)?

    override func rightMouseDown(with event: NSEvent) {
        if let onRightMouseDown {
            onRightMouseDown()
        } else {
            super.rightMouseDown(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let onMouseDown {
            onMouseDown()
        } else {
            super.mouseDown(with: event)
        }
    }
}
