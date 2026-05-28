import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedCity") private var storedCity: String = "Tokyo"
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "celsius"
    @State private var cityInput: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        Form {
            Section(header: Text("都市設定")) {
                HStack {
                    TextField("都市名を入力", text: $cityInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFocused)
                    Button("保存") {
                        storedCity = cityInput
                        cityInput = ""
                        isInputFocused = false
                    }
                    .disabled(cityInput.isEmpty)
                }
                Text("現在の都市: \(storedCity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("温度単位")) {
                Picker("単位", selection: $temperatureUnit) {
                    Text("摂氏 (°C)").tag("celsius")
                    Text("華氏 (°F)").tag("fahrenheit")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("情報")) {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("設定")
        .onAppear {
            cityInput = storedCity
        }
    }
}
