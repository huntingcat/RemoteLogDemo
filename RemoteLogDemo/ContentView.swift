import SwiftUI

struct ContentView: View {
    @ObservedObject private var logManager = LogManager.shared
    @State private var lastTappedEvent: String = ""

    private let port = HTTPServer.shared.port
    private let ip = DeviceInfo.localIPAddress

    private let events: [(name: String, icon: String, detail: String)] = [
        ("app_launch",      "🚀", "应用启动事件"),
        ("button_tap",      "👆", "按钮点击事件"),
        ("page_view",       "📄", "页面浏览事件"),
        ("login_success",   "✅", "登录成功事件"),
        ("logout",          "🚪", "退出登录事件"),
        ("purchase",        "💳", "购买行为事件"),
        ("search",          "🔍", "搜索行为事件"),
        ("error_occur",     "❌", "错误触发事件"),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    serverInfoCard
                    eventButtonsSection
                    logStatusCard
                }
                .padding(16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("RemoteLog")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        logManager.clear()
                        lastTappedEvent = ""
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - 服务信息卡片
    private var serverInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("HTTP 服务器", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)
                .foregroundColor(.primary)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("浏览器访问地址")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("http://\(ip):\(port)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.accentColor)
                        .textSelection(.enabled)
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = "http://\(ip):\(port)"
                } label: {
                    Label("复制", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("服务运行中，手机和电脑请连接同一 WiFi")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - 事件按钮区
    private var eventButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("触发测试事件", systemImage: "hand.tap")
                .font(.headline)
                .foregroundColor(.primary)

            Divider()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(events, id: \.name) { event in
                    Button {
                        logManager.append(eventName: event.name, detail: event.detail)
                        lastTappedEvent = event.icon + " " + event.name
                    } label: {
                        HStack(spacing: 8) {
                            Text(event.icon)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.name)
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - 日志状态卡片
    private var logStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("日志状态", systemImage: "list.bullet.clipboard")
                .font(.headline)
                .foregroundColor(.primary)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("已记录日志")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(logManager.logs.count) / 200 条")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(logManager.logs.count > 180 ? .orange : .primary)
                }
                Spacer()
                if !lastTappedEvent.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("最近触发")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastTappedEvent)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.accentColor)
                    }
                }
            }

            if let latest = logManager.logs.last {
                Text("最新：\(latest.eventName)  \(shortTime(latest.timestamp))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func shortTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        let out = DateFormatter()
        out.dateFormat = "HH:mm:ss"
        return out.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
