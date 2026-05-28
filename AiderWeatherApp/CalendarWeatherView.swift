import SwiftUI

struct CalendarWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var selectedMonth = Date()
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    HStack {
                        Text("\(monthYearString(from: selectedMonth))")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        HStack {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                            }
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 曜日ヘッダー
                    HStack {
                        ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // カレンダーグリッド
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 10) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            if let date = date {
                                CalendarDayCell(
                                    day: calendar.component(.day, from: date),
                                    weatherData: viewModel.calendarWeatherData[calendar.startOfDay(for: date)]
                                )
                            } else {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 天気の凡例
                    VStack(alignment: .leading, spacing: 10) {
                        Text("凡例")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack(spacing: 20) {
                            WeatherLegendItem(icon: "sun.max.fill", description: "晴れ")
                            WeatherLegendItem(icon: "cloud.sun.fill", description: "曇り")
                            WeatherLegendItem(icon: "cloud.rain.fill", description: "雨")
                            WeatherLegendItem(icon: "cloud.bolt.fill", description: "雷")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("天気カレンダー")
            .onAppear {
                Task {
                    await viewModel.fetchForecast(for: viewModel.selectedCity)
                }
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = []
        
        // 前月の空白セル
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // 当月の日付
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

struct CalendarDayCell: View {
    let day: Int
    let weatherData: (temp: Double, icon: String, description: String)?
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(day)")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let weatherData = weatherData {
                Image(systemName: weatherData.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                Text("\(Int(weatherData.temp))°C")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
                    .foregroundColor(.gray)
                Text("--°C")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
        )
    }
}

struct WeatherLegendItem: View {
    let icon: String
    let description: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
