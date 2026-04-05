//
//  ContentView.swift
//  Cheetah
//
//  Created by Shaarav on 29/3/2026.
//

import AppKit
import Combine
import Darwin
import Foundation
import ServiceManagement
import SwiftUI

private enum CheetahDefaults {
    static let selectedRunner = "cheetah.selectedRunner"
    static let showCPUInMenuBar = "cheetah.showCPUInMenuBar"
    static let showMemoryInMenuBar = "cheetah.showMemoryInMenuBar"
    static let graphHistoryWindowSeconds = "cheetah.graphHistoryWindowSeconds"
    static let processRefreshCadenceSeconds = "cheetah.processRefreshCadenceSeconds"
    static let showCPUCard = "cheetah.showCPUCard"
    static let showMemoryCard = "cheetah.showMemoryCard"
    static let showCoresCard = "cheetah.showCoresCard"
    static let showSystemInfoCard = "cheetah.showSystemInfoCard"
    static let showHistoryCard = "cheetah.showHistoryCard"
    static let showProcessesCard = "cheetah.showProcessesCard"
    static let randomRunnerEnabled = "cheetah.randomRunnerEnabled"
    static let randomRunnerIntervalMinutes = "cheetah.randomRunnerIntervalMinutes"
    static let invertRunnerSpeedByCPU = "cheetah.invertRunnerSpeedByCPU"
}

enum GraphHistoryWindow: Int, CaseIterable, Identifiable {
    case seconds30 = 30
    case seconds60 = 60
    case seconds120 = 120

    var id: Int { rawValue }
    var seconds: Int { rawValue }
    var label: String { "\(rawValue)s" }
}

enum ProcessRefreshCadence: Double, CaseIterable, Identifiable {
    case oneSecond = 1
    case twoSeconds = 2
    case fiveSeconds = 5

    var id: Double { rawValue }
    var interval: TimeInterval { rawValue }

    var label: String {
        switch self {
        case .oneSecond:
            return "1s"
        case .twoSeconds:
            return "2s"
        case .fiveSeconds:
            return "5s"
        }
    }
}

struct RunnerOption: Identifiable {
    let id: String

    var displayName: String {
        id
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

enum MemoryPressureLevel {
    case normal
    case warning
    case critical

    var label: String {
        switch self {
        case .normal:
            return "Normal"
        case .warning:
            return "Warning"
        case .critical:
            return "Critical"
        }
    }
}

struct MemorySnapshot {
    let usedBytes: UInt64
    let freeBytes: UInt64
    let cachedBytes: UInt64
    let totalBytes: UInt64
    let pressure: MemoryPressureLevel

    var usedPercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return (Double(usedBytes) / Double(totalBytes)) * 100.0
    }

    static let empty = MemorySnapshot(
        usedBytes: 0,
        freeBytes: 0,
        cachedBytes: 0,
        totalBytes: 1,
        pressure: .normal
    )
}

struct ProcessResourceSample: Identifiable {
    let pid: Int32
    let name: String
    let cpuPercent: Double
    let memoryMB: Double
    let icon: NSImage?

    var id: Int32 { pid }
}

private struct CPUSnapshot {
    let totalUsage: Double
    let perCoreUsage: [Double]
}

private struct ProcessSampleRecord {
    let pid: Int32
    let cpuPercent: Double
    let rssKB: Double
    let command: String
}

@MainActor
final class CheetahSettingsModel: ObservableObject {
    let runnerOptions: [RunnerOption]

    @Published var selectedRunnerID: String
    @Published var showCPUInMenuBar: Bool
    @Published var showMemoryInMenuBar: Bool
    @Published var graphHistoryWindow: GraphHistoryWindow
    @Published var processRefreshCadence: ProcessRefreshCadence
    @Published var randomRunnerEnabled: Bool
    @Published var randomRunnerIntervalMinutes: Int
    @Published var invertRunnerSpeedByCPU: Bool
    @Published var showCPUCard: Bool
    @Published var showMemoryCard: Bool
    @Published var showCoresCard: Bool
    @Published var showSystemInfoCard: Bool
    @Published var showHistoryCard: Bool
    @Published var showProcessesCard: Bool

    private let engine: CheetahEngine
    private var cancellables = Set<AnyCancellable>()

    init(engine: CheetahEngine) {
        self.engine = engine
        runnerOptions = engine.runnerOptions
        selectedRunnerID = engine.selectedRunnerID
        showCPUInMenuBar = engine.showCPUInMenuBar
        showMemoryInMenuBar = engine.showMemoryInMenuBar
        graphHistoryWindow = engine.graphHistoryWindow
        processRefreshCadence = engine.processRefreshCadence
        randomRunnerEnabled = engine.randomRunnerEnabled
        randomRunnerIntervalMinutes = engine.randomRunnerIntervalMinutes
        invertRunnerSpeedByCPU = engine.invertRunnerSpeedByCPU
        showCPUCard = engine.showCPUCard
        showMemoryCard = engine.showMemoryCard
        showCoresCard = engine.showCoresCard
        showSystemInfoCard = engine.showSystemInfoCard
        showHistoryCard = engine.showHistoryCard
        showProcessesCard = engine.showProcessesCard

        $selectedRunnerID
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.selectedRunnerID != value {
                    self.engine.selectedRunnerID = value
                }
            }
            .store(in: &cancellables)

        $showCPUInMenuBar
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showCPUInMenuBar != value {
                    self.engine.showCPUInMenuBar = value
                }
            }
            .store(in: &cancellables)

        $showMemoryInMenuBar
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showMemoryInMenuBar != value {
                    self.engine.showMemoryInMenuBar = value
                }
            }
            .store(in: &cancellables)

        $graphHistoryWindow
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.graphHistoryWindow != value {
                    self.engine.graphHistoryWindow = value
                }
            }
            .store(in: &cancellables)

        $processRefreshCadence
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.processRefreshCadence != value {
                    self.engine.processRefreshCadence = value
                }
            }
            .store(in: &cancellables)

        $randomRunnerEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.randomRunnerEnabled != value {
                    self.engine.randomRunnerEnabled = value
                }
            }
            .store(in: &cancellables)

        $randomRunnerIntervalMinutes
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.randomRunnerIntervalMinutes != value {
                    self.engine.randomRunnerIntervalMinutes = value
                }
            }
            .store(in: &cancellables)

        $invertRunnerSpeedByCPU
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.invertRunnerSpeedByCPU != value {
                    self.engine.invertRunnerSpeedByCPU = value
                }
            }
            .store(in: &cancellables)

        $showCPUCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showCPUCard != value {
                    self.engine.showCPUCard = value
                }
            }
            .store(in: &cancellables)

        $showMemoryCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showMemoryCard != value {
                    self.engine.showMemoryCard = value
                }
            }
            .store(in: &cancellables)

        $showCoresCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showCoresCard != value {
                    self.engine.showCoresCard = value
                }
            }
            .store(in: &cancellables)

        $showSystemInfoCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showSystemInfoCard != value {
                    self.engine.showSystemInfoCard = value
                }
            }
            .store(in: &cancellables)

        $showHistoryCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showHistoryCard != value {
                    self.engine.showHistoryCard = value
                }
            }
            .store(in: &cancellables)

        $showProcessesCard
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.engine.showProcessesCard != value {
                    self.engine.showProcessesCard = value
                }
            }
            .store(in: &cancellables)

        engine.$selectedRunnerID
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.selectedRunnerID != value {
                    self.selectedRunnerID = value
                }
            }
            .store(in: &cancellables)

        engine.$showCPUInMenuBar
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showCPUInMenuBar != value {
                    self.showCPUInMenuBar = value
                }
            }
            .store(in: &cancellables)

        engine.$graphHistoryWindow
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.graphHistoryWindow != value {
                    self.graphHistoryWindow = value
                }
            }
            .store(in: &cancellables)

        engine.$processRefreshCadence
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.processRefreshCadence != value {
                    self.processRefreshCadence = value
                }
            }
            .store(in: &cancellables)

        engine.$randomRunnerEnabled
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.randomRunnerEnabled != value {
                    self.randomRunnerEnabled = value
                }
            }
            .store(in: &cancellables)

        engine.$randomRunnerIntervalMinutes
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.randomRunnerIntervalMinutes != value {
                    self.randomRunnerIntervalMinutes = value
                }
            }
            .store(in: &cancellables)

        engine.$invertRunnerSpeedByCPU
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.invertRunnerSpeedByCPU != value {
                    self.invertRunnerSpeedByCPU = value
                }
            }
            .store(in: &cancellables)

        engine.$showCPUCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showCPUCard != value {
                    self.showCPUCard = value
                }
            }
            .store(in: &cancellables)

        engine.$showMemoryCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showMemoryCard != value {
                    self.showMemoryCard = value
                }
            }
            .store(in: &cancellables)

        engine.$showCoresCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showCoresCard != value {
                    self.showCoresCard = value
                }
            }
            .store(in: &cancellables)

        engine.$showSystemInfoCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showSystemInfoCard != value {
                    self.showSystemInfoCard = value
                }
            }
            .store(in: &cancellables)

        engine.$showHistoryCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showHistoryCard != value {
                    self.showHistoryCard = value
                }
            }
            .store(in: &cancellables)

        engine.$showProcessesCard
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                if self.showProcessesCard != value {
                    self.showProcessesCard = value
                }
            }
            .store(in: &cancellables)
    }
}

