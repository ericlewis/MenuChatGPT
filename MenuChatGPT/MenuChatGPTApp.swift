import ServiceManagement
import SwiftUI
import WebKit

let width: CGFloat = 520
let height: CGFloat = 640

struct WebView: NSViewRepresentable {
  static let shared = WebView(URLRequest(url: URL(string: "https://chat.openai.com/chat")!))

  let request: URLRequest
  let webView: WKWebView = {
    let config = WKWebViewConfiguration()
    config.userContentController.addUserScript(
      .init(
        source: #"""
setInterval(async () => {
    const res = await fetch('/api/auth/session');
    console.log(res.ok);
  }, 30000);
"""#,
        injectionTime: .atDocumentEnd,
        forMainFrameOnly: false
      )
    )
    let webView = WKWebView(frame: .zero, configuration: config)
    return webView
  }()

  init(_ request: URLRequest) {
    self.request = request
  }

  func makeNSView(context: Context) -> WKWebView {
    self.webView.setValue(false, forKey: "drawsBackground")
    return webView
  }

  func updateNSView(_ nsView: WKWebView, context: Context) {
    nsView.load(request)
  }

  func reload() {
    webView.reload()
  }
}

struct ContentView: View {
  var body: some View {
    WebView.shared
      .frame(width: width, height: height)
  }
}

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
      keyEquivalent: "")
    statusBarMenu.addItem(.separator())
    statusBarMenu.addItem(
      withTitle: "Quit",
      action: #selector(AppDelegate.quit),
      keyEquivalent: "")

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

@main
struct MenuChatGPTApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  var body: some Scene {
    _EmptyScene()
  }
}

extension NSPopover {
  private struct Keys {
    static var backgroundViewKey = "backgroundKey"
  }

  private var backgroundView: NSView {
    let bgView = objc_getAssociatedObject(self, &Keys.backgroundViewKey) as? NSView
    if let view = bgView {
      return view
    }

    let view = NSView()
    objc_setAssociatedObject(self, &Keys.backgroundViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    NotificationCenter.default.addObserver(self, selector: #selector(popoverWillOpen(_:)), name: NSPopover.willShowNotification, object: nil)
    return view
  }

  @objc private func popoverWillOpen(_ notification: Notification) {
    if backgroundView.superview == nil, let contentView = contentViewController?.view, let frameView = contentView.superview {
      frameView.wantsLayer = true
      backgroundView.frame = NSInsetRect(frameView.frame, 1, 1)
      backgroundView.autoresizingMask = [.width, .height]
      frameView.addSubview(backgroundView, positioned: .below, relativeTo: contentView)
    }
  }

  var backgroundColor: NSColor? {
    get {
      if let bgColor = backgroundView.layer?.backgroundColor {
        return NSColor(cgColor: bgColor)
      }
      return nil
    }
    set {
      backgroundView.wantsLayer = true
      backgroundView.layer?.backgroundColor = newValue?.cgColor
    }
  }
}
