import SwiftUI
import ServiceManagement

struct MenuView: View {
    @ObservedObject var monitor: NetworkMonitor
    @ObservedObject var settings: Settings

    @State private var hostWindow: NSWindow?

    @State private var expandedSection: Section?

    private enum Section: Hashable {
        case mode, unit, interval
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            speedHeader
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                disclosureRow(
                    title: "Mode",
                    valueLabel: settings.displayMode == .split ? "Split" : "Combined",
                    section: .mode
                ) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        optionRow(
                            title: mode == .split ? "Split" : "Combined",
                            isSelected: mode == settings.displayMode
                        ) {
                            settings.displayMode = mode
                        }
                    }
                }

                disclosureRow(
                    title: "Unit",
                    valueLabel: settings.unitMode == .bytes ? "Bytes" : "Bits",
                    section: .unit
                ) {
                    ForEach(UnitMode.allCases, id: \.self) { unit in
                        optionRow(
                            title: unit == .bytes ? "Bytes" : "Bits",
                            isSelected: unit == settings.unitMode
                        ) {
                            settings.unitMode = unit
                        }
                    }
                }

                disclosureRow(
                    title: "Interval",
                    valueLabel: "\(Int(settings.interval.rawValue))s",
                    section: .interval
                ) {
                    ForEach(Interval.allCases, id: \.self) { iv in
                        optionRow(
                            title: "\(Int(iv.rawValue))s",
                            isSelected: iv == settings.interval
                        ) {
                            settings.interval = iv
                            monitor.updateInterval(iv.rawValue)
                        }
                    }
                }
            }
            .padding(.vertical, 4)

            Divider()

            Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                .toggleStyle(.checkbox)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
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

            Toggle("Hide Speed When Idle", isOn: $settings.hideSpeedWhenIdle)
                .toggleStyle(.checkbox)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q")
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .frame(width: 220)
        .background(.regularMaterial)
        .background(WindowAccessor(window: $hostWindow))
        .onAppear {
            monitor.start(interval: settings.interval.rawValue)
        }
    }

    private var speedHeader: some View {
        let uploadIdle = SpeedFormatter.isIdle(monitor.speed.upload)
        let downloadIdle = SpeedFormatter.isIdle(monitor.speed.download)

        return Group {
            if settings.displayMode == .split {
                HStack(spacing: 4) {
                    Text("↑ \(SpeedFormatter.string(for: monitor.speed.upload, unit: settings.unitMode))")
                        .foregroundStyle(uploadIdle ? .secondary : .primary)
                    Text("↓ \(SpeedFormatter.string(for: monitor.speed.download, unit: settings.unitMode))")
                        .foregroundStyle(downloadIdle ? .secondary : .primary)
                }
            } else {
                let up = monitor.speed.upload
                let down = monitor.speed.download
                HStack(spacing: 4) {
                    if up >= down {
                        Text("↑ \(SpeedFormatter.string(for: up, unit: settings.unitMode))")
                            .foregroundStyle(uploadIdle ? .secondary : .primary)
                    } else {
                        Text("↓ \(SpeedFormatter.string(for: down, unit: settings.unitMode))")
                            .foregroundStyle(downloadIdle ? .secondary : .primary)
                    }
                }
            }
        }
        .font(.system(.body, design: .monospaced))
    }

    @ViewBuilder
    private func disclosureRow<Content: View>(
        title: String,
        valueLabel: String,
        section: Section,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isExpanded = expandedSection == section

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    expandedSection = isExpanded ? nil : section
                }
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(valueLabel)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(.leading, 12)
            }
        }
    }

    private func optionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            expandedSection = nil
            hostWindow?.close()
        } label: {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

private struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            self.window = nsView.window
        }
    }
}
