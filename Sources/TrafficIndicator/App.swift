import SwiftUI

@main
struct TrafficIndicatorApp: App {
    @StateObject private var monitor = NetworkMonitor()
    @StateObject private var settings = Settings()

    var body: some Scene {
        MenuBarExtra {
            MenuView(monitor: monitor, settings: settings)
        } label: {
            let up = short(SpeedFormatter.string(for: monitor.speed.upload, unit: settings.unitMode))
            let down = short(SpeedFormatter.string(for: monitor.speed.download, unit: settings.unitMode))
            if settings.displayMode == .split {
                Text("↓ \(down)  ↑ \(up)")
                    .monospacedDigit()
            } else {
                if monitor.speed.upload >= monitor.speed.download {
                    Text("↑ \(up)")
                        .monospacedDigit()
                } else {
                    Text("↓ \(down)")
                        .monospacedDigit()
                }
            }
        }
    }

    private func short(_ s: String) -> String {
        s.replacingOccurrences(of: #"/s"#, with: "", options: .regularExpression)
    }
}
