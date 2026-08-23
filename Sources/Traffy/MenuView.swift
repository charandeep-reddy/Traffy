import SwiftUI
import ServiceManagement

struct MenuView: View {
    @ObservedObject var monitor: NetworkMonitor
    @ObservedObject var settings: Settings

    @State private var hostWindow: NSWindow?
    @State private var activeSection: Section?
    @Namespace private var glassNamespace

    private enum Section: Hashable, CaseIterable {
        case mode, unit, interval

        var title: String {
            switch self {
            case .mode: "Mode"
            case .unit: "Unit"
            case .interval: "Interval"
            }
        }
    }

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 0) {
                if let section = activeSection {
                    optionsPanel(for: section)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    mainPanel
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: activeSection)
        }
        .frame(width: 240)
        .background(WindowAccessor(window: $hostWindow))
        .onAppear {
            monitor.start(interval: settings.interval.rawValue)
        }
    }

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            speedHeader
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 8)

            VStack(spacing: 2) {
                sectionRow(.mode, valueLabel: settings.displayMode == .split ? "Split" : "Combined")
                sectionRow(.unit, valueLabel: settings.unitMode == .bytes ? "Bytes" : "Bits")
                sectionRow(.interval, valueLabel: "\(Int(settings.interval.rawValue))s")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)

            Divider()
                .padding(.horizontal, 8)

            VStack(spacing: 2) {
                toggleRow(title: "Launch at Login", isOn: $settings.launchAtLogin)
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

                toggleRow(title: "Hide Speed When Idle", isOn: $settings.hideSpeedWhenIdle)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)

            Divider()
                .padding(.horizontal, 8)

            MenuRow {
                NSApplication.shared.terminate(nil)
            } content: {
                HStack {
                    Text("Quit")
                    Spacer()
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 10)
            .keyboardShortcut("q")
        }
    }

    @ViewBuilder
    private func optionsPanel(for section: Section) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuRow {
                withAnimation {
                    activeSection = nil
                }
            } content: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.semibold))
                    Text(section.title)
                        .font(.system(.body, design: .default).weight(.semibold))
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 10)

            Divider()
                .padding(.horizontal, 8)
                .padding(.top, 8)

            VStack(spacing: 2) {
                switch section {
                case .mode:
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        optionRow(
                            title: mode == .split ? "Split" : "Combined",
                            isSelected: mode == settings.displayMode
                        ) {
                            settings.displayMode = mode
                            goBack()
                        }
                    }
                case .unit:
                    ForEach(UnitMode.allCases, id: \.self) { unit in
                        optionRow(
                            title: unit == .bytes ? "Bytes" : "Bits",
                            isSelected: unit == settings.unitMode
                        ) {
                            settings.unitMode = unit
                            goBack()
                        }
                    }
                case .interval:
                    ForEach(Interval.allCases, id: \.self) { iv in
                        optionRow(
                            title: "\(Int(iv.rawValue))s",
                            isSelected: iv == settings.interval
                        ) {
                            settings.interval = iv
                            monitor.updateInterval(iv.rawValue)
                            goBack()
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
    }

    private func goBack() {
        withAnimation {
            activeSection = nil
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

    private func sectionRow(_ section: Section, valueLabel: String) -> some View {
        MenuRow {
            withAnimation {
                activeSection = section
            }
        } content: {
            HStack {
                Text(section.title)
                Spacer()
                Text(valueLabel)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func optionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        MenuRow {
            action()
            hostWindow?.close()
        } content: {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        MenuRow {
            isOn.wrappedValue.toggle()
        } content: {
            HStack {
                Text(title)
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }
        }
    }
}

private struct MenuRow<Content: View>: View {
    @State private var isHovering = false
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.08) : .clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
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
