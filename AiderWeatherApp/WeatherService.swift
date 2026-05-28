//
//  WeatherService.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import Foundation

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case networkError(Error)
}

class WeatherService {
    private var apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    // シングルトンインスタンス
    static let shared = WeatherService()
    
    private init() {
        // 初期値は空文字列
        self.apiKey = ""
        
        // 環境変数からAPIキーを読み込む試み
        if let key = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"] {
            self.apiKey = key
        } else {
            // 開発用: Info.plistから読み込むことも可能
            // 実際のアプリではより安全な方法で管理してください
            print("警告: OpenWeather APIキーが設定されていません")
        }
    }
    
    func setAPIKey(_ key: String) {
        self.apiKey = key
    }
    
    func hasAPIKey() -> Bool {
        return !apiKey.isEmpty
    }
    
    // 現在の天気を取得
    func fetchCurrentWeather(cityName: String) async throws -> CurrentWeatherResponse {
        let endpoint = "/weather"
        let queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"), // 摂氏
            URLQueryItem(name: "lang", value: "ja") // 日本語
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    // 5日間の天気予報を取得
    func fetchForecast(cityName: String) async throws -> ForecastResponse {
        let endpoint = "/forecast"
        let queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ja")
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    // 共通のリクエスト処理
    private func performRequest<T: Codable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkError(error)
        }
    }
}
