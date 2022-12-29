import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(spacing: 0) {
      Rectangle().foregroundStyle(Color("DarkGrayColor"))
        .frame(height: 15)
      WebView.shared
    }
    .background(Color("BackgroundColor"))
  }
}
