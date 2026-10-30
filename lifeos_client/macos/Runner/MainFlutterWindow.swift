import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Open at a comfortable size the first time (sidebar + content), and
    // never shrink below a usable phone-width layout.
    self.setContentSize(NSSize(width: 1200, height: 800))
    self.contentMinSize = NSSize(width: 420, height: 560)
    self.center()
    self.setFrameAutosaveName("LifeOSMainWindow")

    // Blend the title bar into the app like native macOS apps.
    self.titlebarAppearsTransparent = true
    self.title = "LifeOS"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
