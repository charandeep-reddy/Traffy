import SwiftUI

@main
struct TraffyApp: App {
    @StateObject private var monitor = NetworkMonitor()
    @StateObject private var settings = Settings()

    var body: some Scene {
        MenuBarExtra {
            MenuView(monitor: monitor, settings: settings)
        } label: {
            LabelText(monitor: monitor, settings: settings)
                .onAppear { monitor.start(interval: settings.interval.rawValue) }
        }
        .menuBarExtraStyle(.window)
    }
}

private struct LabelText: View {
    @ObservedObject var monitor: NetworkMonitor
    @ObservedObject var settings: Settings

    var body: some View {
        let uploadIdle = SpeedFormatter.isIdle(monitor.speed.upload)
        let downloadIdle = SpeedFormatter.isIdle(monitor.speed.download)
        let fullyIdle = uploadIdle && downloadIdle

        if settings.hideSpeedWhenIdle && fullyIdle {
            Image(systemName: "network")
                .foregroundStyle(.secondary)
        } else {
            let up = short(SpeedFormatter.string(for: monitor.speed.upload, unit: settings.unitMode))
            let down = short(SpeedFormatter.string(for: monitor.speed.download, unit: settings.unitMode))

            if settings.displayMode == .split {
                Text("↓ \(down)  ↑ \(up)")
                    .monospacedDigit()
                    .foregroundStyle(fullyIdle ? .secondary : .primary)
            } else {
                if monitor.speed.upload >= monitor.speed.download {
                    Text("↑ \(up)")
                        .monospacedDigit()
                        .foregroundStyle(uploadIdle ? .secondary : .primary)
                } else {
                    Text("↓ \(down)")
                        .monospacedDigit()
                        .foregroundStyle(downloadIdle ? .secondary : .primary)
                }
            }
        }
    }

    private func short(_ s: String) -> String {
        s.replacingOccurrences(of: #"/s"#, with: "", options: .regularExpression)
    }
}
