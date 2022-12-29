import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(spacing: 0) {
      Rectangle().foregroundStyle(Color("DarkGrayColor"))
        .frame(height: 13)
      WebView.shared
      Rectangle().foregroundStyle(Color("DarkGrayColor"))
        .frame(height: 15)
        .overlay {
          Capsule().fill(Color.secondary)
            .frame(width: 95, height: 5)
            .padding(.bottom, 2)
        }
    }
    .background(Color("BackgroundColor"))
  }
}
