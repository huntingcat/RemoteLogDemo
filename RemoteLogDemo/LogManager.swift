import Foundation

struct LogEntry: Codable, Identifiable {
    let id: String
    let timestamp: String
    let eventName: String
    let deviceModel: String
    let osVersion: String
    let detail: String

    init(eventName: String, detail: String = "") {
        self.id = UUID().uuidString
        self.timestamp = ISO8601DateFormatter().string(from: Date())
        self.eventName = eventName
        self.deviceModel = DeviceInfo.model
        self.osVersion = DeviceInfo.osVersion
        self.detail = detail
    }
}

final class LogManager: ObservableObject {
    static let shared = LogManager()

    private let maxCount = 200
    private let lock = NSLock()

    @Published private(set) var logs: [LogEntry] = []

    private init() {}

    func append(eventName: String, detail: String = "") {
        let entry = LogEntry(eventName: eventName, detail: detail)
        lock.lock()
        defer { lock.unlock() }
        var updated = logs
        updated.append(entry)
        if updated.count > maxCount {
            updated.removeFirst(updated.count - maxCount)
        }
        DispatchQueue.main.async {
            self.logs = updated
        }
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        DispatchQueue.main.async {
            self.logs = []
        }
    }

    func logsJSON() -> String {
        lock.lock()
        let snapshot = logs
        lock.unlock()
        guard let data = try? JSONEncoder().encode(snapshot),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }
}
