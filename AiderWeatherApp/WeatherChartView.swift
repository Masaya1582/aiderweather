//
//  WeatherChartView.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import SwiftUI
import Charts

struct WeatherChartView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var selectedTimeRange: TimeRange = .hours24
    @State private var selectedChartType: ChartType = .temperature
    @State private var selectedDataPoint: WeatherChartDataPoint?
    @State private var showingDetailSheet = false
    
    enum TimeRange: String, CaseIterable {
        case hours24 = "24時間"
        case hours48 = "48時間"
        case hours72 = "72時間"
        
        var hourCount: Int {
            switch self {
            case .hours24: return 24
            case .hours48: return 48
            case .hours72: return 72
            }
        }
    }
    
    enum ChartType: String, CaseIterable {
        case temperature = "気温"
        case feelsLike = "体感温度"
        case humidity = "湿度"
        case pressure = "気圧"
        case windSpeed = "風速"
        case precipitation = "降水確率"
        case cloudiness = "雲量"
    }
    
    var filteredChartData: [WeatherChartDataPoint] {
        let totalHours = selectedTimeRange.hourCount
        let dataPointsNeeded = totalHours / 3 // 3時間間隔
        return Array(viewModel.chartData.prefix(dataPointsNeeded))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    headerSection
                    
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.forecastItems.isEmpty {
                        emptyView
                    } else {
                        // コントロールパネル
                        controlPanel
                        
                        // メインチャート
                        mainChartSection
                        
                        // 統計カード
                        statisticsSection
                        
                        // データカードグリッド
                        dataCardGrid
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("詳細チャート")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDetailSheet) {
                if let dataPoint = selectedDataPoint {
                    DetailDataSheet(dataPoint: dataPoint)
                }
            }
        }
    }
    
    // MARK: - ヘッダー
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("天気予報チャート")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("詳細な気象データを可視化")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - ローディングビュー
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("気象データを読み込み中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    // MARK: - 空ビュー
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            Text("予報データがありません")
                .font(.title2)
                .fontWeight(.medium)
            Text("都市を選択してデータを取得してください")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    // MARK: - コントロールパネル
    private var controlPanel: some View {
        VStack(spacing: 15) {
            // 時間範囲選択
            VStack(alignment: .leading, spacing: 8) {
                Text("時間範囲")
                    .font(.headline)
                Picker("時間範囲", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // チャートタイプ選択
            VStack(alignment: .leading, spacing: 8) {
                Text("表示データ")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            ChartTypeButton(
                                type: type,
                                isSelected: selectedChartType == type,
                                action: { selectedChartType = type }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - メインチャート
    private var mainChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(selectedChartType.rawValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: chartIcon(for: selectedChartType))
                    .font(.title3)
                    .foregroundColor(chartColor(for: selectedChartType))
            }
            .padding(.horizontal)
            
            Chart {
                ForEach(filteredChartData) { dataPoint in
                    LineMark(
                        x: .value("日時", dataPoint.time),
                        y: .value("値", chartValue(for: dataPoint))
                    )
                    .foregroundStyle(chartColor(for: selectedChartType))
                    .symbol(Circle())
                    .symbolSize(40)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("日時", dataPoint.time),
                        y: .value("値", chartValue(for: dataPoint))
                    )
                    .foregroundStyle(chartColor(for: selectedChartType))
                    .symbolSize(60)
                    .opacity(0)
                    .annotation(position: .overlay) {
                        Button(action: {
                            selectedDataPoint = dataPoint
                            showingDetailSheet = true
                        }) {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(chartAxisLabel(for: doubleValue))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour())
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 15, y: 8)
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - 統計セクション
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("統計情報")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    StatCard(
                        title: "最高気温",
                        value: String(format: "%.1f°C", filteredChartData.map { $0.temperature }.max() ?? 0),
                        icon: "thermometer.sun.fill",
                        color: .orange
                    )
                    StatCard(
                        title: "最低気温",
                        value: String(format: "%.1f°C", filteredChartData.map { $0.temperature }.min() ?? 0),
                        icon: "thermometer.snowflake",
                        color: .blue
                    )
                    StatCard(
                        title: "平均風速",
                        value: String(format: "%.1f m/s", filteredChartData.map { $0.windSpeed }.reduce(0, +) / Double(filteredChartData.count)),
                        icon: "wind",
                        color: .cyan
                    )
                    StatCard(
                        title: "降水確率",
                        value: String(format: "%.0f%%", filteredChartData.map { $0.precipitation }.max() ?? 0),
                        icon: "cloud.rain.fill",
                        color: .indigo
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - データカードグリッド
    private var dataCardGrid: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("詳細データ")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(filteredChartData.prefix(6)) { dataPoint in
                    DataCard(dataPoint: dataPoint)
                        .onTapGesture {
                            selectedDataPoint = dataPoint
                            showingDetailSheet = true
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - ヘルパーメソッド
    private func chartValue(for dataPoint: WeatherChartDataPoint) -> Double {
        switch selectedChartType {
        case .temperature:
            return dataPoint.temperature
        case .feelsLike:
            return dataPoint.feelsLike
        case .humidity:
            return Double(dataPoint.humidity)
        case .pressure:
            return Double(dataPoint.pressure)
        case .windSpeed:
            return dataPoint.windSpeed
        case .precipitation:
            return dataPoint.precipitation
        case .cloudiness:
            return Double(dataPoint.cloudiness)
        }
    }
    
    private func chartColor(for type: ChartType) -> Color {
        switch type {
        case .temperature: return .red
        case .feelsLike: return .orange
        case .humidity: return .blue
        case .pressure: return .purple
        case .windSpeed: return .cyan
        case .precipitation: return .indigo
        case .cloudiness: return .gray
        }
    }
    
    private func chartIcon(for type: ChartType) -> String {
        switch type {
        case .temperature: return "thermometer"
        case .feelsLike: return "thermometer.medium"
        case .humidity: return "humidity"
        case .pressure: return "barometer"
        case .windSpeed: return "wind"
        case .precipitation: return "cloud.rain"
        case .cloudiness: return "cloud"
        }
    }
    
    private func chartAxisLabel(for value: Double) -> String {
        switch selectedChartType {
        case .temperature, .feelsLike:
            return "\(Int(value))°C"
        case .humidity, .precipitation, .cloudiness:
            return "\(Int(value))%"
        case .pressure:
            return "\(Int(value)) hPa"
        case .windSpeed:
            return String(format: "%.1f m/s", value)
        }
    }
}

// MARK: - チャートタイプボタン
struct ChartTypeButton: View {
    let type: WeatherChartView.ChartType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(type.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
    
    private var iconName: String {
        switch type {
        case .temperature: return "thermometer"
        case .feelsLike: return "person.fill"
        case .humidity: return "drop.fill"
        case .pressure: return "barometer"
        case .windSpeed: return "wind"
        case .precipitation: return "cloud.rain.fill"
        case .cloudiness: return "cloud.fill"
        }
    }
}

// MARK: - 統計カード
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }
}

// MARK: - データカード
struct DataCard: View {
    let dataPoint: WeatherChartDataPoint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(dataPoint.time, format: .dateTime.hour())
                    .font(.headline)
                Spacer()
                Image(systemName: dataPoint.icon)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(dataPoint.temperature))°C")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("体感 \(Int(dataPoint.feelsLike))°C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("風速")
                            .font(.caption)
                        Text(String(format: "%.1f m/s", dataPoint.windSpeed))
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("降水")
                            .font(.caption)
                        Text("\(Int(dataPoint.precipitation))%")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }
}

// MARK: - 詳細データシート
struct DetailDataSheet: View {
    @Environment(\.dismiss) var dismiss
    let dataPoint: WeatherChartDataPoint
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダーカード
                    VStack(spacing: 10) {
                        Text(dataPoint.time, format: .dateTime.weekday().day().month().hour())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // 天気アイコンと説明
                        HStack(spacing: 15) {
                            Image(systemName: dataPoint.icon)
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 5)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(dataPoint.weatherDescription)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                Text("詳細気象データ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        )
                    }
                    .padding()
                    
                    // データグリッド - モダンなカードデザイン
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        DetailItem(title: "気温", value: "\(Int(dataPoint.temperature))°C", icon: "thermometer", color: .red)
                        DetailItem(title: "体感温度", value: "\(Int(dataPoint.feelsLike))°C", icon: "thermometer.medium", color: .orange)
                        DetailItem(title: "湿度", value: "\(dataPoint.humidity)%", icon: "humidity", color: .blue)
                        DetailItem(title: "気圧", value: "\(dataPoint.pressure) hPa", icon: "barometer", color: .purple)
                        DetailItem(title: "風速", value: String(format: "%.1f m/s", dataPoint.windSpeed), icon: "wind", color: .cyan)
                        DetailItem(title: "突風風速", value: String(format: "%.1f m/s", dataPoint.windGust), icon: "wind.circle", color: .teal)
                        DetailItem(title: "雲量", value: "\(dataPoint.cloudiness)%", icon: "cloud", color: .gray)
                        DetailItem(title: "降水確率", value: "\(Int(dataPoint.precipitation))%", icon: "cloud.rain", color: .indigo)
                    }
                    .padding()
                    
                    // 追加統計情報
                    VStack(alignment: .leading, spacing: 15) {
                        Text("統計情報")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatCardMini(title: "熱指数", value: "\(calculateHeatIndex(temp: dataPoint.temperature, humidity: dataPoint.humidity))°C", icon: "thermometer.high", color: .red)
                            StatCardMini(title: "体感差", value: "\(Int(abs(dataPoint.temperature - dataPoint.feelsLike)))°C", icon: "arrow.left.arrow.right", color: .orange)
                            StatCardMini(title: "風速比", value: String(format: "%.1f", dataPoint.windGust / max(dataPoint.windSpeed, 0.1)), icon: "wind.circle", color: .cyan)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("詳細気象データ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("完了")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private func calculateHeatIndex(temp: Double, humidity: Int) -> Int {
        // 簡易的な熱指数計算
        let t = temp
        let rh = Double(humidity)
        let heatIndex = 0.5 * (t + 61.0 + ((t - 68.0) * 1.2) + (rh * 0.094))
        return Int(heatIndex)
    }
}

struct StatCardMini: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        )
    }
}

struct DetailItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        )
    }
}

// チャート用のデータモデル
struct WeatherChartDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let pressure: Int
    let windSpeed: Double
    let windGust: Double
    let cloudiness: Int
    let precipitation: Double
    let weatherDescription: String
    let icon: String
}

#Preview {
    WeatherChartView(viewModel: WeatherViewModel())
}
