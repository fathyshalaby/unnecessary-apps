import SwiftUI
import PhotosUI
import Vision
import UIKit
import ImageIO
import DumbKit

@main struct PigeonOrSeagullApp: App { var body: some Scene { WindowGroup { PigeonView().dumbNativeEntry(scheme: "app12pigeonorseagull") { _, _ in } } } }
struct PigeonView: View {
    @AppStorage("birdGuess.nearWater") private var nearWater = false
    @AppStorage("birdGuess.looksAngry") private var looksAngry = true
    @AppStorage("birdGuess.wingsOperational") private var wingsOperational = false
    @AppStorage("birdGuess.result") private var result = "The bird is withholding evidence."
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var photoFinding = "The bird bureau has not seen a photo yet."
    @State private var visionRuling: String?
    @State private var showingCamera = false

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        AppCanvas(accent: accent, experience: .camera) {
            AppHeader(
                eyebrow: "ORNITHOLOGICAL EMERGENCY",
                title: "Pigeon or seagull?",
                subtitle: "Please describe the creature. Do not approach it.",
                accent: accent,
                showsMascot: false
            )

            if let banner = VisionSupport.deviceBannerMessage {
            Text(banner)
            .font(.caption.weight(.bold))
            .foregroundStyle(CorpPalette.mutedInk)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityIdentifier("visionDeviceBanner")
            }

            scannerStage

            DumbCard(accent: accent, isSelected: nearWater || looksAngry || wingsOperational) {
            VStack(alignment: .leading, spacing: 4) {
            HStack {
            DumbStatusPill("FIELD SCANNER", systemImage: "scope", accent: accent)
            Spacer()
            Text(visionRuling == nil ? "READY" : "RULING FOUND")
            .font(.caption2.weight(.black).monospaced())
            .foregroundStyle(visionRuling == nil ? CorpPalette.mutedInk : accent)
            }
            Toggle("Near a body of water", isOn: $nearWater)
            Toggle("Looks like it owes you money", isOn: $looksAngry)
            Toggle("Wings look aggressively operational", isOn: $wingsOperational)
            Text("Use the checklist only when the bird refuses to pose.")
            .font(.caption.weight(.semibold))
            .foregroundStyle(CorpPalette.mutedInk)
            .padding(.top, 8)
            }
            }
            .accessibilityIdentifier("birdObservationInputs")

            Button(action: reset) {
            Label("Reset the evidence", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetBirdGuessButton")

        } bottomBar: {
            DumbAction(title: "Identify bird", accent: accent, systemImage: "bird.fill", action: identify)
            .accessibilityIdentifier("identifyBirdButton")

            DumbResult(text: result, accent: accent, systemImage: "binoculars.fill", reactionStyle: .bounce)

            if result != "The bird is withholding evidence." && !result.hasPrefix("Analyzing") {
                DumbShareVerdict(
                    text: result,
                    subject: "Bird ruling",
                    accent: accent,
                    accessibilityIdentifier: "shareBirdRulingButton"
                )
            }

        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await analyze(item) }
        }
        .onChange(of: visionRuling) { _, ruling in
            if let ruling { result = ruling }
        }
        .sheet(isPresented: $showingCamera) {
            DumbCameraPicker(
                onImage: { image in
                    showingCamera = false
                    Task { await analyze(image) }
                },
                onCancel: { showingCamera = false }
            )
            .ignoresSafeArea()
        }
    }

    private var scannerStage: some View {
        DumbCard(accent: accent, isSelected: photo != nil) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    DumbStatusPill("SPECIES SCAN", systemImage: "binoculars.fill", accent: accent)
                    Spacer()
                    Text(photo == nil ? "NO TARGET" : "TARGET LOCKED")
                        .font(.caption2.weight(.black).monospaced())
                        .foregroundStyle(photo == nil ? CorpPalette.mutedInk : accent)
                }