@MainActor
final class CheetahEngine: ObservableObject {
    private struct ProcessMetadata {
        let name: String
        let icon: NSImage?
    }

    // Menu bar extras render in a 22pt working area; tune icon body size within that range.
    private static let menuBarFrameHeight: CGFloat = 18
    private static let fetchCounterSize = 5
    private static let backgroundMetricsInterval: TimeInterval = 2.5
    private static let dashboardMetricsInterval: TimeInterval = 1.0
    private static let dashboardDetailedMetricsInterval: TimeInterval = 2.0
    private static let dashboardMinimumProcessSampleInterval: TimeInterval = 5.0
    private static let historySamplingInterval: TimeInterval = 1.0
    private static let defaultAnimationInterval: TimeInterval = 0.20
    private static let maxFramesPerSecond = 40.0
    private static let topProcessLimit = 5

    @Published var selectedRunnerID: String {
        didSet {
            guard selectedRunnerID != oldValue else { return }
            UserDefaults.standard.set(selectedRunnerID, forKey: CheetahDefaults.selectedRunner)
            resetRunnerFrames()
        }
    }

    @Published var showCPUInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showCPUInMenuBar, forKey: CheetahDefaults.showCPUInMenuBar)
        }
    }

    @Published var showMemoryInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showMemoryInMenuBar, forKey: CheetahDefaults.showMemoryInMenuBar)
        }
    }

    @Published var graphHistoryWindow: GraphHistoryWindow {
        didSet {
            guard graphHistoryWindow != oldValue else { return }
            UserDefaults.standard.set(graphHistoryWindow.rawValue, forKey: CheetahDefaults.graphHistoryWindowSeconds)
            trimHistoryBuffers()
        }
    }

    @Published var processRefreshCadence: ProcessRefreshCadence {
        didSet {
            guard processRefreshCadence != oldValue else { return }
            UserDefaults.standard.set(processRefreshCadence.rawValue, forKey: CheetahDefaults.processRefreshCadenceSeconds)
            configureProcessTimer()
        }
    }

    @Published var randomRunnerEnabled: Bool {
        didSet {
            guard randomRunnerEnabled != oldValue else { return }
            UserDefaults.standard.set(randomRunnerEnabled, forKey: CheetahDefaults.randomRunnerEnabled)
            configureRandomRunnerTimer()
        }
    }

    @Published var randomRunnerIntervalMinutes: Int {
        didSet {
            let normalizedMinutes = max(randomRunnerIntervalMinutes, 1)
            if normalizedMinutes != randomRunnerIntervalMinutes {
                randomRunnerIntervalMinutes = normalizedMinutes
                return
            }
            guard randomRunnerIntervalMinutes != oldValue else { return }
            UserDefaults.standard.set(randomRunnerIntervalMinutes, forKey: CheetahDefaults.randomRunnerIntervalMinutes)
            configureRandomRunnerTimer()
        }
    }

    @Published var invertRunnerSpeedByCPU: Bool {
        didSet {
            guard invertRunnerSpeedByCPU != oldValue else { return }
            UserDefaults.standard.set(invertRunnerSpeedByCPU, forKey: CheetahDefaults.invertRunnerSpeedByCPU)
            updateAnimationInterval()
        }
    }

    @Published var showCPUCard: Bool = true { didSet { UserDefaults.standard.set(showCPUCard, forKey: CheetahDefaults.showCPUCard) } }
    @Published var showMemoryCard: Bool = true { didSet { UserDefaults.standard.set(showMemoryCard, forKey: CheetahDefaults.showMemoryCard) } }
    @Published var showCoresCard: Bool = true {
        didSet {
            guard showCoresCard != oldValue else { return }
            UserDefaults.standard.set(showCoresCard, forKey: CheetahDefaults.showCoresCard)
            configureDetailedMetricsTimer()
            if !showCoresCard {
                perCoreCPUUsage = []
            }
        }
    }
    @Published var showSystemInfoCard: Bool = true { didSet { UserDefaults.standard.set(showSystemInfoCard, forKey: CheetahDefaults.showSystemInfoCard) } }
    @Published var showHistoryCard: Bool = true { didSet { UserDefaults.standard.set(showHistoryCard, forKey: CheetahDefaults.showHistoryCard) } }
    @Published var showProcessesCard: Bool = true {
        didSet {
            guard showProcessesCard != oldValue else { return }
            UserDefaults.standard.set(showProcessesCard, forKey: CheetahDefaults.showProcessesCard)
            configureProcessTimer()
        }
    }

    @Published private(set) var cpuUsagePercentage: Double = 0
    @Published private(set) var perCoreCPUUsage: [Double] = []
    @Published private(set) var memorySnapshot: MemorySnapshot = .empty
    @Published private(set) var memoryUsagePercentage: Double = 0
    @Published private(set) var cpuHistory: [Double] = []
    @Published private(set) var memoryHistory: [Double] = []
    @Published private(set) var topCPUProcesses: [ProcessResourceSample] = []
    @Published private(set) var topMemoryProcesses: [ProcessResourceSample] = []
    @Published private(set) var hasAttemptedProcessSampling: Bool = false

    var onFrameUpdate: ((NSImage) -> Void)?

    private(set) var frameImage: NSImage {
        didSet {
            guard frameImage !== oldValue else { return }
            onFrameUpdate?(frameImage)
        }
    }

    let runnerOptions: [RunnerOption]

    private var animationTimer: DispatchSourceTimer?
    private var metricsTimer: DispatchSourceTimer?
    private var detailedMetricsTimer: DispatchSourceTimer?
    private var processTimer: DispatchSourceTimer?
    private var randomRunnerTimer: DispatchSourceTimer?
    private var isDashboardVisible = false
    private var frameIndex = 0
    private var frameCount = 1
    private var currentRunnerFrames: [NSImage] = []
    private var cpuSamples: [Double] = []
    private var cpuSampleSum = 0.0
    private var fetchCounter = CheetahEngine.fetchCounterSize
    private var currentMetricsInterval = CheetahEngine.backgroundMetricsInterval
    private var scheduledAnimationInterval = CheetahEngine.defaultAnimationInterval
    private var processMetadataCache: [Int32: ProcessMetadata] = [:]
    private let cpuSampler = CPUSampler()
    private let memorySampler = MemorySampler()
    private let processSampler = ProcessSampler()

    init() {
        runnerOptions = Self.supportedRunnerIDs.map(RunnerOption.init)

        let initialRunner = UserDefaults.standard.string(forKey: CheetahDefaults.selectedRunner)
        let fallbackRunner = "cheetah"
        let resolvedRunnerID: String
        if let initialRunner,
           Self.supportedRunnerIDs.contains(initialRunner) {
            resolvedRunnerID = initialRunner
        } else {
            resolvedRunnerID = fallbackRunner
        }
        selectedRunnerID = resolvedRunnerID

        if UserDefaults.standard.object(forKey: CheetahDefaults.showCPUInMenuBar) != nil {
            showCPUInMenuBar = UserDefaults.standard.bool(forKey: CheetahDefaults.showCPUInMenuBar)
        } else {
            showCPUInMenuBar = false
        }

        if UserDefaults.standard.object(forKey: CheetahDefaults.showMemoryInMenuBar) != nil {
            showMemoryInMenuBar = UserDefaults.standard.bool(forKey: CheetahDefaults.showMemoryInMenuBar)
        } else {
            showMemoryInMenuBar = false
        }

        if let storedWindow = UserDefaults.standard.object(forKey: CheetahDefaults.graphHistoryWindowSeconds) as? Int,
           let resolvedWindow = GraphHistoryWindow(rawValue: storedWindow) {
            graphHistoryWindow = resolvedWindow
        } else {
            graphHistoryWindow = .seconds60
        }

        if let storedCadence = UserDefaults.standard.object(forKey: CheetahDefaults.processRefreshCadenceSeconds) as? Double,
           let resolvedCadence = ProcessRefreshCadence(rawValue: storedCadence) {
            processRefreshCadence = resolvedCadence
        } else if let storedCadenceInt = UserDefaults.standard.object(forKey: CheetahDefaults.processRefreshCadenceSeconds) as? Int,
                  let resolvedCadence = ProcessRefreshCadence(rawValue: Double(storedCadenceInt)) {
            processRefreshCadence = resolvedCadence
        } else {
            processRefreshCadence = .twoSeconds
        }

        if UserDefaults.standard.object(forKey: CheetahDefaults.randomRunnerEnabled) != nil {
            randomRunnerEnabled = UserDefaults.standard.bool(forKey: CheetahDefaults.randomRunnerEnabled)
        } else {
            randomRunnerEnabled = false
        }

        if let storedRandomInterval = UserDefaults.standard.object(forKey: CheetahDefaults.randomRunnerIntervalMinutes) as? Int {
            randomRunnerIntervalMinutes = max(storedRandomInterval, 1)
        } else if let storedRandomIntervalDouble = UserDefaults.standard.object(forKey: CheetahDefaults.randomRunnerIntervalMinutes) as? Double {
            randomRunnerIntervalMinutes = max(Int(storedRandomIntervalDouble.rounded()), 1)
        } else if let storedLegacyRandomCadence = UserDefaults.standard.object(forKey: "cheetah.randomRunnerCadenceMinutes") as? Double {
            randomRunnerIntervalMinutes = max(Int(storedLegacyRandomCadence.rounded()), 1)
        } else if let storedLegacyRandomCadenceInt = UserDefaults.standard.object(forKey: "cheetah.randomRunnerCadenceMinutes") as? Int {
            randomRunnerIntervalMinutes = max(storedLegacyRandomCadenceInt, 1)
        } else {
            randomRunnerIntervalMinutes = 5
        }

        if UserDefaults.standard.object(forKey: CheetahDefaults.invertRunnerSpeedByCPU) != nil {
            invertRunnerSpeedByCPU = UserDefaults.standard.bool(forKey: CheetahDefaults.invertRunnerSpeedByCPU)
        } else {
            invertRunnerSpeedByCPU = false
        }

        frameImage = Self.templateImage(for: resolvedRunnerID, frameIndex: 0)
            ?? NSImage(systemSymbolName: "hare", accessibilityDescription: "Runner")
            ?? NSImage(size: NSSize(width: 18, height: 18))

        resetRunnerFrames()
        trimHistoryBuffers()
        start()
    }

    deinit {
        animationTimer?.cancel()
        metricsTimer?.cancel()
        detailedMetricsTimer?.cancel()
        processTimer?.cancel()
        randomRunnerTimer?.cancel()
    }

    private func start() {
        animationTimer = DispatchSource.makeTimerSource(queue: .main)
        animationTimer?.setEventHandler { [weak self] in
            self?.advanceFrame()
        }
        animationTimer?.schedule(
            deadline: .now(),
            repeating: Self.defaultAnimationInterval,
            leeway: .milliseconds(8)
        )
        animationTimer?.resume()

        configureMetricsTimer()
        configureDetailedMetricsTimer()
        configureProcessTimer()
        configureRandomRunnerTimer()
    }

    func setDashboardVisible(_ visible: Bool) {
        guard isDashboardVisible != visible else { return }
        isDashboardVisible = visible
        configureMetricsTimer()
        configureDetailedMetricsTimer()
        configureProcessTimer()
    }

    private func configureMetricsTimer() {
        let targetInterval = isDashboardVisible ? Self.dashboardMetricsInterval : Self.backgroundMetricsInterval
        guard metricsTimer == nil || abs(targetInterval - currentMetricsInterval) > 0.001 else {
            return
        }

        metricsTimer?.cancel()

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.setEventHandler { [weak self] in
            self?.sampleMetricsInBackground()
        }
        let leeway = DispatchTimeInterval.milliseconds(Int(max(targetInterval * 120.0, 100.0)))
        timer.schedule(deadline: .now(), repeating: targetInterval, leeway: leeway)
        timer.resume()

        metricsTimer = timer
        currentMetricsInterval = targetInterval
    }

    private func configureDetailedMetricsTimer() {
        detailedMetricsTimer?.cancel()
        detailedMetricsTimer = nil

        guard isDashboardVisible, showCoresCard else {
            if !perCoreCPUUsage.isEmpty {
                perCoreCPUUsage = []
            }
            cpuSampler.resetPerCoreBaseline()
            return
        }

        cpuSampler.resetPerCoreBaseline()
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        timer.setEventHandler { [weak self] in
            self?.sampleDetailedMetricsInBackground()
        }
        timer.schedule(deadline: .now(), repeating: Self.dashboardDetailedMetricsInterval, leeway: .milliseconds(200))
        timer.resume()
        detailedMetricsTimer = timer
    }

    private func configureProcessTimer() {
        processTimer?.cancel()
        processTimer = nil

        guard isDashboardVisible, showProcessesCard else {
            return
        }

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        timer.setEventHandler { [weak self] in
            self?.sampleProcessesInBackground()
        }

        let cadence = max(processRefreshCadence.interval, Self.dashboardMinimumProcessSampleInterval)
        let leeway = DispatchTimeInterval.milliseconds(Int(max(cadence * 100.0, 100.0)))
        timer.schedule(deadline: .now(), repeating: cadence, leeway: leeway)
        timer.resume()
        processTimer = timer
    }

    private func configureRandomRunnerTimer() {
        randomRunnerTimer?.cancel()
        randomRunnerTimer = nil

        guard randomRunnerEnabled else {
            return
        }

        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.setEventHandler { [weak self] in
            self?.switchToRandomRunner()
        }

        let cadence = TimeInterval(max(randomRunnerIntervalMinutes, 1) * 60)
        let leeway = DispatchTimeInterval.seconds(Int(max(cadence * 0.1, 1)))
        timer.schedule(deadline: .now() + cadence, repeating: cadence, leeway: leeway)
        timer.resume()
        randomRunnerTimer = timer
    }

    private func switchToRandomRunner() {
        let candidates = runnerOptions.map(\.id).filter { $0 != selectedRunnerID }
        guard let nextRunner = candidates.randomElement() else {
            return
        }
        selectedRunnerID = nextRunner
    }

    private func sampleMetricsInBackground() {
        let totalCPUUsage = cpuSampler.sampleTotalUsage()
        let sampledMemory = memorySampler.sampleMemory()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let clampedCPU = min(max(totalCPUUsage, 0), 100)

            self.cpuSamples.append(clampedCPU)
            self.cpuSampleSum += clampedCPU
            if self.cpuSamples.count > Self.fetchCounterSize {
                let overflowCount = self.cpuSamples.count - Self.fetchCounterSize
                let removedSum = self.cpuSamples.prefix(overflowCount).reduce(0, +)
                self.cpuSamples.removeFirst(overflowCount)
                self.cpuSampleSum -= removedSum
            }

            if !self.cpuSamples.isEmpty {
                self.cpuUsagePercentage = self.cpuSampleSum / Double(self.cpuSamples.count)
            }

            self.memorySnapshot = sampledMemory
            self.memoryUsagePercentage = min(max(sampledMemory.usedPercentage, 0), 100)

            if self.isDashboardVisible, self.showHistoryCard {
                self.appendHistorySample(cpu: clampedCPU, memory: self.memoryUsagePercentage)
            }

            self.fetchCounter += 1
            if self.fetchCounter < Self.fetchCounterSize {
                return
            }

            self.fetchCounter = 0
            self.updateAnimationInterval()
        }
    }

    private func sampleDetailedMetricsInBackground() {
        let sampledPerCore = cpuSampler.samplePerCoreUsage().map { min(max($0, 0), 100) }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.isDashboardVisible, self.showCoresCard else { return }
            if self.perCoreCPUUsage != sampledPerCore {
                self.perCoreCPUUsage = sampledPerCore
            }
        }
    }

    private func sampleProcessesInBackground() {
        let records = processSampler.sampleProcesses()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.updateProcessSamples(with: records)
        }
    }

    private func updateProcessSamples(with records: [ProcessSampleRecord]) {
        hasAttemptedProcessSampling = true
        guard !records.isEmpty else {
            topCPUProcesses = []
            topMemoryProcesses = []
            return
        }

        let validRecords = records.filter { $0.pid > 0 }
        guard !validRecords.isEmpty else {
            topCPUProcesses = []
            topMemoryProcesses = []
            return
        }

        let candidateLimit = max(Self.topProcessLimit * 4, 12)
        let topCPURecords = Array(validRecords.sorted { $0.cpuPercent > $1.cpuPercent }.prefix(candidateLimit))
        let topMemoryRecords = Array(validRecords.sorted { $0.rssKB > $1.rssKB }.prefix(candidateLimit))

        var candidateRecordsByPID: [Int32: ProcessSampleRecord] = [:]
        for record in topCPURecords + topMemoryRecords {
            if let existing = candidateRecordsByPID[record.pid],
               existing.cpuPercent >= record.cpuPercent,
               existing.rssKB >= record.rssKB {
                continue
            }
            candidateRecordsByPID[record.pid] = record
        }

        let candidatePIDs = Set(candidateRecordsByPID.keys)
        let missingMetadataPIDs = candidatePIDs.filter { processMetadataCache[$0] == nil }
        let runningAppsByPID: [Int32: NSRunningApplication]
        if missingMetadataPIDs.isEmpty {
            runningAppsByPID = [:]
        } else {
            let allRunningApps = NSWorkspace.shared.runningApplications
            runningAppsByPID = Dictionary(uniqueKeysWithValues: allRunningApps.compactMap { app in
                let pid = app.processIdentifier
                guard missingMetadataPIDs.contains(pid) else { return nil }
                return (pid, app)
            })
        }

        let sampleByPID: [Int32: ProcessResourceSample] = candidateRecordsByPID.reduce(into: [:]) { partialResult, entry in
            let record = entry.value
            let metadata = metadataForProcess(record: record, runningAppsByPID: runningAppsByPID)
            partialResult[record.pid] = ProcessResourceSample(
                pid: record.pid,
                name: metadata.name,
                cpuPercent: max(record.cpuPercent, 0),
                memoryMB: max(record.rssKB / 1024.0, 0),
                icon: metadata.icon
            )
        }

        processMetadataCache = processMetadataCache.filter { candidatePIDs.contains($0.key) }

        topCPUProcesses = orderedTopSamples(from: topCPURecords, sampleByPID: sampleByPID)
        topMemoryProcesses = orderedTopSamples(from: topMemoryRecords, sampleByPID: sampleByPID)
    }

    private func metadataForProcess(record: ProcessSampleRecord, runningAppsByPID: [Int32: NSRunningApplication]) -> ProcessMetadata {
        if let cached = processMetadataCache[record.pid] {
            return cached
        }

        let app = runningAppsByPID[record.pid]
        let metadata = ProcessMetadata(
            name: app?.localizedName ?? ProcessSampler.displayName(from: record.command),
            icon: app?.icon
        )
        processMetadataCache[record.pid] = metadata
        return metadata
    }

    private func orderedTopSamples(from records: [ProcessSampleRecord], sampleByPID: [Int32: ProcessResourceSample]) -> [ProcessResourceSample] {
        var seen = Set<Int32>()
        var result: [ProcessResourceSample] = []
        result.reserveCapacity(Self.topProcessLimit)

        for record in records {
            guard seen.insert(record.pid).inserted,
                  let sample = sampleByPID[record.pid] else {
                continue
            }
            result.append(sample)
            if result.count == Self.topProcessLimit {
                break
            }
        }

        return result
    }

    private func appendHistorySample(cpu: Double, memory: Double) {
        cpuHistory.append(cpu)
        memoryHistory.append(memory)
        trimHistoryBuffers()
    }

    private func trimHistoryBuffers() {
        let maxSamples = max(Int(Double(graphHistoryWindow.seconds) / Self.historySamplingInterval), 1)
        if cpuHistory.count > maxSamples {
            cpuHistory.removeFirst(cpuHistory.count - maxSamples)
        }
        if memoryHistory.count > maxSamples {
            memoryHistory.removeFirst(memoryHistory.count - maxSamples)
        }
    }

    private func updateAnimationInterval() {
        let interval = frameDurationForCurrentCPU()
        guard abs(interval - scheduledAnimationInterval) > 0.005 else {
            return
        }

        scheduledAnimationInterval = interval
        let leewayNanoseconds = max(Int((interval * 0.1) * 1_000_000_000), 1_000_000)
        animationTimer?.schedule(
            deadline: .now(),
            repeating: interval,
            leeway: .nanoseconds(leewayNanoseconds)
        )
    }

    private func resetRunnerFrames() {
        currentRunnerFrames = Self.cachedFrames(for: selectedRunnerID)
        frameCount = max(currentRunnerFrames.count, 1)
        frameIndex = 0
        updateFrameImage()
    }

    private func advanceFrame() {
        guard frameCount > 0 else { return }
        frameIndex = (frameIndex + 1) % frameCount
        updateFrameImage()
    }

    private func updateFrameImage() {
        if currentRunnerFrames.indices.contains(frameIndex) {
            let image = currentRunnerFrames[frameIndex]
            frameImage = image
        }
    }

    private static var runnerFramesCache: [String: [NSImage]] = [:]
    private static var runnerPreviewImageCache: [String: NSImage] = [:]

    private static func cachedFrames(for runnerID: String) -> [NSImage] {
        if let cached = runnerFramesCache[runnerID], !cached.isEmpty {
            return cached
        }

        // Clear old caches to save memory.
        runnerFramesCache.removeAll()

        var frames: [NSImage] = []
        var frameIndex = 0
        while frameIndex < 120 {
            let image = autoreleasepool {
                templateImage(for: runnerID, frameIndex: frameIndex)
            }
            guard let validImage = image else {
                break
            }
            frames.append(validImage)
            frameIndex += 1
        }

        if frames.isEmpty {
            frames = [
                NSImage(systemSymbolName: "hare", accessibilityDescription: "Runner")
                ?? NSImage(size: NSSize(width: 18, height: 18))
            ]
        }

        runnerFramesCache[runnerID] = frames
        return frames
    }

    private func frameDurationForCurrentCPU() -> TimeInterval {
        let load = min(max(cpuUsagePercentage, 0), 100)
        let drivingLoad = invertRunnerSpeedByCPU ? (100.0 - load) : load
        let normalizedLoad = min(max(drivingLoad / 100.0, 0), 1)
        // Keep the same peak FPS capability, but avoid rapidly ramping frame commits at moderate CPU levels.
        let speed = 1.0 + pow(normalizedLoad, 2.2) * 19.0
        let intervalMilliseconds = 500.0 / speed
        let minInterval = 1.0 / Self.maxFramesPerSecond
        return max(intervalMilliseconds / 1000.0, minInterval)
    }

    private static func frameName(for runnerID: String, frameIndex: Int) -> String {
        "\(runnerID)-page-\(frameIndex)_Normal"
    }

    private static func assetNameCandidates(for runnerID: String, frameIndex: Int) -> [String] {
        let frame = frameName(for: runnerID, frameIndex: frameIndex)
        return [
            "\(runnerID)/\(frame)",
            frame
        ]
    }

    private static func loadImage(for runnerID: String, frameIndex: Int) -> NSImage? {
        for candidate in assetNameCandidates(for: runnerID, frameIndex: frameIndex) {
            if let image = NSImage(named: NSImage.Name(candidate)) {
                return image
            }
        }
        return nil
    }

    static func previewImage(for runnerID: String) -> NSImage? {
        if let cached = runnerPreviewImageCache[runnerID] {
            return cached
        }

        guard let preview = templateImage(for: runnerID, frameIndex: 0) else {
            return nil
        }

        runnerPreviewImageCache[runnerID] = preview
        return preview
    }

    private static func templateImage(for runnerID: String, frameIndex: Int) -> NSImage? {
        guard let source = loadImage(for: runnerID, frameIndex: frameIndex) else {
            return nil
        }

        let pointSize = normalizedMenuBarSize(for: source.size)
        return pixelPerfectTemplateImage(from: source, pointSize: pointSize)
    }

    private static func pixelPerfectTemplateImage(from source: NSImage, pointSize: NSSize) -> NSImage {
        let image = NSImage(size: pointSize)
        let sourceRect = NSRect(origin: .zero, size: source.size)

        // Build only a 2x representation to keep memory and processing low while preserving menu bar sharpness.
        let scale = 2.0
        let pixelWidth = max(Int((pointSize.width * scale).rounded()), 1)
        let pixelHeight = max(Int((pointSize.height * scale).rounded()), 1)

        if let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelWidth,
            pixelsHigh: pixelHeight,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) {
            rep.size = pointSize

            NSGraphicsContext.saveGraphicsState()
            if let context = NSGraphicsContext(bitmapImageRep: rep) {
                NSGraphicsContext.current = context
                context.imageInterpolation = .none
                source.draw(in: NSRect(origin: .zero, size: pointSize), from: sourceRect, operation: .copy, fraction: 1.0)
                context.flushGraphics()
            }
            NSGraphicsContext.restoreGraphicsState()

            image.addRepresentation(rep)
        }

        image.size = pointSize
        image.isTemplate = true
        return image
    }

    private static func normalizedMenuBarSize(for sourceSize: NSSize) -> NSSize {
        guard sourceSize.height > 0 else {
            return NSSize(width: menuBarFrameHeight, height: menuBarFrameHeight)
        }

        let width = (sourceSize.width / sourceSize.height) * menuBarFrameHeight
        return NSSize(width: max(width, 8), height: menuBarFrameHeight)
    }

    private static let supportedRunnerIDs: [String] = [
        "bird", "bonfire", "butterfly", "cat", "cat-b", "cat-c", "cat-tail", "chameleon", "cheetah",
        "chicken", "city", "coffee", "cogwheel", "cradle", "dinosaur", "dog", "dogeza", "dolphin", "dots",
        "dragon", "drop", "earth", "engine", "entaku", "factory", "fishman", "flash-cat", "fox", "frog",
        "ghost", "golden-cat", "greyhound", "hamster-wheel", "hedgehog", "horse", "human", "jack-o-lantern",
        "maneki-neko", "metal-cluster-cat", "mochi", "mock-nyan-cat", "mouse", "octopus", "otter", "owl",
        "parrot", "party-people", "pendulum", "penguin", "penguin2", "pig", "pulse", "puppy", "push-up",
        "rabbit", "reactor", "reindeer-sleigh", "rocket", "rotating-sushi", "rubber-duck", "sausage",
        "self-made", "sheep", "sine-curve", "sit-up", "slime", "snowman", "sparkler", "squirrel",
        "steam-locomotive", "sushi", "tapioca-drink", "terrier", "triforce", "unlock", "welsh-corgi", "whale",
        "wind-chime"
    ]
}

