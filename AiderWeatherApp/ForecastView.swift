import SwiftUI

struct ForecastView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.forecastItems.prefix(10), id: \.dt) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.weather.first?.description ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(Int(item.main.temp))°C")
                        .font(.title2)
                    Image(systemName: weatherIcon(from: item.weather.first?.icon ?? ""))
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("5日間予報")
        .onAppear {
            Task {
                await viewModel.fetchForecast(for: viewModel.selectedCity)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM/dd HH:mm"
        return displayFormatter.string(from: date)
    }
    
    private func weatherIcon(from iconCode: String) -> String {
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
}
