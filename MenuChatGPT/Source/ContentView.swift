import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(spacing: 0) {
      Rectangle().foregroundStyle(Color("DarkGrayColor"))
        .frame(height: 15)
        .overlay {
          Capsule().fill(Color.secondary)
            .frame(width: 95, height: 5)
            .padding(.top, 8)
        }
      WebView.shared
    }
    .background(Color("BackgroundColor"))
  }
}