struct CoreTopology {
    static let shared = CoreTopology()
    let eCores: Int
    
    init() {
        var size = 0
        sysctlbyname("hw.perflevel1.logicalcpu", nil, &size, nil, 0)
        if size > 0 {
            let pointer = malloc(size)
            sysctlbyname("hw.perflevel1.logicalcpu", pointer, &size, nil, 0)
            eCores = size == 4 ? Int(pointer!.assumingMemoryBound(to: Int32.self).pointee) : Int(pointer!.assumingMemoryBound(to: Int64.self).pointee)
            free(pointer)
        } else {
            eCores = 0
        }
    }
    
    func type(for index: Int) -> String {
        if eCores == 0 { return "Core" }
        return index < eCores ? "Efficiency" : "Performance"
    }
}

private final class CPUSampler {
    private typealias TickTuple = (UInt32, UInt32, UInt32, UInt32)

    private var previousTotalTicks: TickTuple?
    private var previousTotalUsage: Double = 0
    private var previousPerCoreTicks: [TickTuple]?
    private var previousPerCoreUsage: [Double] = []
    private let hostPort: host_t = mach_host_self()

    deinit {
        mach_port_deallocate(mach_task_self_, hostPort)
    }

    func sampleTotalUsage() -> Double {
        sampleTotalCPUUsage()
    }

