import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
  static let shared = WebView(URLRequest(url: URL(string: "https://chat.openai.com/chat")!))

  let request: URLRequest
  let webView: WKWebView = {
    let config = WKWebViewConfiguration()
    config.userContentController.addUserScript(
      .init(
        source: #"""
const addStyle = (() => {
  const style = document.createElement('style');
  document.head.append(style);
  return (styleString) => style.textContent = styleString;
})();

addStyle(`
  .sticky.top-0.z-10.flex.items-center {
    padding-top: 0px !important;
  }
  .px-3.pt-2.pb-3.text-center.text-xs {
    visibility:hidden !important;
    height: 0px !important;
    padding-bottom: 0px !important;
  }
`);

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
    webView.underPageBackgroundColor = NSColor(named: "BackgroundColor")
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
