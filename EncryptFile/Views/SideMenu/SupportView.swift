import SwiftUI
import WebKit

struct ActivityIndicatorView: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 3, height: geometry.size.height / 7.5)
                .background(Color.secondary.opacity(0.2))
                .foregroundColor(Color.red)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var url: String
    @Published var isLoading = true

    init(url: String) {
        self.url = url
    }
}

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    let webView = WKWebView()

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                webView.evaluateJavaScript("document.getElementsByClassName('t-tildalabel')[0].remove()")
            }
        }
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<WebView>) {}

    func makeUIView(context: Context) -> UIView {
        webView.navigationDelegate = context.coordinator

        if let url = URL(string: viewModel.url) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }
}

struct SupportView: View {
    @StateObject var model = WebViewModel(url: "https://ncrpt.io/support")
    var body: some View {
        VStack(alignment: .leading) {
            LoadingView(isShowing: self.$model.isLoading) {
                WebView(viewModel: self.model)
            }
        }
        .navigationTitle("support")
        .navigationBarTitleDisplayMode(.inline)
    }
}