    func samplePerCoreUsage() -> [Double] {
        samplePerCoreCPUUsage()
    }

    func resetPerCoreBaseline() {
        previousPerCoreTicks = nil
        previousPerCoreUsage = []
    }

    private func sampleTotalCPUUsage() -> Double {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        var hostInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(hostPort, HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return previousTotalUsage
        }

        let currentTicks: TickTuple = (
            hostInfo.cpu_ticks.0,
            hostInfo.cpu_ticks.1,
            hostInfo.cpu_ticks.2,
            hostInfo.cpu_ticks.3
        )

        defer { previousTotalTicks = currentTicks }

        guard let previousTotalTicks else {
            return 0
        }

        let userDelta = Self.deltaTicks(current: currentTicks.0, previous: previousTotalTicks.0)
        let systemDelta = Self.deltaTicks(current: currentTicks.1, previous: previousTotalTicks.1)
        let idleDelta = Self.deltaTicks(current: currentTicks.2, previous: previousTotalTicks.2)
        let niceDelta = Self.deltaTicks(current: currentTicks.3, previous: previousTotalTicks.3)

        let inUse = userDelta + systemDelta + niceDelta
        let total = inUse + idleDelta

        guard total > 0 else {
            return previousTotalUsage
        }

        let usage = (inUse / total) * 100.0
        previousTotalUsage = Swift.min(Swift.max(usage, 0.0), 100.0)
        return previousTotalUsage
    }

