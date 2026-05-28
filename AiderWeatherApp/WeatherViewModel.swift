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
    
    func weatherIcon(from iconCode: String) -> String {
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
    
    // チャート用に加工したデータ
    var chartData: [WeatherChartDataPoint] {
        // 最初の24時間分の予報データを使用（3時間間隔なので8点）
        let forecastItemsToUse = Array(forecastItems.prefix(8))
        
        return forecastItemsToUse.map { item in
            WeatherChartDataPoint(
                time: Date(timeIntervalSince1970: TimeInterval(item.dt)),
                temperature: item.main.temp,
                humidity: item.main.humidity,
                weatherDescription: item.weather.first?.description ?? "",
                icon: weatherIcon(from: item.weather.first?.icon ?? "")
            )
        }
    }
    
    // カレンダー表示用のデータ（日付ごとにグループ化）
    var calendarWeatherData: [Date: (temp: Double, icon: String, description: String)] {
        var result: [Date: (temp: Double, icon: String, description: String)] = [:]
        let calendar = Calendar.current
        
        for item in forecastItems {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let dayStart = calendar.startOfDay(for: date)
            
            // 既に同じ日付のデータがある場合は、温度の平均を取るか、最初のものを保持
            if result[dayStart] == nil {
                let iconCode = item.weather.first?.icon ?? ""
                result[dayStart] = (
                    temp: item.main.temp,
                    icon: weatherIcon(from: iconCode),
                    description: item.weather.first?.description ?? ""
                )
            }
        }
        return result
    }
    
    // 日付フォーマット用のヘルパーメソッド
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
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
