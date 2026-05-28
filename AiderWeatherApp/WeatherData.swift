//
//  WeatherData.swift
//  AiderWeatherApp
//
//  Created by Masaya Nakakuki on 2026/05/28.
//

import Foundation

// MARK: - Current Weather Response
struct CurrentWeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

// MARK: - Forecast Response
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int?
    let pop: Double
    let rain: Rain?
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain
        case dtTxt = "dt_txt"
    }
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Sub-models
struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

struct Rain: Codable {
    let threeHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

// MARK: - View Models
struct WeatherDisplayData {
    let cityName: String
    let temperature: String
    let weatherDescription: String
    let icon: String
    let humidity: String
    let windSpeed: String
    
    static let placeholder = WeatherDisplayData(
        cityName: "東京",
        temperature: "25°C",
        weatherDescription: "晴れ",
        icon: "sun.max.fill",
        humidity: "65%",
        windSpeed: "5 m/s"
    )
}