    private func samplePerCoreCPUUsage() -> [Double] {
        var processorCount: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(
            hostPort,
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &cpuInfo,
            &numCPUInfo
        )

        guard result == KERN_SUCCESS, let cpuInfo else {
            return previousPerCoreUsage
        }

        defer {
            let size = vm_size_t(Int(numCPUInfo) * MemoryLayout<integer_t>.stride)
            let address = vm_address_t(UInt(bitPattern: cpuInfo))
            vm_deallocate(mach_task_self_, address, size)
        }

        let buffer = UnsafeBufferPointer(start: cpuInfo, count: Int(numCPUInfo))
        let stride = Int(CPU_STATE_MAX)
        var currentCoreTicks: [TickTuple] = []
        currentCoreTicks.reserveCapacity(Int(processorCount))

        for coreIndex in 0..<Int(processorCount) {
            let base = coreIndex * stride
            guard base + 3 < buffer.count else { continue }

            currentCoreTicks.append((
                UInt32(buffer[base + Int(CPU_STATE_USER)]),
                UInt32(buffer[base + Int(CPU_STATE_SYSTEM)]),
                UInt32(buffer[base + Int(CPU_STATE_IDLE)]),
                UInt32(buffer[base + Int(CPU_STATE_NICE)])
            ))
        }

        defer { previousPerCoreTicks = currentCoreTicks }

        guard let previousPerCoreTicks,
              previousPerCoreTicks.count == currentCoreTicks.count else {
            previousPerCoreUsage = Array(repeating: 0, count: currentCoreTicks.count)
            return previousPerCoreUsage
        }

        var usageByCore: [Double] = []
        usageByCore.reserveCapacity(currentCoreTicks.count)

        for index in currentCoreTicks.indices {
            let current = currentCoreTicks[index]
            let previous = previousPerCoreTicks[index]

            let userDelta = Self.deltaTicks(current: current.0, previous: previous.0)
            let systemDelta = Self.deltaTicks(current: current.1, previous: previous.1)
            let idleDelta = Self.deltaTicks(current: current.2, previous: previous.2)
            let niceDelta = Self.deltaTicks(current: current.3, previous: previous.3)

            let inUse = userDelta + systemDelta + niceDelta
            let total = inUse + idleDelta
            guard total > 0 else {
                usageByCore.append(0)
                continue
            }

            let usage = (inUse / total) * 100.0
            usageByCore.append(Swift.min(Swift.max(usage, 0.0), 100.0))
        }

        previousPerCoreUsage = usageByCore
        return usageByCore
    }

