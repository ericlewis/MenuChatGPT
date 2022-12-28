import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let request: URLRequest

    func makeNSView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.setValue(false, forKey: "drawsBackground")
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(request)
    }
}

struct ContentView: View {
  var body: some View {
    WebView(request: URLRequest(url: URL(string: "https://chat.openai.com/chat")!))
      .frame(width: 520, height: 640)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {

  var popover: NSPopover!
  var statusBarItem: NSStatusItem!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let contentView = ContentView()

    let popover = NSPopover()
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: contentView)
    self.popover = popover
    self.popover.backgroundColor = #colorLiteral(red: 0.20, green: 0.21, blue: 0.25, alpha: 1.00)

    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "Icon")
      button.action = #selector(togglePopover(_:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
  }

  @objc func togglePopover(_ sender: NSStatusBarButton) {
    if self.popover.isShown {
      self.popover.performClose(sender)
    } else {
      self.popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
    }
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
        if backgroundView.superview == nil {
            if let contentView = contentViewController?.view, let frameView = contentView.superview {
                frameView.wantsLayer = true
                backgroundView.frame = NSInsetRect(frameView.frame, 1, 1)
                backgroundView.autoresizingMask = [.width, .height]
                frameView.addSubview(backgroundView, positioned: .below, relativeTo: contentView)
            }
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
