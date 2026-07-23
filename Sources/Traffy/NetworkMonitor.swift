import Foundation
import Darwin

struct NetworkSpeed {
    let upload: Double
    let download: Double
}

@MainActor
final class NetworkMonitor: ObservableObject {
    @Published var speed = NetworkSpeed(upload: 0, download: 0)

    private var previousBytes: (upload: UInt64, download: UInt64)?
    private var timer: Timer?
    private var interval: TimeInterval = 1

    func start(interval: TimeInterval) {
        self.interval = interval
        previousBytes = nil
        timer?.invalidate()
        let newTimer = Timer(timeInterval: interval, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
        tick()
    }

    func updateInterval(_ newInterval: TimeInterval) {
        interval = newInterval
        start(interval: newInterval)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let current = readBytes()

        guard let prev = previousBytes else {
            previousBytes = current
            return
        }

        let uploadDelta = current.upload >= prev.upload ? current.upload - prev.upload : 0
        let downloadDelta = current.download >= prev.download ? current.download - prev.download : 0

        previousBytes = current

        speed = NetworkSpeed(
            upload: Double(uploadDelta) / interval,
            download: Double(downloadDelta) / interval
        )
    }

    private func readBytes() -> (upload: UInt64, download: UInt64) {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0, let start = addresses else {
            return (0, 0)
        }
        defer { freeifaddrs(addresses) }

        var totalUpload: UInt64 = 0
        var totalDownload: UInt64 = 0

        var cursor: UnsafeMutablePointer<ifaddrs>? = start
        while let addr = cursor {
            defer { cursor = addr.pointee.ifa_next }

            let name = String(cString: addr.pointee.ifa_name)
            guard name != "lo0" else { continue }

            let flags = Int32(addr.pointee.ifa_flags)
            guard (flags & IFF_UP) != 0 else { continue }

            if let data = addr.pointee.ifa_data {
                let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                totalDownload += UInt64(networkData.ifi_ibytes)
                totalUpload += UInt64(networkData.ifi_obytes)
            }
        }

        return (totalUpload, totalDownload)
    }
}