    private static func deltaTicks(current: UInt32, previous: UInt32) -> Double {
        if current >= previous {
            return Double(current - previous)
        }

        let wrapped = UInt64(current) + (UInt64(UInt32.max) - UInt64(previous)) + 1
        return Double(wrapped)
    }
}

private final class MemorySampler {
    private let hostPort: host_t = mach_host_self()
    private var pageSize: vm_size_t = 4096
    private var previousSnapshot = MemorySnapshot.empty

    init() {
        host_page_size(hostPort, &pageSize)
    }

    deinit {
        mach_port_deallocate(mach_task_self_, hostPort)
    }

    func sampleMemory() -> MemorySnapshot {
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        var stats = vm_statistics64()

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return previousSnapshot
        }

        let total = ProcessInfo.processInfo.physicalMemory
        let page = UInt64(pageSize)
        let free = UInt64(stats.free_count) * page
        let active = UInt64(stats.active_count) * page
        let inactive = UInt64(stats.inactive_count) * page
        let wired = UInt64(stats.wire_count) * page
        let compressed = UInt64(stats.compressor_page_count) * page
        let speculative = UInt64(stats.speculative_count) * page

        let cached = inactive + speculative
        let used = min(active + wired + compressed, total)
        let usedRatio = total > 0 ? Double(used) / Double(total) : 0

        let pressure: MemoryPressureLevel
        switch usedRatio {
        case ..<0.70:
            pressure = .normal
        case ..<0.85:
            pressure = .warning
        default:
            pressure = .critical
        }

        let snapshot = MemorySnapshot(
            usedBytes: used,
            freeBytes: min(free, total),
            cachedBytes: min(cached, total),
            totalBytes: max(total, 1),
            pressure: pressure
        )

        previousSnapshot = snapshot
        return snapshot
    }
}

private final class ProcessSampler {
    func sampleProcesses() -> [ProcessSampleRecord] {
        // Use comm to avoid large command-line payload parsing on every sample tick.
        runPS(arguments: ["-axo", "pid=,%cpu=,rss=,comm="])
    }

    private func runPS(arguments: [String]) -> [ProcessSampleRecord] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = arguments

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
        } catch {
            return []
        }

        // Read before waiting so large ps output cannot block on pipe capacity.
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        guard task.terminationStatus == 0 else {
            return []
        }

        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }

        return output
            .split(whereSeparator: \.isNewline)
            .compactMap { Self.parseProcessLine($0) }
    }

    private static func parseDouble(_ value: Substring) -> Double? {
        if let parsed = Double(value) {
            return parsed
        }

        let normalized = String(value).replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    static func displayName(from command: String) -> String {
        let pathComponent = URL(fileURLWithPath: command).lastPathComponent
        if !pathComponent.isEmpty {
            return pathComponent
        }
        return command
    }

    private static func parseProcessLine(_ line: Substring) -> ProcessSampleRecord? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let fields = trimmed.split(maxSplits: 3, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace })
        guard fields.count == 4,
              let pid = Int32(fields[0]),
              let cpu = parseDouble(fields[1]),
              let rssKB = parseDouble(fields[2]) else {
            return nil
        }

        return ProcessSampleRecord(
            pid: pid,
            cpuPercent: cpu,
            rssKB: rssKB,
            command: String(fields[3])
        )
    }
}

struct DashboardCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CheetahMenuView: View {
    @ObservedObject var engine: CheetahEngine
    let onContentSizeChange: (CGSize) -> Void

    @State private var lastReportedContentSize: CGSize = .zero
    @State private var hoveredCoreIndex: Int?

