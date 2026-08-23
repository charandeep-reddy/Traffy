import Foundation

enum SpeedFormatter {
    static let idleThreshold: Double = 1

    static func isIdle(_ bytesPerSecond: Double) -> Bool {
        bytesPerSecond < idleThreshold
    }

    static func string(for bytesPerSecond: Double, unit: UnitMode) -> String {
        if isIdle(bytesPerSecond) {
            return "--"
        }

        let value: Double
        let suffix: String

        switch unit {
        case .bytes:
            (value, suffix) = scale(bytesPerSecond, base: 1024, units: ["B/s", "KB/s", "MB/s", "GB/s"])
        case .bits:
            let bitsPerSecond = bytesPerSecond * 8
            (value, suffix) = scale(bitsPerSecond, base: 1000, units: ["b/s", "Kbps", "Mbps", "Gbps"])
        }

        return String(format: "%.1f %@", value, suffix)
    }

    private static func scale(_ value: Double, base: Double, units: [String]) -> (Double, String) {
        var v = value
        var idx = 0
        while v >= base && idx < units.count - 1 {
            v /= base
            idx += 1
        }
        return (v, units[idx])
    }
}
