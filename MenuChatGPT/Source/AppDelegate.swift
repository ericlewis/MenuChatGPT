import ServiceManagement
import SwiftUI

let width: CGFloat = 520
let height: CGFloat = 640

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSPopoverDelegate {
  var popover: NSPopover!
  var statusBarItem: NSStatusItem!
  var statusBarMenu: NSMenu!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let contentView = ContentView()

    // our right click menu
    statusBarMenu = NSMenu(title: "ChatGPT Menu")
    statusBarMenu.delegate = self
    statusBarMenu.addItem(
      withTitle: "New Chat",
      action: #selector(AppDelegate.newChat),
      keyEquivalent: "n")
    statusBarMenu.addItem(
      withTitle: "New Chat",
      action: #selector(AppDelegate.newChat),
      keyEquivalent: "n")
    statusBarMenu.addItem(.separator())
    statusBarMenu.addItem(
      withTitle: "Quit",
      action: #selector(AppDelegate.quit),
      keyEquivalent: "q")

    self.popover = NSPopover()
    self.popover.contentSize = .init(width: width, height: height)
    self.popover.behavior = .transient
    self.popover.contentViewController = NSHostingController(rootView: contentView)
    self.popover.delegate = self
    self.popover.backgroundColor = #colorLiteral(red: 0.20, green: 0.21, blue: 0.25, alpha: 1.00)

    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "Icon")
      button.action = #selector(togglePopover(_:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    // launch all the time!
    try? SMAppService.mainApp.register()
  }

  @objc func togglePopover(_ sender: NSStatusBarButton) {
    if NSApp.currentEvent!.type == NSEvent.EventType.rightMouseUp {
      statusBarItem.menu = statusBarMenu
      statusBarItem.button?.performClick(nil)
    } else if self.popover.isShown {
      self.popover.performClose(sender)
    } else {
      self.popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
    }
  }

  @objc func menuDidClose(_ menu: NSMenu) {
    statusBarItem.menu = nil
  }

  @objc func newChat() {
    WebView.shared.reload()
    togglePopover(statusBarItem.button!)
  }

  @objc func quit() {
    NSApp.terminate(self)
  }

  @objc func popoverShouldDetach(_ popover: NSPopover) -> Bool {
    true
  }
}