    init(engine: CheetahEngine, onContentSizeChange: @escaping (CGSize) -> Void = { _ in }) {
        _engine = ObservedObject(wrappedValue: engine)
        self.onContentSizeChange = onContentSizeChange
    }

    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    var body: some View {
        VStack(spacing: 12) {
            headerView
            
            if engine.showCPUCard || engine.showMemoryCard {
                HStack(spacing: 12) {
                    if engine.showCPUCard { cpuCard }
                    if engine.showMemoryCard { memoryCard }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            
            if engine.showCoresCard || engine.showSystemInfoCard {
                HStack(spacing: 12) {
                    if engine.showCoresCard { coreMatrixCard }
                    if engine.showSystemInfoCard { systemInfoCard }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            
            if engine.showHistoryCard {
                historyGraphsCard
            }
            if engine.showProcessesCard {
                topProcessesCard
            }
        }
        .padding(16)
        .frame(width: 420)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: MenuContentSizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(MenuContentSizePreferenceKey.self) { size in
            reportContentSizeIfNeeded(size)
        }
        .onAppear {
            onContentSizeChange(lastReportedContentSize)
        }
        .onChange(of: engine.perCoreCPUUsage.count) { _, _ in
            onContentSizeChange(lastReportedContentSize)
        }
        .onChange(of: engine.topCPUProcesses.count) { _, _ in
            onContentSizeChange(lastReportedContentSize)
        }
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            Text("Cheetah")
                .font(.system(size: 16, weight: .bold))
            Spacer()
            SettingsLink {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                NSApp.activate(ignoringOtherApps: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for window in NSApp.windows where window.title == "Cheetah Settings" || window.title == "Settings" || window.title == "Preferences" {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            })
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 4)
    }

    private var cpuCard: some View {
        DashboardCard(title: "CPU Load") {
            VStack(alignment: .leading, spacing: 2) {
                Text(oneDecimalPercent(engine.cpuUsagePercentage))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.15))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.blue)
                            .frame(width: max(0, geo.size.width * CGFloat(engine.cpuUsagePercentage / 100.0)))
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var memoryCard: some View {
        DashboardCard(title: "System Memory") {
            VStack(alignment: .leading, spacing: 2) {
                Text(oneDecimalPercent(engine.memoryUsagePercentage))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.15))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.green)
                            .frame(width: max(0, geo.size.width * CGFloat(engine.memoryUsagePercentage / 100.0)))
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var coreMatrixCard: some View {
        DashboardCard(title: "CPU Cores") {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 4) {
                    if engine.perCoreCPUUsage.isEmpty {
                        Text("...").font(.caption).foregroundColor(.secondary)
                    } else {
                        ForEach(engine.perCoreCPUUsage.indices, id: \.self) { index in
                            let usage = engine.perCoreCPUUsage[index]
                            GeometryReader { geo in
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.blue.opacity(0.15))
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.blue.opacity(0.8))
                                        .frame(height: max(2, geo.size.height * CGFloat(usage / 100.0)))
                                }
                                .contentShape(Rectangle())
                                .onHover { isHovered in
                                    if isHovered {
                                        hoveredCoreIndex = index
                                    } else if hoveredCoreIndex == index {
                                        hoveredCoreIndex = nil
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 38)
                
                if let idx = hoveredCoreIndex, idx < engine.perCoreCPUUsage.count {
                    Text("Core \(idx + 1) (\(CoreTopology.shared.type(for: idx))): \(Int(engine.perCoreCPUUsage[idx]))%")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(NSColor.windowBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(Color.secondary.opacity(0.35), lineWidth: 0.8)
                        )
                        .offset(y: -18)
                }
            }
        }
    }

    private var systemInfoCard: some View {
        DashboardCard(title: "System Info") {
            VStack(spacing: 6) {
                HStack {
                    Text("Uptime")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(uptimeString)
                        .font(.system(size: 12, weight: .semibold))
                }
                HStack {
                    Text("Pressure")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(engine.memorySnapshot.pressure.label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(pressureColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(pressureColor.opacity(0.15))
                        .cornerRadius(4)
                }
            }
            .frame(minHeight: 36)
        }
    }

    private var historyGraphsCard: some View {
        DashboardCard(title: "Usage History") {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text("CPU")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 32, alignment: .leading)
                    SparklineGraph(values: engine.cpuHistory, strokeColor: .blue, maxValue: 100)
                        .frame(height: 24)
                }
                HStack(spacing: 8) {
                    Text("MEM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                        .frame(width: 32, alignment: .leading)
                    SparklineGraph(values: engine.memoryHistory, strokeColor: .green, maxValue: 100)
                        .frame(height: 24)
                }
            }
        }
    }

    private var topProcessesCard: some View {
        DashboardCard(title: "Top Consumers") {
            VStack(spacing: 8) {
                HStack {
                    Text("PROC")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("CPU")
                        .frame(width: 45, alignment: .trailing)
                    Text("MEM")
                        .frame(width: 45, alignment: .trailing)
                }
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.bottom, -2)
                
                let samples = topProcesses
                if samples.isEmpty {
                    Text(engine.hasAttemptedProcessSampling ? "No process data" : "Initializing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                } else {
                    ForEach(samples) { sample in
                        HStack(spacing: 8) {
                            if let icon = sample.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            } else {
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.secondary.opacity(0.3))
                            }
                            Text(sample.name)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(String(format: "%.1f%%", sample.cpuPercent))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 45, alignment: .trailing)
                            
                            Text("\(Int(sample.memoryMB))M")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 45, alignment: .trailing)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    private var topProcesses: [ProcessResourceSample] {
        var mergedByPID: [Int32: ProcessResourceSample] = [:]
        for sample in engine.topCPUProcesses + engine.topMemoryProcesses {
            if let existing = mergedByPID[sample.pid] {
                mergedByPID[sample.pid] = ProcessResourceSample(
                    pid: sample.pid,
                    name: existing.name,
                    cpuPercent: max(existing.cpuPercent, sample.cpuPercent),
                    memoryMB: max(existing.memoryMB, sample.memoryMB),
                    icon: existing.icon ?? sample.icon
                )
            } else {
                mergedByPID[sample.pid] = sample
            }
        }

        return mergedByPID.values
            .sorted { lhs, rhs in
                if lhs.cpuPercent != rhs.cpuPercent {
                    return lhs.cpuPercent > rhs.cpuPercent
                }
                return lhs.memoryMB > rhs.memoryMB
            }
            .prefix(5)
            .map { $0 }
    }

    private var uptimeString: String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    private var pressureColor: Color {
        switch engine.memorySnapshot.pressure {
        case .normal: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }

    private func formattedBytes(_ bytes: UInt64) -> String {
        byteFormatter.string(fromByteCount: Int64(bytes))
    }

    private func oneDecimalPercent(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1))))%"
    }

    private func reportContentSizeIfNeeded(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        let normalizedSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        let deltaThreshold: CGFloat = 0.5
        guard abs(normalizedSize.width - lastReportedContentSize.width) > deltaThreshold ||
                abs(normalizedSize.height - lastReportedContentSize.height) > deltaThreshold else {
            return
        }

        lastReportedContentSize = normalizedSize
        onContentSizeChange(normalizedSize)
    }
}

private struct MenuContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct MetricSection<Content: View>: View {
    let title: String
    let value: String
    let subtitle: String?
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Text(value)
                        .font(.system(.body, design: .monospaced))

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

private struct SparklineGraph: View {
    let values: [Double]
    let strokeColor: Color
    let maxValue: Double
    @State private var hoveredIndex: Int?

    var body: some View {
        GeometryReader { proxy in
            let points = plottedPoints(in: proxy.size)

            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(NSColor.textBackgroundColor))

                fillPath(points: points, in: proxy.size)
                    .fill(strokeColor.opacity(0.18))

                linePath(points: points)
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

                if let hoveredIndex,
                   hoveredIndex >= 0,
                   hoveredIndex < points.count {
                    let point = points[hoveredIndex]
                    let value = resolvedValues[hoveredIndex]

                    Path { path in
                        path.move(to: CGPoint(x: point.x, y: 0))
                        path.addLine(to: CGPoint(x: point.x, y: proxy.size.height))
                    }
                    .stroke(strokeColor.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                    Circle()
                        .fill(strokeColor)
                        .frame(width: 6, height: 6)
                        .position(point)

                    let secondsAgo = resolvedValues.count - 1 - hoveredIndex
                    let timeStr = secondsAgo == 0 ? "Now" : "-\(secondsAgo)s"

                    Text("\(value.formatted(.number.precision(.fractionLength(1))))% (\(timeStr))")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(NSColor.windowBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(strokeColor.opacity(0.35), lineWidth: 0.8)
                        )
                        .position(
                            x: min(max(point.x, 36), proxy.size.width - 36),
                            y: 8
                        )
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case let .active(location):
                    hoveredIndex = nearestIndex(for: location.x, width: proxy.size.width)
                case .ended:
                    hoveredIndex = nil
                }
            }
        }
        .frame(height: 34)
    }

    private var resolvedValues: [Double] {
        values.isEmpty ? [0, 0] : values
    }

    private func nearestIndex(for x: CGFloat, width: CGFloat) -> Int {
        guard !resolvedValues.isEmpty else { return 0 }
        guard resolvedValues.count > 1 else { return 0 }

        let clampedX = min(max(x, 0), width)
        let ratio = width > 0 ? clampedX / width : 0
        let rawIndex = Int((ratio * CGFloat(resolvedValues.count - 1)).rounded())
        return min(max(rawIndex, 0), resolvedValues.count - 1)
    }

    private func linePath(points: [CGPoint]) -> Path {
        guard let first = points.first else { return Path() }

        var path = Path()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }

    private func fillPath(points: [CGPoint], in size: CGSize) -> Path {
        guard let first = points.first, let last = points.last else { return Path() }

        var path = Path()
        path.move(to: CGPoint(x: first.x, y: size.height))
        path.addLine(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.addLine(to: CGPoint(x: last.x, y: size.height))
        path.closeSubpath()
        return path
    }

    private func plottedPoints(in size: CGSize) -> [CGPoint] {
        let denominator = max(maxValue, 1)
        let step = resolvedValues.count > 1 ? size.width / CGFloat(resolvedValues.count - 1) : 0

        return resolvedValues.enumerated().map { index, value in
            let clamped = min(max(value, 0), denominator)
            let x = CGFloat(index) * step
            let y = size.height - (CGFloat(clamped) / CGFloat(denominator)) * size.height
            return CGPoint(x: x, y: y)
        }
    }
}

private struct ProcessRowView: View {
    let sample: ProcessResourceSample

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if let icon = sample.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .interpolation(.high)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 14, height: 14)

            Text(sample.name)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text("\(sample.cpuPercent, specifier: "%.1f")%")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(width: 52, alignment: .trailing)

            Text("\(sample.memoryMB.formatted(.number.precision(.fractionLength(0)))) MB")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 72, alignment: .trailing)
        }
        .font(.caption)
    }
}

