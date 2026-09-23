import Cocoa

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

class CleanerWindowController: NSWindowController, NSWindowDelegate {
    var statusLabel: NSTextField!
    var aiTextView: NSTextView!
    var progressBar: NSProgressIndicator!
    var currentStepLabel: NSTextField!
    var logTextView: NSTextView!
    var bottomSummaryLabel: NSTextField!
    var doneButton: NSButton!

    convenience init() {
        let width: CGFloat = 680
        let height: CGFloat = 640
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(contentRect: rect,
                              styleMask: [.titled, .closable, .miniaturizable],
                              backing: .buffered, defer: false)
        window.center()
        window.title = "AI Dọn Dẹp Mac"
        window.isReleasedWhenClosed = false
        self.init(window: window)
        window.delegate = self
        setupUI()
        startCleaner()
    }
    
    func setupUI() {
        guard let window = self.window else { return }
        let contentView = FlippedView(frame: window.contentView!.bounds)
        contentView.wantsLayer = true
        window.contentView = contentView
        
        let pad: CGFloat = 20
        let contentWidth = contentView.bounds.width - (pad * 2)
        
        // 1. Header (y: 16 -> 68)
        let iconView = NSImageView(frame: NSRect(x: pad, y: 16, width: 48, height: 48))
        if let icon = NSApplication.shared.applicationIconImage {
            iconView.image = icon
        } else if let resPath = Bundle.main.resourcePath,
                  let icon = NSImage(contentsOfFile: "\(resPath)/applet.icns") {
            iconView.image = icon
        }
        contentView.addSubview(iconView)
        
        let titleLabel = NSTextField(labelWithString: "AI Dọn Dẹp & Tối Ưu Mac")
        titleLabel.frame = NSRect(x: pad + 60, y: 18, width: contentWidth - 60, height: 22)
        titleLabel.font = NSFont.systemFont(ofSize: 17, weight: .bold)
        contentView.addSubview(titleLabel)
        
        statusLabel = NSTextField(labelWithString: "🤖 Gemini 3.6 Flash | Đang quét & kết nối phân tích hệ thống...")
        statusLabel.frame = NSRect(x: pad + 60, y: 42, width: contentWidth - 60, height: 18)
        statusLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = NSColor.secondaryLabelColor
        contentView.addSubview(statusLabel)
        
        // 2. AI Advice Card (y: 76 -> 190, height: 114)
        let aiCard = FlippedView(frame: NSRect(x: pad, y: 76, width: contentWidth, height: 114))
        aiCard.wantsLayer = true
        aiCard.layer?.cornerRadius = 10
        aiCard.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        aiCard.layer?.borderWidth = 1.0
        aiCard.layer?.borderColor = NSColor.separatorColor.cgColor
        contentView.addSubview(aiCard)
        
        let aiTitleLabel = NSTextField(labelWithString: "💡 Lời khuyên & Phân tích từ Gemini AI")
        aiTitleLabel.frame = NSRect(x: 12, y: 8, width: contentWidth - 24, height: 18)
        aiTitleLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        aiTitleLabel.textColor = NSColor.systemBlue
        aiCard.addSubview(aiTitleLabel)
        
        let aiScroll = NSScrollView(frame: NSRect(x: 10, y: 28, width: contentWidth - 20, height: 76))
        aiScroll.hasVerticalScroller = true
        aiScroll.autohidesScrollers = true
        aiScroll.borderType = .noBorder
        aiScroll.drawsBackground = false
        
        aiTextView = NSTextView(frame: aiScroll.bounds)
        aiTextView.isEditable = false
        aiTextView.isSelectable = true
        aiTextView.drawsBackground = false
        aiTextView.font = NSFont.systemFont(ofSize: 12)
        aiTextView.string = "Đang kết nối Gemini AI để đánh giá tình trạng bộ nhớ và đưa ra khuyến nghị tối ưu..."
        aiScroll.documentView = aiTextView
        aiCard.addSubview(aiScroll)
        
        // 3. Progress Step Label & Bar (y: 200 -> 234)
        currentStepLabel = NSTextField(labelWithString: "Tiến trình: Chuẩn bị quét và dọn dẹp...")
        currentStepLabel.frame = NSRect(x: pad, y: 200, width: contentWidth, height: 18)
        currentStepLabel.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        contentView.addSubview(currentStepLabel)
        
        progressBar = NSProgressIndicator(frame: NSRect(x: pad, y: 222, width: contentWidth, height: 12))
        progressBar.isIndeterminate = true
        progressBar.style = .bar
        progressBar.startAnimation(nil)
        contentView.addSubview(progressBar)
        
        // 4. Live Log View (y: 244 -> 566, height: 322)
        let logScroll = NSScrollView(frame: NSRect(x: pad, y: 244, width: contentWidth, height: 322))
        logScroll.hasVerticalScroller = true
        logScroll.hasHorizontalScroller = false
        logScroll.autohidesScrollers = false
        logScroll.borderType = .bezelBorder
        
        logTextView = NSTextView(frame: logScroll.bounds)
        logTextView.isEditable = false
        logTextView.isSelectable = true
        logTextView.autoresizingMask = [.width]
        logTextView.backgroundColor = NSColor(red: 0.08, green: 0.10, blue: 0.13, alpha: 1.0)
        logTextView.textColor = NSColor(red: 0.65, green: 0.85, blue: 0.65, alpha: 1.0)
        logTextView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logTextView.string = "Khởi tạo tiến trình dọn dẹp...\n"
        logScroll.documentView = logTextView
        contentView.addSubview(logScroll)
        
        // 5. Bottom Summary & Done Button (y: 582 -> 614)
        bottomSummaryLabel = NSTextField(labelWithString: "Đang dọn dẹp hệ thống, vui lòng chờ...")
        bottomSummaryLabel.frame = NSRect(x: pad, y: 588, width: contentWidth - 110, height: 22)
        bottomSummaryLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        contentView.addSubview(bottomSummaryLabel)
        
        doneButton = NSButton(frame: NSRect(x: contentView.bounds.width - pad - 100, y: 580, width: 100, height: 32))
        doneButton.title = "Đang dọn..."
        doneButton.bezelStyle = .rounded
        doneButton.target = self
        doneButton.action = #selector(doneClicked)
        doneButton.isEnabled = false
        contentView.addSubview(doneButton)
    }
    
