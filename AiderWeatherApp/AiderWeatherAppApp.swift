//
//  AiderWeatherAppApp.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import SwiftUI

@main
struct AiderWeatherAppApp: App {
    init() {
        // APIキーの設定
        setupAPIKey()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupAPIKey() {
        // 環境変数からAPIキーを読み込む
        if let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"] {
            WeatherService.shared.setAPIKey(apiKey)
            print("APIキーを環境変数から設定しました")
        } else {
            // 開発中はここで直接設定することも可能（本番では非推奨）
            // WeatherService.shared.setAPIKey("your_api_key_here")
            print("注意: APIキーが設定されていません")
            print("環境変数 OPENWEATHER_API_KEY を設定するか、")
            print("WeatherService.shared.setAPIKey() を直接呼び出してください")
        }
    }
}