struct CheetahSettingsView: View {
    @ObservedObject var settings: CheetahSettingsModel

    var body: some View {
        TabView {
            GeneralSettingsView(settings: settings)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            RunnerSettingsView(settings: settings)
                .tabItem {
                    Label("Runner", systemImage: "hare")
                }
            
            DashboardSettingsView(settings: settings)
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 480, height: 400)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows where window.title == "Cheetah Settings" || window.title == "Settings" || window.title == "Preferences" {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var settings: CheetahSettingsModel
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "macwindow")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                            .font(.system(size: 13, weight: .medium))
                        Text("Start Cheetah automatically when you log in.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                print("Failed to toggle Launch at Login: \(error.localizedDescription)")
                            }
                        }
                }
                .padding(.vertical, 4)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "cpu")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Menu Bar CPU")
                            .font(.system(size: 13, weight: .medium))
                        Text("Display CPU usage percentage in the menu bar.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showCPUInMenuBar)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "memorychip")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Menu Bar Memory")
                            .font(.system(size: 13, weight: .medium))
                        Text("Display memory usage percentage in the menu bar.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showMemoryInMenuBar)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
            } header: {
                Text("Startup & Menu Bar")
            }
            
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Graph History Window")
                            .font(.system(size: 13, weight: .medium))
                        Text("Set the time span shown on history line charts.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Picker("", selection: $settings.graphHistoryWindow) {
                        ForEach(GraphHistoryWindow.allCases) { window in
                            Text(window.label).tag(window)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: 150)
                }
                .padding(.vertical, 4)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Process Refresh Cadence")
                            .font(.system(size: 13, weight: .medium))
                        Text("Define how frequently top consumers are refreshed.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Picker("", selection: $settings.processRefreshCadence) {
                        ForEach(ProcessRefreshCadence.allCases) { cadence in
                            Text(cadence.label).tag(cadence)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: 150)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "shuffle")
                            .foregroundColor(.accentColor)
                            .frame(width: 16, alignment: .center)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Randomly Change Runner")
                                .font(.system(size: 13, weight: .medium))
                            Text("Automatically switch to a different runner at a fixed interval.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 16)
                        Toggle("", isOn: $settings.randomRunnerEnabled)
                            .labelsHidden()
                    }
                    
                    if settings.randomRunnerEnabled {
                        HStack(spacing: 8) {
                            Text("Every")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Stepper(value: $settings.randomRunnerIntervalMinutes, in: 1...120) {
                                Text("\(settings.randomRunnerIntervalMinutes) min")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .padding(.top, 6)
                            }
                            .frame(maxWidth: 140)
                        }
                        .padding(.leading, 28)
                    }
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "speedometer")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Invert Runner Speed")
                            .font(.system(size: 13, weight: .medium))
                        Text("Run faster on low CPU load and slower when CPU load is high.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.invertRunnerSpeedByCPU)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
            } header: {
                Text("Behavior")
            }
        }
        .formStyle(.grouped)
    }
}

struct DashboardSettingsView: View {
    @ObservedObject var settings: CheetahSettingsModel
    
    var body: some View {
        Form {
            Section(header: Text("Visible Dashboard Cards")) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "cpu")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CPU Load")
                            .font(.system(size: 13, weight: .medium))
                        Text("Show overall usage and system load average.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showCPUCard).labelsHidden()
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "memorychip")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("System Memory")
                            .font(.system(size: 13, weight: .medium))
                        Text("Monitor RAM utilization and memory pressure.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showMemoryCard).labelsHidden()
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CPU Cores")
                            .font(.system(size: 13, weight: .medium))
                        Text("Track individual utilization of all CPU cores.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showCoresCard).labelsHidden()
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("System Info")
                            .font(.system(size: 13, weight: .medium))
                        Text("Display host name, processor, and system uptime.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showSystemInfoCard).labelsHidden()
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "clock")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Usage History")
                            .font(.system(size: 13, weight: .medium))
                        Text("Graph CPU and Memory over a span of time.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showHistoryCard).labelsHidden()
                }
                .padding(.vertical, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.accentColor)
                        .frame(width: 16, alignment: .center)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Top Consumers")
                            .font(.system(size: 13, weight: .medium))
                        Text("List the largest memory and CPU process offenders.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Toggle("", isOn: $settings.showProcessesCard).labelsHidden()
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 80, height: 80)
            
            Text("Cheetah")
                .font(.largeTitle).bold()
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("Version \(version)")
                    .foregroundColor(.secondary)
            }
            
            Button("Quit Cheetah") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RunnerSettingsView: View {
    @ObservedObject var settings: CheetahSettingsModel
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]
    
    var filteredOptions: [RunnerOption] {
        if searchText.isEmpty {
            return settings.runnerOptions
        } else {
            return settings.runnerOptions.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search runners...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
            .padding()
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredOptions) { option in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                settings.selectedRunnerID = option.id
                            }
                        } label: {
                            VStack(spacing: 8) {
                                if let img = CheetahEngine.previewImage(for: option.id) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .interpolation(.none)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.primary)
                                        .scaleEffect(settings.selectedRunnerID == option.id ? 1.15 : 1.0)
                                } else {
                                    Image(systemName: "hare.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.primary)
                                }
                                Text(option.displayName)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                            .background(settings.selectedRunnerID == option.id ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(settings.selectedRunnerID == option.id ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: settings.selectedRunnerID == option.id ? 2 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Onboarding
struct OnboardingView: View {
    @ObservedObject var settings: CheetahSettingsModel
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            ZStack {
                if currentPage == 0 {
                    OnboardingPage(
                        title: "Meet Cheetah",
                        description: "Monitor your CPU and Memory directly from your menu bar with a customizable running companion.",
                        runnerID: "cheetah"
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if currentPage == 1 {
                    OnboardingPage(
                        title: "Performance & Optimization",
                        description: "Keeps track of heavy processes without draining your battery! Cheetah dynamically adjusts its speed based on CPU load.",
                        runnerID: "rocket"
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if currentPage == 2 {
                    VStack(spacing: 16) {
                        Text("Choose Your Runner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("You can change your menu bar companion at any time.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        RunnerSettingsView(settings: settings)
                            .frame(height: 250)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(12)
                            .padding()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Footer
            HStack {
                // Page indicator Dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(i == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()

                if currentPage < 2 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        hasSeenOnboarding = true
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            appDelegate.onboardingWindow?.close()
                            
                            // Open main menu popover automatically
                            if let button = appDelegate.statusItem.button {
                                NSApp.activate(ignoringOtherApps: true)
                                // Only trigger if popover is off
                                // The user explicitly wanted it to straight go to the main app layout.
                            }
                        } else {
                            NSApp.keyWindow?.close()
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 600, height: 470)
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let runnerID: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if runnerID == "rocket" {
                // Use SF Symbol for rocket
                Image(systemName: "rocket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .padding(30)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
            } else if runnerID == "cheetah" {
                // Use actual app icon
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(30)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Circle())
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.accentColor)
                        .padding(30)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Circle())
                }
            } else if let img = CheetahEngine.previewImage(for: runnerID) {
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .padding(30)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
            } else {
                Image(systemName: "hare.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .padding(30)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
    }
}
