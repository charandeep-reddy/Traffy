import Foundation

enum DisplayMode: String, CaseIterable {
    case split
    case combined
}

enum UnitMode: String, CaseIterable {
    case bytes
    case bits
}

enum Interval: TimeInterval, CaseIterable {
    case one = 1
    case two = 2
    case three = 3
}

final class Settings: ObservableObject {
    @Published var displayMode: DisplayMode {
        didSet { UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode") }
    }

    @Published var unitMode: UnitMode {
        didSet { UserDefaults.standard.set(unitMode.rawValue, forKey: "unitMode") }
    }

    @Published var interval: Interval {
        didSet { UserDefaults.standard.set(interval.rawValue, forKey: "interval") }
    }

    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    init() {
        let defaults = UserDefaults.standard
        displayMode = DisplayMode(rawValue: defaults.string(forKey: "displayMode") ?? "") ?? .split
        unitMode = UnitMode(rawValue: defaults.string(forKey: "unitMode") ?? "") ?? .bytes
        interval = Interval(rawValue: defaults.double(forKey: "interval")) ?? .one
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
    }
}
