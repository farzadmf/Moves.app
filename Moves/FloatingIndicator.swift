import Cocoa

class FloatingIndicator {
  static let shared = FloatingIndicator()

  private var window: NSWindow?
  private var monitor: Any?

  func show(for intention: Intention) {
    hide()

    let size: CGFloat = 48
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: size, height: size),
      styleMask: .borderless,
      backing: .buffered,
      defer: false
    )
    window.level = .floating
    window.backgroundColor = .clear
    window.isOpaque = false
    window.ignoresMouseEvents = true
    window.hasShadow = false

    let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: size, height: size))
    let symbolName = intention == .move ? "arrow.up.and.down.and.arrow.left.and.right" : "arrow.up.left.and.arrow.down.right"
    if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
      let config = NSImage.SymbolConfiguration(pointSize: 28, weight: .bold)
      imageView.image = image.withSymbolConfiguration(config)
      imageView.contentTintColor = .white
    }

    let background = NSView(frame: NSRect(x: 0, y: 0, width: size, height: size))
    background.wantsLayer = true
    background.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
    background.layer?.cornerRadius = 8

    background.addSubview(imageView)
    window.contentView = background

    updatePosition(window: window)
    window.orderFrontRegardless()
    self.window = window

    monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
      guard let self = self, let window = self.window else { return }
      self.updatePosition(window: window)
    }
  }

  func hide() {
    if let monitor = monitor {
      NSEvent.removeMonitor(monitor)
    }
    monitor = nil
    window?.orderOut(nil)
    window = nil
  }

  private func updatePosition(window: NSWindow) {
    let mouseLocation = NSEvent.mouseLocation
    window.setFrameOrigin(NSPoint(x: mouseLocation.x + 15, y: mouseLocation.y - 40))
  }
}
