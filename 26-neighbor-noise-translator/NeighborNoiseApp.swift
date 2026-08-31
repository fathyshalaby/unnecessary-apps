import SwiftUI
import AVFoundation
import DumbKit

@main struct NeighborNoiseApp: App { var body: some Scene { WindowGroup { NeighborNoiseView().dumbNativeEntry(scheme: "app26neighbornoise") { _, _ in } } } }

private final class LocalNoiseSampler {
    private let engine = AVAudioEngine()
    private let lock = NSLock()
    private var levels: [Double] = []

    func start() throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw LocalNoiseSamplerError.noInput
        }

        input.installTap(onBus: 0, bufferSize: 1_024, format: format) { [weak self] buffer, _ in
            self?.recordLevel(from: buffer)
        }
        do {
            try engine.start()
        } catch {
            input.removeTap(onBus: 0)
            throw error
        }
    }

    func stop() -> Double {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        lock.lock()
        defer { lock.unlock() }
        guard !levels.isEmpty else { return 0 }
        return levels.reduce(0, +) / Double(levels.count)
    }

    private func recordLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return }

        var sum: Double = 0
        for index in 0..<frameCount {
            let sample = Double(channelData[index])
            sum += sample * sample
        }
        let rms = sqrt(sum / Double(frameCount))
        let decibels = 20 * log10(max(rms, 0.0001))
        let normalized = min(max((decibels + 60) / 60, 0), 1)

        lock.lock()
        levels.append(normalized)
        lock.unlock()
    }
}

private enum LocalNoiseSamplerError: Error {
    case noInput
}

struct NeighborNoiseView: View {
    @AppStorage("neighborNoise.noise") private var noise = ""
    @AppStorage("neighborNoise.result") private var result = "The wall is listening."
    @State private var isListening = false
    @State private var noiseLevel = 0.0
    @State private var microphoneStatus = "No wall testimony yet."
    @State private var sampler: LocalNoiseSampler?
    @State private var listenRemaining = 0
    @State private var listenTimer: Timer?

    private let accent = CorpPalette.sky

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "DOMESTIC ACOUSTICS",
                title: "Neighbor noise translator",
                subtitle: "Turn an unexplained thud into a category.",
                accent: accent
            )

            DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
            Button {
            listenToWall()
            } label: {
            Label(isListening ? "Listening to the wall…" : "Listen for two seconds", systemImage: "waveform")
            .font(.headline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(isListening)
            .accessibilityIdentifier("listenNeighborNoiseButton")

            if isListening {
            Text("\(listenRemaining)s remaining")
            .font(.caption.weight(.black))
            .foregroundStyle(accent)
            .monospacedDigit()
            .accessibilityIdentifier("listenRemainingLabel")
            }

            ProgressView(value: noiseLevel)
            .tint(accent)
            .accessibilityLabel("Noise level")

            Text(microphoneStatus)
            .font(.caption.weight(.semibold))
            .foregroundStyle(CorpPalette.mutedInk)

            DumbField("Describe the sound", axis: .vertical, maxLength: 240, text: $noise)
            Text("Prefer not to listen? Describe the suspicious thud yourself.")
            .font(.caption.weight(.semibold))
            .foregroundStyle(CorpPalette.mutedInk)
            }
            }
            .accessibilityIdentifier("neighborNoiseInput")

            Button(action: reset) {
            Label("Reset the wall", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetNeighborNoiseButton")

        } bottomBar: {
            DumbAction(title: "Translate noise", accent: accent, systemImage: "ear.fill", action: translate)
            .accessibilityIdentifier("translateNeighborNoiseButton")

            DumbResult(text: result, accent: accent, systemImage: "waveform", reactionStyle: .shake)

        }
    }

    private func translate() {
        let lower = noise.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !lower.isEmpty else {
            result = "No sound described. The wall has been granted procedural silence."
            return
        }
        result = lower.contains("drill")
            ? "Translation: drilling. Retreat from the wall."
            : lower.contains("music")
                ? "Translation: someone has chosen a bass line."
                : translation(for: lower)
    }

    private func listenToWall() {
        guard !isListening else { return }
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            beginListening()
        case .denied:
            microphoneStatus = "Microphone access is off. Typed descriptions still work."
        case .undetermined:
            microphoneStatus = "Asking for two-second microphone access…"
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        beginListening()
                    } else {
                        microphoneStatus = "Microphone access was declined. Typed descriptions still work."
                    }
                }
            }
        @unknown default:
            microphoneStatus = "The wall declined to testify. Describe the noise instead."
        }
    }

    private func beginListening() {
        do {
            let newSampler = LocalNoiseSampler()
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try newSampler.start()
            sampler = newSampler
            isListening = true
            noiseLevel = 0
            listenRemaining = 2
            microphoneStatus = "Listening… the wall has two seconds to testify."
            listenTimer?.invalidate()
            listenTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                listenRemaining -= 1
                if listenRemaining <= 0 {
                    timer.invalidate()
                    listenTimer = nil
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                finishListening()
            }
        } catch {
            sampler = nil
            isListening = false
            microphoneStatus = "The wall refused to testify. Describe the noise instead."
        }
    }

    private func finishListening() {
        listenTimer?.invalidate()
        listenTimer = nil
        listenRemaining = 0
        guard let sampler else { return }
        let level = sampler.stop()
        self.sampler = nil
        isListening = false
        noiseLevel = level
        let description = noiseDescription(for: level)
        noise = description
        microphoneStatus = "Testimony recorded: two seconds of suspicious wall activity."
        result = translation(for: description)
    }

    private func noiseDescription(for level: Double) -> String {
        if level > 0.72 { return "A serious thud from the wall" }
        if level > 0.35 { return "Furniture, plumbing, or diplomatic incident sounds" }
        return "Suspiciously peaceful wall activity"
    }

    private func translation(for description: String) -> String {
        let lower = description.lowercased()
        if lower.contains("thud") || lower.contains("serious") {
            return "Translation: a serious thud. The wall requests a respectful distance."
        }
        if lower.contains("peaceful") || lower.contains("asleep") {
            return "Translation: suspiciously peaceful. The wall may be asleep."
        }
        return "Translation: furniture, plumbing, or a small diplomatic incident."
    }

    private func reset() {
        listenTimer?.invalidate()
        listenTimer = nil
        listenRemaining = 0
        noise = ""
        result = "The wall is listening."
        isListening = false
        noiseLevel = 0
        microphoneStatus = "No wall testimony yet."
        _ = sampler?.stop()
        sampler = nil
    }
}
