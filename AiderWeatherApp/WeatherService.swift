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
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    // シングルトンインスタンス
    static let shared = WeatherService()
    
    private init() {
        // APIキーを設定（実際のプロジェクトでは環境変数などから取得）
        // 注意: 実際のアプリでは安全な方法でAPIキーを管理してください
        self.apiKey = "YOUR_API_KEY_HERE" // 後で実際のキーに置き換える
    }
    
    func setAPIKey(_ key: String) {
        // 実行時にAPIキーを設定するためのメソッド
        // この実装では簡略化のためプロパティを変更可能にします
        // 実際のアプリではより安全な方法を検討してください
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
