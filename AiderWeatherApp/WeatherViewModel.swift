//
//  WeatherViewModel.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherDisplayData = .placeholder
    @Published var forecastItems: [ForecastItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCity: String = "Tokyo"
    
    private let weatherService = WeatherService.shared
    
    func fetchWeather(for city: String = "Tokyo") async {
        isLoading = true
        errorMessage = nil
        
        // APIキーが設定されているか確認
        if !weatherService.hasAPIKey() {
            errorMessage = "OpenWeather APIキーが設定されていません。\nWeatherService.swiftのapiKeyを設定してください。"
            isLoading = false
            return
        }
        
        do {
            let response = try await weatherService.fetchCurrentWeather(cityName: city)
            updateWeatherData(from: response)
        } catch {
            handleError(error)
        }
        
        // 天気予報も同時に取得
        await fetchForecast(for: city)
        
        isLoading = false
    }
    
    func fetchForecast(for city: String = "Tokyo") async {
        // APIキーが設定されているか確認
        if !weatherService.hasAPIKey() {
            return
        }
        
        do {
            let response = try await weatherService.fetchForecast(cityName: city)
            forecastItems = response.list
        } catch {
            // エラー時はforecastItemsを空にしてエラーメッセージを設定
            forecastItems = []
            print("Forecast error: \(error)")
            // 必要に応じてエラーメッセージを設定
            errorMessage = "天気予報の取得に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func updateCity(_ city: String) {
        selectedCity = city
        Task {
            await fetchWeather(for: city)
            await fetchForecast(for: city)
        }
    }
    
    private func updateWeatherData(from response: CurrentWeatherResponse) {
        weatherData = WeatherDisplayData(
            cityName: response.name,
            temperature: "\(Int(response.main.temp))°C",
            weatherDescription: response.weather.first?.description ?? "データなし",
            icon: weatherIcon(from: response.weather.first?.icon ?? ""),
            humidity: "\(response.main.humidity)%",
            windSpeed: "\(response.wind.speed) m/s"
        )
    }
    
    private func weatherIcon(from iconCode: String) -> String {
        // OpenWeatherのアイコンコードをSF Symbolにマッピング
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d", "03d", "04d": return "cloud.sun.fill"
        case "02n", "03n", "04n": return "cloud.moon.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark.circle"
        }
    }
    
    private func handleError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            switch weatherError {
            case .invalidURL:
                errorMessage = "無効なURLです。APIエンドポイントを確認してください。"
            case .invalidResponse:
                errorMessage = "サーバーからの応答が無効です。ステータスコードを確認してください。"
            case .invalidData:
                errorMessage = "データの解析に失敗しました。APIレスポンス形式が変更された可能性があります。"
            case .networkError(let underlyingError):
                errorMessage = "ネットワークエラー: \(underlyingError.localizedDescription)\nインターネット接続を確認してください。"
            }
        } else {
            errorMessage = "予期せぬエラーが発生しました: \(error.localizedDescription)"
        }
        
        // エラー時はプレースホルダーデータを表示
        weatherData = .placeholder
    }
}
