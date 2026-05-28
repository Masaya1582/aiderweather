//
//  ContentView.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityInput = "Tokyo"
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 都市入力
                    HStack {
                        TextField("都市名を入力", text: $cityInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchWeather(for: cityInput)
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                    
                    if viewModel.isLoading {
                        ProgressView("天気データを取得中...")
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        // 天気情報カード
                        VStack(spacing: 15) {
                            // 都市名
                            Text(viewModel.weatherData.cityName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            // 天気アイコン
                            Image(systemName: viewModel.weatherData.icon)
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                            
                            // 気温
                            Text(viewModel.weatherData.temperature)
                                .font(.system(size: 60, weight: .medium))
                            
                            // 天気状態
                            Text(viewModel.weatherData.weatherDescription)
                                .font(.title2)
                                .textCase(.uppercase)
                                .foregroundColor(.secondary)
                            
                            // 詳細情報
                            HStack(spacing: 30) {
                                VStack {
                                    Image(systemName: "humidity.fill")
                                        .foregroundColor(.blue)
                                    Text("湿度")
                                        .font(.caption)
                                    Text(viewModel.weatherData.humidity)
                                        .font(.headline)
                                }
                                
                                VStack {
                                    Image(systemName: "wind")
                                        .foregroundColor(.green)
                                    Text("風速")
                                        .font(.caption)
                                    Text(viewModel.weatherData.windSpeed)
                                        .font(.headline)
                                }
                            }
                            .padding(.top)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            
                            if errorMessage.contains("APIキー") {
                                Link("OpenWeather APIキーを取得", destination: URL(string: "https://openweathermap.org/api")!)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                        .padding()
                    }
                    
                    Spacer()
                    
                    // 説明テキスト
                    Text("SwiftUI & Swift Concurrency 学習プロジェクト")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationTitle("天気アプリ")
            .task {
                // 初期表示時に東京の天気を取得
                await viewModel.fetchWeather()
            }
        }
    }
}

#Preview {
    ContentView()
}
