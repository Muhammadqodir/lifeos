import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var menuCommands: MenuCommands?

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

    let channel = FlutterMethodChannel(
      name: "lifeos/menu",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    menuCommands = MenuCommands(channel: channel)
    // Wait for MainMenu.xib to finish loading the menu bar.
    DispatchQueue.main.async { [weak self] in self?.menuCommands?.install() }

    super.awakeFromNib()
  }
}

/// Adds File, View and Go commands to the menu bar from MainMenu.xib and
/// forwards them to the app shell (main_page.dart) over "lifeos/menu".
///
/// The key equivalents match the shell's own shortcuts. Flutter gets each
/// key press first, so a shortcut runs once: in Flutter when the shell has
/// focus, otherwise through the menu item.
final class MenuCommands: NSObject {
  private let channel: FlutterMethodChannel

  /// Same order as the tabs in main_page.dart.
  private let tabs = ["Home", "Finances", "Health", "Projects", "More"]

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  func install() {
    guard let mainMenu = NSApp.mainMenu else { return }

    let file = NSMenu(title: "File")
    file.addItem(item("New Item", key: "n", action: #selector(newItem)))
    file.addItem(.separator())
    file.addItem(
      NSMenuItem(
        title: "Close Window", action: #selector(NSWindow.performClose(_:)),
        keyEquivalent: "w"))
    insert(file, into: mainMenu, at: 1)

    if let view = mainMenu.item(withTitle: "View")?.submenu {
      view.insertItem(item("Refresh", key: "r", action: #selector(refresh)), at: 0)
      view.insertItem(.separator(), at: 1)
    }

    let go = NSMenu(title: "Go")
    go.addItem(item("Back", key: "[", action: #selector(back)))
    go.addItem(.separator())
    for (index, name) in tabs.enumerated() {
      let tab = item(name, key: "\(index + 1)", action: #selector(selectTab(_:)))
      tab.tag = index
      go.addItem(tab)
    }
    let viewIndex = mainMenu.indexOfItem(withTitle: "View")
    insert(go, into: mainMenu, at: viewIndex >= 0 ? viewIndex + 1 : mainMenu.numberOfItems)
  }

  private func item(_ title: String, key: String, action: Selector) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
    item.target = self
    return item
  }

  private func insert(_ menu: NSMenu, into mainMenu: NSMenu, at index: Int) {
    let holder = NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
    holder.submenu = menu
    mainMenu.insertItem(holder, at: min(index, mainMenu.numberOfItems))
  }

  @objc private func newItem() { channel.invokeMethod("newItem", arguments: nil) }
  @objc private func refresh() { channel.invokeMethod("refresh", arguments: nil) }
  @objc private func back() { channel.invokeMethod("back", arguments: nil) }
  @objc private func selectTab(_ sender: NSMenuItem) {
    channel.invokeMethod("selectTab", arguments: sender.tag)
  }
}
