import SwiftUI
import PhotosUI
import Vision
import ImageIO
import UIKit
import DumbKit

@main struct DogNameGuesserApp: App { var body: some Scene { WindowGroup { DogNameGuesserView().dumbNativeEntry(scheme: "app24dognameguesser") { _, _ in } } } }
struct DogNameGuesserView: View {
    @AppStorage("dogName.fluff") private var fluff = 5.0
    @AppStorage("dogName.seriousness") private var seriousness = 5.0
    @AppStorage("dogName.guess") private var guess = ""
    @AppStorage("dogName.result") private var result = "The dog is awaiting your accusation."
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var photoFinding = "The name committee has not seen a dog yet."
    @State private var suggestedName: String?
    @State private var showingCamera = false

    private let accent = CorpPalette.courtroomNavy

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "CANINE NOMENCLATURE",
                title: "Dog name guesser",
                subtitle: "The dog will not confirm anything. That is part of the test.",
                accent: accent
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

            cameraStage

            DumbCard(accent: accent, isSelected: !guess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
            HStack {
            DumbStatusPill("NAME LAB", systemImage: "text.badge.checkmark", accent: accent)
            Spacer()
            Text("TWO DIALS")
            .font(.caption2.weight(.black).monospaced())
            .foregroundStyle(CorpPalette.mutedInk)
            }
            DumbSlider(title: "Fluff", value: $fluff, range: 0...10, step: 1, accent: accent)
            DumbSlider(title: "Seriousness", value: $seriousness, range: 0...10, step: 1, accent: accent)
            DumbField("Your guess", maxLength: 60, text: $guess)
            if let suggestedName {
            Button {
            guess = suggestedName
            } label: {
            Label("Use committee suggestion: \(suggestedName)", systemImage: "wand.and.stars")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("useDogSuggestionButton")
            }
            Text("Tune the official nonsense, then make your accusation.")
            .font(.caption.weight(.semibold))
            .foregroundStyle(CorpPalette.mutedInk)
            }
            }
            .accessibilityIdentifier("dogNameInputs")

            Button(action: reset) {
            Label("Reset the accusation", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetDogNameButton")

        } bottomBar: {
            DumbAction(title: "Present the name", accent: accent, systemImage: "pawprint.fill", action: presentName)
            .accessibilityIdentifier("presentDogNameButton")

            DumbResult(text: result, accent: accent, systemImage: "person.text.rectangle.fill", reactionStyle: .stamp)

        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await analyze(item) }
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

    private var cameraStage: some View {
        DumbCard(accent: accent, isSelected: photo != nil) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    DumbStatusPill("PHOTO EVIDENCE", systemImage: "pawprint.fill", accent: accent)
                    Spacer()
                    Text(photo == nil ? "WAITING" : "CAPTURED")
                        .font(.caption2.weight(.black).monospaced())
                        .foregroundStyle(photo == nil ? CorpPalette.mutedInk : accent)
                }

                ZStack {
                    if let photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 196)
                            .clipped()
                            .accessibilityLabel("Selected dog photo")
                    } else {
                        VStack(spacing: 9) {
                            Image(systemName: "pawprint.circle.fill")
                                .font(.system(.largeTitle, design: .rounded).weight(.black))
                                .foregroundStyle(accent)
                            Text("Point the committee at a dog")
                                .font(.headline.weight(.black))
                            Text("A photo is optional, but the committee loves evidence.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                    }
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(accent.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
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
                    .accessibilityIdentifier("dogPhotoPickerButton")
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
                    .accessibilityIdentifier("dogCameraButton")
                    .accessibilityLabel("Take photo")
                    .accessibilityHint("Opens the camera so you can photograph a dog.")
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
        .accessibilityIdentifier("dogEvidenceStage")
    }

    private func presentName() {
        let cleanGuess = guess.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanGuess.isEmpty else {
            result = "You guessed nothing. Bold."
            return
        }
        let verdict = fluff > 7 ? "an excellent fluffy name" : seriousness > 7 ? "a strong government name" : "a name the dog may tolerate"
        result = "\(cleanGuess) is \(verdict). \(photoFinding)"
    }

    private func reset() {
        fluff = 5
        seriousness = 5
        guess = ""
        result = "The dog is awaiting your accusation."
        selectedPhoto = nil
        photo = nil
        photoFinding = "The name committee has not seen a dog yet."
        suggestedName = nil
    }

    private func analyze(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                await MainActor.run {
                    photoFinding = "The photo refused to testify."
                    suggestedName = nil
                }
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
                photoFinding = "Photo accepted. The name committee will proceed on vibes."
                suggestedName = nil
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
                .prefix(3)
                .map { $0.identifier.replacingOccurrences(of: "_", with: " ") }
            let joinedLabels = topLabels.isEmpty ? "an unidentified creature" : topLabels.joined(separator: ", ")
            let dogDetected = topLabels.contains { label in
                let normalized = label.lowercased()
                return normalized.contains("dog") || [
                    "retriever", "terrier", "hound", "poodle", "shepherd", "spaniel", "bulldog",
                    "collie", "chihuahua", "pug", "husky", "corgi", "beagle", "boxer", "mastiff",
                    "schnauzer", "rottweiler", "doberman", "samoyed", "setter", "pointer"
                ].contains(where: normalized.contains)
            }
            let suggestedNames = ["Biscuit", "Mochi", "Winston", "Pickle", "Marmalade", "Professor Wiggles"]
            let proposedName = suggestedNames[(Int(fluff) + Int(seriousness) + topLabels.count) % suggestedNames.count]
            let finding = dogDetected
                ? "The name committee sees \(joinedLabels) and proposes \(proposedName)."
                : "The committee sees \(joinedLabels), but no dog is confirmed. Suspicious."

            await MainActor.run {
                photo = image
                photoFinding = finding
                suggestedName = dogDetected ? proposedName : nil
                if guess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, dogDetected {
                    guess = proposedName
                }
                if dogDetected {
                    let name = guess.trimmingCharacters(in: .whitespacesAndNewlines)
                    result = name.isEmpty ? finding : "Preview: \(name). \(finding)"
                }
            }
        } catch {
            await MainActor.run {
                photo = image
                photoFinding = "Photo accepted. The name committee will proceed on vibes."
                suggestedName = nil
            }
        }
    }
}
