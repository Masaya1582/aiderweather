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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("天気予報チャート")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView("データを読み込み中...")
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if viewModel.forecastItems.isEmpty {
                        VStack {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                            Text("予報データがありません")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // 気温チャート
                        VStack(alignment: .leading, spacing: 10) {
                            Text("気温予報")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(viewModel.chartData, id: \.time) { dataPoint in
                                    LineMark(
                                        x: .value("日時", dataPoint.time),
                                        y: .value("気温", dataPoint.temperature)
                                    )
                                    .foregroundStyle(.red)
                                    .symbol(Circle())
                                    .symbolSize(50)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let temp = value.as(Double.self) {
                                            Text("\(Int(temp))°C")
                                        }
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let date = value.as(Date.self) {
                                            Text(date, format: .dateTime.hour())
                                        }
                                    }
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.2), radius: 5)
                            )
                            .padding(.horizontal)
                        }
                        
                        // 湿度チャート
                        VStack(alignment: .leading, spacing: 10) {
                            Text("湿度予報")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(viewModel.chartData, id: \.time) { dataPoint in
                                    AreaMark(
                                        x: .value("日時", dataPoint.time),
                                        y: .value("湿度", dataPoint.humidity)
                                    )
                                    .foregroundStyle(.blue.opacity(0.3))
                                    
                                    LineMark(
                                        x: .value("日時", dataPoint.time),
                                        y: .value("湿度", dataPoint.humidity)
                                    )
                                    .foregroundStyle(.blue)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let humidity = value.as(Int.self) {
                                            Text("\(humidity)%")
                                        }
                                    }
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.2), radius: 5)
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("チャート")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// チャート用のデータモデル
struct WeatherChartDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let humidity: Int
    let weatherDescription: String
    let icon: String
}

#Preview {
    WeatherChartView(viewModel: WeatherViewModel())
}
