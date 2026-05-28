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
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.5), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // タイトル
                        Text("🌤️ 天気アプリ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top)
                        
                        // 都市入力セクション
                        VStack(spacing: 15) {
                            Text("都市名を入力してください")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("例: Tokyo, London, Paris", text: $cityInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .focused($isInputFocused)
                                    .submitLabel(.search)
                                    .onSubmit {
                                        Task {
                                            await fetchWeather()
                                        }
                                    }
                                
                                Button(action: {
                                    Task {
                                        await fetchWeather()
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                .padding(.trailing)
                                .disabled(viewModel.isLoading)
                            }
                        }
                        .padding(.horizontal)
                        
                        // ローディング表示
                        if viewModel.isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("天気データを取得中...")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 40)
                        }
                        
                        // エラーメッセージ
                        if let errorMessage = viewModel.errorMessage {
                            VStack(spacing: 15) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                
                                Text(errorMessage)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                if errorMessage.contains("APIキー") {
                                    Link("OpenWeather APIキーを取得", destination: URL(string: "https://openweathermap.org/api")!)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.top, 5)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        // 天気情報カード
                        if !viewModel.isLoading && viewModel.errorMessage == nil {
                            VStack(spacing: 20) {
                                // 都市名
                                Text(viewModel.weatherData.cityName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                // 天気アイコンと気温
                                HStack(spacing: 10) {
                                    Image(systemName: viewModel.weatherData.icon)
                                        .font(.system(size: 70))
                                        .foregroundColor(.orange)
                                    
                                    Text(viewModel.weatherData.temperature)
                                        .font(.system(size: 55, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                
                                // 天気状態
                                Text(viewModel.weatherData.weatherDescription)
                                    .font(.title2)
                                    .textCase(.uppercase)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 5)
                                
                                // 詳細情報
                                HStack(spacing: 40) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "drop.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        Text("湿度")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(viewModel.weatherData.humidity)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "wind")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                        Text("風速")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(viewModel.weatherData.windSpeed)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .padding(.vertical, 30)
                            .padding(.horizontal, 25)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // フッター
                        VStack(spacing: 10) {
                            Divider()
                                .padding(.horizontal)
                            
                            Text("SwiftUI & Swift Concurrency 学習プロジェクト")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                // 初期表示時に東京の天気を取得
                Task {
                    await viewModel.fetchWeather(for: cityInput)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func fetchWeather() async {
        isInputFocused = false
        await viewModel.fetchWeather(for: cityInput)
    }
}

#Preview {
    ContentView()
}