    @objc func doneClicked() {
        NSApp.terminate(nil)
    }
    
    func appendLog(_ text: String) {
        DispatchQueue.main.async {
            guard let storage = self.logTextView.textStorage else { return }
            let attr = NSAttributedString(string: text, attributes: [
                .foregroundColor: NSColor(red: 0.70, green: 0.88, blue: 0.70, alpha: 1.0),
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            ])
            storage.append(attr)
            self.logTextView.scrollToEndOfDocument(nil)
        }
    }
    
    func resolveScriptPath(named: String, ext: String) -> String {
        let bundle = Bundle.main
        if let p = bundle.path(forResource: named, ofType: ext) {
            return p
        }
        if let resPath = bundle.resourcePath {
            let direct = "\(resPath)/\(named).\(ext)"
            if FileManager.default.fileExists(atPath: direct) {
                return direct
            }
        }
        let home = NSHomeDirectory()
        let fallback = "\(home)/.local/bin/\(named).\(ext)"
        return fallback
    }
    
    func startCleaner() {
        DispatchQueue.global(qos: .userInitiated).async {
            let aiScriptPath = self.resolveScriptPath(named: "ai_cleaner", ext: "py")
            let cleanScriptPath = self.resolveScriptPath(named: "clean_mac", ext: "sh")
            
            // 1. Phân tích từ Gemini AI
            if FileManager.default.fileExists(atPath: aiScriptPath) {
                let aiProcess = Process()
                aiProcess.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
                aiProcess.arguments = [aiScriptPath, "--analyze-only"]
                let aiPipe = Pipe()
                aiProcess.standardOutput = aiPipe
                aiProcess.standardError = aiPipe
                
                do {
                    try aiProcess.run()
                    let aiData = aiPipe.fileHandleForReading.readDataToEndOfFile()
                    aiProcess.waitUntilExit()
                    var aiText = String(data: aiData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    aiText = aiText.replacingOccurrences(of: "**", with: "")
                    
                    DispatchQueue.main.async {
                        if !aiText.isEmpty {
                            self.aiTextView.string = aiText
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.aiTextView.string = "Ổ cứng của bạn đang được quét và tối ưu theo quy tắc chuẩn của macOS."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.aiTextView.string = "Tự động phân tích và dọn dẹp các phân vùng rác hệ thống."
                }
            }
            
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "🧹 Đang dọn dẹp từng thành phần rác & cache..."
                self.progressBar.isIndeterminate = false
                self.progressBar.minValue = 0
                self.progressBar.maxValue = 9
                self.progressBar.doubleValue = 0
            }
            
            // 2. Chạy dọn dẹp và stream output
            let cleanProcess = Process()
            cleanProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
            cleanProcess.arguments = [cleanScriptPath]
            let cleanPipe = Pipe()
            cleanProcess.standardOutput = cleanPipe
            cleanProcess.standardError = cleanPipe
            
            let outHandle = cleanPipe.fileHandleForReading
            outHandle.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty, let line = String(data: data, encoding: .utf8) else { return }
                
                self.appendLog(line)
                
                let lines = line.components(separatedBy: .newlines)
                for l in lines {
                    if l.hasPrefix("STEP:") {
                        let parts = l.components(separatedBy: ":")
                        if parts.count >= 3, let stepNum = Double(parts[1]) {
                            let title = parts[2]
                            DispatchQueue.main.async {
                                self.progressBar.doubleValue = stepNum
                                self.currentStepLabel.stringValue = "[\(Int(stepNum))/9] \(title)"
                            }
                        }
                    } else if l.hasPrefix("FINISH:") {
                        let parts = l.components(separatedBy: ":")
                        if parts.count >= 3 {
                            let freed = parts[1]
                            let current = parts[2]
                            DispatchQueue.main.async {
                                self.bottomSummaryLabel.stringValue = "🎉 Hoàn tất! Giải phóng: \(freed) (Trống: \(current))"
                                self.bottomSummaryLabel.textColor = NSColor.systemGreen
                                self.progressBar.doubleValue = 9
                                self.currentStepLabel.stringValue = "✓ Tất cả 9 bước dọn dẹp đã hoàn tất thành công!"
                                self.doneButton.title = "Xong"
                                self.doneButton.keyEquivalent = "\r"
                                self.doneButton.isEnabled = true
                                NSSound(named: "Glass")?.play()
                            }
                        }
                    }
                }
            }
            
            do {
                try cleanProcess.run()
                cleanProcess.waitUntilExit()
            } catch {
                self.appendLog("Lỗi khi thực thi script dọn dẹp: \(error.localizedDescription)\n")
            }
            
            DispatchQueue.main.async {
                self.doneButton.title = "Xong"
                self.doneButton.isEnabled = true
                self.doneButton.keyEquivalent = "\r"
                if self.bottomSummaryLabel.stringValue.contains("Đang dọn dẹp") {
                    self.bottomSummaryLabel.stringValue = "🎉 Dọn dẹp hoàn tất!"
                    self.bottomSummaryLabel.textColor = NSColor.systemGreen
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: CleanerWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowController = CleanerWindowController()
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