                ZStack {
                    if let photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                            .clipped()
                            .accessibilityLabel("Selected bird photo")
                    } else {
                        VStack(spacing: 9) {
                            ZStack {
                                Circle().stroke(accent.opacity(0.28), lineWidth: 2).frame(width: 86, height: 86)
                                Circle().stroke(accent.opacity(0.18), lineWidth: 1).frame(width: 132, height: 132)
                                Image(systemName: "bird.fill")
                                    .font(.system(.title, design: .rounded).weight(.black))
                                    .foregroundStyle(accent)
                            }
                            Text("Find the suspicious bird")
                                .font(.headline.weight(.black))
                            Text("A photo gives the bureau something to argue about.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                    }
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(accent.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [4, 8]))
                        .padding(2)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 196)
                .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                HStack(spacing: 8) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Library", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("birdPhotoPickerButton")
                    .accessibilityLabel("Photo library")
                    .accessibilityHint("Opens your photo library.")

                    Button {
                        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                            photoFinding = "The camera is not available here. Choose a photo instead."
                            return
                        }
                        showingCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("birdCameraButton")
                    .accessibilityLabel("Take photo")
                    .accessibilityHint("Opens the camera so you can photograph a bird.")
                }
                .font(.subheadline.weight(.black))
                .foregroundStyle(CorpPalette.actionInk)
                .background(accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: accent.opacity(0.22), radius: 0, y: 4)
                .buttonStyle(DumbPressStyle())
                .accessibilityElement(children: .contain)

                Text(photoFinding)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("birdScannerStage")
    }

    private func identify() {
        if let visionRuling {
            result = visionRuling
            return
        }

        result = nearWater && (looksAngry || wingsOperational)
            ? "Seagull. It has a plan and your lunch is in it."
            : nearWater
                ? "Probably seagull. Water is a strong clue."
                : (looksAngry || wingsOperational)
                    ? "Pigeon. An urban professional."
                    : "Pigeon. Congratulations, it is simply shaped like that."
    }

    private func reset() {
        nearWater = false
        looksAngry = true
        wingsOperational = false
        result = "The bird is withholding evidence."
        selectedPhoto = nil
        photo = nil
        photoFinding = "The bird bureau has not seen a photo yet."
        visionRuling = nil
    }

    private func analyze(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                await MainActor.run { photoFinding = "The photo refused to testify." }
                return
            }

            let image = UIImage(cgImage: cgImage)
            await analyze(image)
        } catch {
            await MainActor.run {
                photoFinding = "The photo refused to testify. Try another one."
            }
        }
    }

    private func analyze(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            await MainActor.run {
                photo = image
                photoFinding = "Photo accepted. The bird bureau needs the checklist for this one."
            }
            return
        }

            var requestResult: [VNClassificationObservation] = []
            let request = VNClassifyImageRequest { request, _ in
                requestResult = request.results as? [VNClassificationObservation] ?? []
            }
        do {
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])

            let topLabels = requestResult
                .filter { $0.confidence >= 0.12 }
                .prefix(4)
                .map { $0.identifier.replacingOccurrences(of: "_", with: " ") }
            let joinedLabels = topLabels.isEmpty ? "an unidentified creature" : topLabels.joined(separator: ", ")
            let normalized = topLabels.map { $0.lowercased() }
            let isSeagull = normalized.contains { $0.contains("seagull") || $0.contains("gull") }
            let isPigeon = normalized.contains { $0.contains("pigeon") || $0.contains("dove") }
            let ruling: String
            if isSeagull {
                ruling = "Seagull. The bird bureau sees \(joinedLabels). It still wants your lunch."
            } else if isPigeon {
                ruling = "Pigeon. The bird bureau sees \(joinedLabels). An urban professional."
            } else if normalized.contains(where: { $0.contains("bird") }) {
                ruling = "Bird confirmed, species disputed. The bureau sees \(joinedLabels)."
            } else {
                ruling = "No pigeon or seagull confirmed. The bureau sees \(joinedLabels). The committee remains suspicious."
            }

            await MainActor.run {
                photo = image
                photoFinding = "Bureau notes: \(joinedLabels)."
                visionRuling = ruling
                result = ruling
            }
        } catch {
            await MainActor.run {
                photo = image
                photoFinding = "Photo accepted. The bird bureau needs the checklist for this one."
                visionRuling = nil
            }
        }
    }
}
