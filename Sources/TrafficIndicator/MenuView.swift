import SwiftUI
import ServiceManagement

struct MenuView: View {
    @ObservedObject var monitor: NetworkMonitor
    @ObservedObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading) {
            if settings.displayMode == .split {
                HStack(spacing: 4) {
                    Text("↑ \(SpeedFormatter.string(for: monitor.speed.upload, unit: settings.unitMode))")
                    Text("↓ \(SpeedFormatter.string(for: monitor.speed.download, unit: settings.unitMode))")
                }
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
            } else {
                let up = monitor.speed.upload
                let down = monitor.speed.download
                HStack(spacing: 4) {
                    if up >= down {
                        Text("↑ \(SpeedFormatter.string(for: up, unit: settings.unitMode))")
                    } else {
                        Text("↓ \(SpeedFormatter.string(for: down, unit: settings.unitMode))")
                    }
                }
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
            }

            Divider()

            Menu("Mode") {
                ForEach(DisplayMode.allCases, id: \.self) { mode in
                    Button {
                        settings.displayMode = mode
                    } label: {
                        HStack {
                            Text(mode == .split ? "Split" : "Combined")
                            if mode == settings.displayMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Menu("Unit") {
                ForEach(UnitMode.allCases, id: \.self) { unit in
                    Button {
                        settings.unitMode = unit
                    } label: {
                        HStack {
                            Text(unit == .bytes ? "Bytes" : "Bits")
                            if unit == settings.unitMode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Menu("Interval") {
                ForEach(Interval.allCases, id: \.self) { iv in
                    Button {
                        settings.interval = iv
                        monitor.updateInterval(iv.rawValue)
                    } label: {
                        HStack {
                            Text("\(Int(iv.rawValue))s")
                            if iv == settings.interval {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Divider()

            Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                .onChange(of: settings.launchAtLogin) { newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        print("Failed to update login item: \(error)")
                    }
                }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .onAppear {
            monitor.start(interval: settings.interval.rawValue)
        }
    }
}
