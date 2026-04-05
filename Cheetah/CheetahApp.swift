//
//  CheetahApp.swift
//  Cheetah
//
//  Created by Shaarav on 29/3/2026.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem!
    let engine = CheetahEngine()
    lazy var settingsModel = CheetahSettingsModel(engine: engine)
    private var cancellables = Set<AnyCancellable>()
    private var lastDisplayedCPU = -1
    private var cpuLabelCharacterCount = 0
    private var lastFrameCommitTime = CFAbsoluteTimeGetCurrent()
    private let maxStatusRenderFPS = 60.0
    private let maxRenderedFrameCacheEntries = 192
    private var cachedRenderedFrames: [FrameRenderCacheKey: NSImage] = [:]
    private var cachedAppearanceIsDark: Bool?
    private let iconView = NSImageView()
    private let cpuLabel = NSTextField(labelWithString: "")
    private let memLabel = NSTextField(labelWithString: "")
    private let cpuIcon = NSImageView()
    private let memIcon = NSImageView()
    private let stackView = NSStackView()
    private var lastDisplayedMemory = -1
    private var iconWidthConstraint: NSLayoutConstraint?
    private var iconWidthLockedForRunner = false
    private let menuPopover = NSPopover()
    private var popoverMenuController: NSHostingController<CheetahMenuView>?
    private var pendingResizeWorkItem: DispatchWorkItem?
    private var eventMonitor: Any?
    var onboardingWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            setupStatusButtonContent(button)
            button.target = self
            button.action = #selector(toggleMenuPopover(_:))
            button.sendAction(on: [.leftMouseUp])
        }

        let popoverMenu = NSHostingController(
            rootView: CheetahMenuView(engine: engine) { [weak self] _ in
                self?.scheduleMenuPopupResize()
            }
        )
        popoverMenuController = popoverMenu
        menuPopover.contentViewController = popoverMenu
        menuPopover.behavior = .transient
        menuPopover.animates = false
        menuPopover.contentSize = NSSize(width: 360, height: 1)
        menuPopover.delegate = self

        // Delay one runloop so SwiftUI can finish layout before measuring fitting size.
        DispatchQueue.main.async { [weak self] in
            self?.updateMenuPopupSizeFromFittingSize()
        }
        
        if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            showOnboardingWindow()
        }
        
        engine.onFrameUpdate = { [weak self] image in
            guard let self else { return }
            let now = CFAbsoluteTimeGetCurrent()
            if now - self.lastFrameCommitTime < (1.0 / self.maxStatusRenderFPS) {
                return
            }
            self.lastFrameCommitTime = now

            guard let button = self.statusItem.button else { return }
            let resolvedImage = self.resolvedStatusImage(for: image, button: button)
            if self.iconView.image !== resolvedImage {
                self.iconView.image = resolvedImage

                if !self.iconWidthLockedForRunner {
                    self.iconWidthConstraint?.constant = max(resolvedImage.size.width, 8)
                    self.iconWidthLockedForRunner = true
                    self.updateStatusItemLength()
                }
            }
        }
            
        engine.$showCPUInMenuBar
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)

        engine.$showMemoryInMenuBar
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)

        engine.$selectedRunnerID
            .sink { [weak self] _ in
                guard let self else { return }
                self.cachedRenderedFrames.removeAll(keepingCapacity: true)
                self.iconWidthConstraint?.constant = 18
                self.iconWidthLockedForRunner = false
                self.updateStatusItemLength()
            }
            .store(in: &cancellables)
            
        engine.$cpuUsagePercentage
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)

        engine.$memoryUsagePercentage
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)
    }

    @objc
    private func toggleMenuPopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }

        if menuPopover.isShown {
            menuPopover.performClose(sender)
            return
        }

        updateMenuPopupSizeFromFittingSize()
        menuPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        menuPopover.contentViewController?.view.window?.makeKey()

        removeEventMonitor()
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.menuPopover.isShown else { return }
            self.menuPopover.performClose(event)
        }

        // Re-measure after opening so the popover window can settle with final animated content size.
        scheduleMenuPopupResize()
    }

    private func removeEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func popoverWillShow(_ notification: Notification) {
        engine.setDashboardVisible(true)
    }

    func popoverDidClose(_ notification: Notification) {
        removeEventMonitor()
        engine.setDashboardVisible(false)
    }

    private func showOnboardingWindow() {
        if onboardingWindow == nil {
            let hostingController = NSHostingController(rootView: OnboardingView(settings: settingsModel))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("Onboarding Window")
            window.contentView = hostingController.view
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.isReleasedWhenClosed = false
            onboardingWindow = window
        }
        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func scheduleMenuPopupResize() {
        pendingResizeWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateMenuPopupSizeFromFittingSize()
        }
        pendingResizeWorkItem = workItem
        DispatchQueue.main.async(execute: workItem)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [weak self] in
            self?.updateMenuPopupSizeFromFittingSize()
        }
    }

    private func updateMenuPopupSizeFromFittingSize() {
        guard let hostingView = popoverMenuController?.view else { return }
        hostingView.layoutSubtreeIfNeeded()
        let fittingSize = hostingView.fittingSize
        guard fittingSize.width > 0, fittingSize.height > 0 else { return }
        updateMenuPopupSize(for: fittingSize)
    }

    private func updateMenuPopupSize(for contentSize: CGSize) {
        guard contentSize.width > 0,
              contentSize.height > 0 else {
            return
        }

        let targetSize = NSSize(width: ceil(contentSize.width), height: ceil(contentSize.height))
        let currentSize = menuPopover.contentSize
        let deltaThreshold: CGFloat = 0.5

        guard abs(currentSize.width - targetSize.width) > deltaThreshold ||
                abs(currentSize.height - targetSize.height) > deltaThreshold else {
            return
        }

        menuPopover.contentSize = targetSize
        popoverMenuController?.view.window?.setContentSize(targetSize)
    }
    
    private func updateTitle() {
        let cpuText: String
        let cpuRounded = Int(engine.cpuUsagePercentage.rounded())
        if engine.showCPUInMenuBar {
            cpuText = "\(cpuRounded)%"
            lastDisplayedCPU = cpuRounded
        } else {
            cpuText = ""
            lastDisplayedCPU = -1
        }
        
        let memText: String
        let memRounded = Int(engine.memoryUsagePercentage.rounded())
        if engine.showMemoryInMenuBar {
            memText = "\(memRounded)%"
            lastDisplayedMemory = memRounded
        } else {
            memText = ""
            lastDisplayedMemory = -1
        }

        var lengthChanged = false
        
        if cpuLabel.stringValue != cpuText {
            cpuLabel.stringValue = cpuText
            let count = cpuText.isEmpty ? 0 : cpuText.count
            if count != cpuLabelCharacterCount {
                cpuLabelCharacterCount = count
                lengthChanged = true
            }
            let isHidden = cpuText.isEmpty
            if cpuLabel.isHidden != isHidden {
                cpuLabel.isHidden = isHidden
                cpuIcon.isHidden = isHidden
                lengthChanged = true
            }
        }
        
        if memLabel.stringValue != memText {
            memLabel.stringValue = memText
            let isHidden = memText.isEmpty
            if memLabel.isHidden != isHidden {
                memLabel.isHidden = isHidden
                memIcon.isHidden = isHidden
                lengthChanged = true
            }
        }
        
        if lengthChanged {
            updateStatusItemLength()
        }
    }

    private func setupStatusButtonContent(_ button: NSStatusBarButton) {
        button.image = nil
        button.title = ""
        button.imagePosition = .noImage

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 4
        stackView.edgeInsets = NSEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        
        iconView.imageScaling = .scaleNone
        iconView.imageAlignment = .alignCenter
        stackView.addArrangedSubview(iconView)
        
        let iconWidth = iconView.widthAnchor.constraint(equalToConstant: 18)
        iconWidthConstraint = iconWidth
        iconWidth.isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        let font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        
        stackView.setCustomSpacing(8, after: iconView)
        
        let cpuConfig = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        cpuIcon.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)?.withSymbolConfiguration(cpuConfig)
        cpuIcon.contentTintColor = .labelColor
        cpuLabel.font = font
        cpuLabel.textColor = .labelColor
        cpuLabel.alignment = .left
        cpuLabel.isHidden = true
        cpuIcon.isHidden = true
        stackView.addArrangedSubview(cpuIcon)
        stackView.addArrangedSubview(cpuLabel)
        stackView.setCustomSpacing(2, after: cpuIcon)
        stackView.setCustomSpacing(8, after: cpuLabel)
        
        let memConfig = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        memIcon.image = NSImage(systemSymbolName: "memorychip", accessibilityDescription: nil)?.withSymbolConfiguration(memConfig)
        memIcon.contentTintColor = .labelColor
        memLabel.font = font
        memLabel.textColor = .labelColor
        memLabel.alignment = .left
        memLabel.isHidden = true
        memIcon.isHidden = true
        stackView.addArrangedSubview(memIcon)
        stackView.addArrangedSubview(memLabel)
        stackView.setCustomSpacing(2, after: memIcon)

        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])

        updateStatusItemLength()
    }

    private func updateStatusItemLength() {
        stackView.layoutSubtreeIfNeeded()
        let totalWidth = stackView.fittingSize.width
        statusItem.length = max(totalWidth, 20)
    }

    private func resolvedStatusImage(for templateImage: NSImage, button: NSStatusBarButton) -> NSImage {
        let darkMode = button.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if cachedAppearanceIsDark != darkMode {
            cachedAppearanceIsDark = darkMode
            cachedRenderedFrames.removeAll(keepingCapacity: true)
        }
        let cacheKey = FrameRenderCacheKey(frameID: ObjectIdentifier(templateImage), darkMode: darkMode)

        if let cached = cachedRenderedFrames[cacheKey] {
            return cached
        }

        let tintColor: NSColor = darkMode ? .white : .black
        guard let rendered = renderedMenuBarImage(from: templateImage, tintColor: tintColor) else {
            return templateImage
        }

        if cachedRenderedFrames.count >= maxRenderedFrameCacheEntries {
            cachedRenderedFrames.removeAll(keepingCapacity: true)
        }
        cachedRenderedFrames[cacheKey] = rendered
        return rendered
    }

    private func renderedMenuBarImage(from source: NSImage, tintColor: NSColor) -> NSImage? {
        guard let sourceCGImage = source.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let width = sourceCGImage.width
        let height = sourceCGImage.height
        guard width > 0, height > 0 else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.setFillColor(tintColor.cgColor)
        context.fill(rect)

        // Use the frame alpha as a mask so the final bitmap is already menu-bar colored.   
        context.setBlendMode(.destinationIn)
        context.draw(sourceCGImage, in: rect)

        guard let tintedCGImage = context.makeImage() else {
            return nil
        }

        let image = NSImage(cgImage: tintedCGImage, size: source.size)
        image.isTemplate = false
        return image
    }
}

private struct FrameRenderCacheKey: Hashable {
    let frameID: ObjectIdentifier
    let darkMode: Bool
}

@main
struct CheetahApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            CheetahSettingsView(settings: appDelegate.settingsModel)
        }
    }
}
