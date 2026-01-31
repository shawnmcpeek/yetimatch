import UIKit
import SwiftUI
import ComposeApp
import GoogleMobileAds

struct ComposeView: UIViewControllerRepresentable {
    init() {
        MainViewControllerKt.IOSBanner = {
            UIHostingController(rootView: BannerAdView())
        }
    }

    func makeUIViewController(context: Context) -> UIViewController {
        MainViewControllerKt.MainViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        ComposeView()
            .ignoresSafeArea()
    }
}



