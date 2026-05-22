import Foundation

enum SpeedFormatter {
    static func string(for bytesPerSecond: Double, unit: UnitMode) -> String {
        let value: Double
        let suffix: String

        switch unit {
        case .bytes:
            (value, suffix) = scale(bytesPerSecond, base: 1024, units: ["B/s", "KB/s", "MB/s", "GB/s"])
        case .bits:
            let bitsPerSecond = bytesPerSecond * 8
            (value, suffix) = scale(bitsPerSecond, base: 1000, units: ["b/s", "Kbps", "Mbps", "Gbps"])
        }

        if value < 1 && (suffix == "B/s" || suffix == "b/s") {
            return "0.0 \(suffix)"
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
