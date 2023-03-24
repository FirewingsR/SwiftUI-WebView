//
//  iOS_WebViewApp.swift
//  iOS-WebView
//
//  Created by William on 2023/3/22.
//

import SwiftUI
import UIKit

@main
struct SwiftUIDemoAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            SwiftUIDemoApp.main()
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(SceneDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct SwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
