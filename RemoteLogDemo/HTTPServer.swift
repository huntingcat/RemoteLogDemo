import Foundation
import Swifter

final class HTTPServer {
    static let shared = HTTPServer()
    let port: UInt16 = 8080

    private let server = HttpServer()
    private init() {}

    func start() {
        setupRoutes()
        do {
            try server.start(port, forceIPv4: true)
            print("[HTTPServer] 启动成功，端口 \(port)")
        } catch {
            print("[HTTPServer] 启动失败: \(error)")
        }
    }

    func stop() {
        server.stop()
    }

    private func setupRoutes() {
        server["/"] = { _ in
            guard let url = Bundle.main.url(forResource: "index", withExtension: "html"),
                  let html = try? String(contentsOf: url, encoding: .utf8) else {
                return .internalServerError
            }
            return HttpResponse.ok(.html(html))
        }

        server["/api/logs"] = { _ in
            let json = LogManager.shared.logsJSON()
            return HttpResponse.ok(.text(json))
        }

        server.DELETE["/api/logs"] = { _ in
            LogManager.shared.clear()
            return HttpResponse.ok(.text("{\"ok\":true}"))
        }
    }
}
