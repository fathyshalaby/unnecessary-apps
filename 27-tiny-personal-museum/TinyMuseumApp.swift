import SwiftUI
import PhotosUI
import UIKit
import ImageIO
import DumbKit

@main
struct TinyMuseumApp: App {
    var body: some Scene { WindowGroup { TinyMuseumView().dumbNativeEntry(scheme: "app27tinymuseum") { _, _ in } } }
}

private struct MuseumExhibit: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let story: String
    let photoFilename: String?
    let createdAt: Date

    var placard: String {
        let curatorNote = story.isEmpty
            ? "The curator declined to explain why this matters."
            : story
        return "EXHIBIT: \(title)\nCurator’s note: \(curatorNote)\nSignificance: unclear but sincere.\nPlease do not touch the glass."
    }
}

private enum MuseumArchive {
    static let limit = 30

    private static var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TinyMuseum", isDirectory: true)
    }

    private static var catalogURL: URL {
        directory.appendingPathComponent("catalog.json")
    }

    static func load() -> [MuseumExhibit] {
        guard let data = try? Data(contentsOf: catalogURL),
              let decoded = try? JSONDecoder().decode([MuseumExhibit].self, from: data) else {
            return []
        }
        return Array(decoded.prefix(limit))
    }

    static func save(_ exhibits: [MuseumExhibit]) throws {
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete]
        )
        let data = try JSONEncoder().encode(Array(exhibits.prefix(limit)))
        try data.write(to: catalogURL, options: [.atomic, .completeFileProtection])
    }

    static func savePhoto(_ data: Data, for id: UUID) throws -> String {
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete]
        )
        let filename = "\(id.uuidString).jpg"
        try data.write(
            to: directory.appendingPathComponent(filename),
            options: [.atomic, .completeFileProtection]
        )
        return filename
    }

    static func image(named filename: String?) -> UIImage? {
        guard let filename,
              let data = try? Data(contentsOf: directory.appendingPathComponent(filename)) else {
            return nil
        }
        return UIImage(data: data)
    }

    static func deletePhoto(named filename: String?) {
        guard let filename else { return }
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(filename))
    }

    static func clear() throws {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        try FileManager.default.removeItem(at: directory)
    }
}

struct TinyMuseumView: View {
    @State private var exhibits: [MuseumExhibit]
    @State private var objectTitle = ""
    @State private var story = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pendingPhoto: UIImage?
    @State private var pendingJPEG: Data?
    @State private var photoStatus = "A photo is optional. The object’s emotional paperwork is not."
    @State private var showingCamera = false
    @State private var result: String
    @State private var validationMessage = ""
    @State private var showClearConfirmation = false
    @State private var curatorRevision = 0
    @State private var selectedExhibit: MuseumExhibit?

    private let accent = CorpPalette.violet

    init() {
        let loaded = MuseumArchive.load()
        _exhibits = State(initialValue: loaded)
        _result = State(
            initialValue: loaded.first?.placard
                ?? "No exhibit has opened. The gift shop is still somehow operational."
        )
    }

    var body: some View {
        AppCanvas(accent: accent, experience: .gallery) {
            AppHeader(
                eyebrow: "THE MUSEUM OF SMALL THINGS",
                title: "Tiny Personal Museum",
                subtitle: "Archive ordinary objects before history carelessly forgets them.",
                accent: accent,
                showsMascot: false
            )

            DumbBoundaryChip(
                storageKey: "tinyMuseum.boundaryDismissed",
                message: "Private exhibit archive on your device — not a public museum or cloud gallery.",
                accent: accent,
                systemImage: "photo.on.rectangle.angled"
            )

            HStack {
                DumbStatusPill("YOUR MUSEUM", systemImage: "building.columns.fill", accent: accent)
                Spacer()
                Text("\(exhibits.count)/\(MuseumArchive.limit) EXHIBITS")
                    .font(.caption2.weight(.black))
                    .tracking(0.8)
                    .foregroundStyle(CorpPalette.mutedInk)
                    .accessibilityIdentifier("museumExhibitCount")
                    .accessibilityValue("\(exhibits.count)")
            }

            curatorDesk

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "building.columns.fill",
                reactionStyle: .stamp
            )
            .accessibilityIdentifier("museumPlacard")

            if result != "No exhibit has opened. The gift shop is still somehow operational." && !result.hasPrefix("Exhibit changed") {
                DumbShareVerdict(
                    text: result,
                    subject: "Museum placard",
                    accent: accent,
                    accessibilityIdentifier: "shareMuseumPlacardButton"
                )
            }

            exhibitCatalog

            Text("Add a story and a photo if you want. This museum is for you, not an audience.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button(action: resetDesk) {
                    Label("Reset curator desk", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(objectTitle.isEmpty && story.isEmpty && pendingPhoto == nil)
                .accessibilityIdentifier("resetTinyMuseumButton")

                Button {
                    showClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.headline.weight(.black))
                        .frame(width: 48, height: 44)
                }
                .foregroundStyle(CorpPalette.warningRed)
                .buttonStyle(DumbPressStyle())
                .disabled(exhibits.isEmpty)
                .accessibilityLabel("Clear the complete museum")
                .accessibilityIdentifier("clearMuseumButton")
            }
        } bottomBar: {
            if canOpenExhibition {
                DumbAction(
                    title: exhibits.count >= MuseumArchive.limit ? "Museum at capacity" : "Open this exhibition",
                    accent: accent,
                    systemImage: "building.columns.fill",
                    action: openExhibition
                )
                .disabled(exhibitsAtCapacity)
                .accessibilityIdentifier("openTinyExhibitionButton")
            }
        }
        .confirmationDialog(
            "Permanently close every exhibit?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Erase the complete museum", role: .destructive, action: clearMuseum)
            Button("Keep the museum open", role: .cancel) {}
        } message: {
            Text("This closes the museum and erases every exhibit. It cannot be undone.")
        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await importPhoto(item) }
        }
        .sheet(isPresented: $showingCamera) {
            DumbCameraPicker(
                onImage: { image in
                    showingCamera = false
                    Task { await importPhoto(image) }
                },
                onCancel: { showingCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(item: $selectedExhibit) { exhibit in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let photo = MuseumArchive.image(named: exhibit.photoFilename) {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .accessibilityLabel("Photo for \(exhibit.title)")
                        }
                        Text(exhibit.placard)
                            .font(.system(.subheadline, design: .serif).weight(.semibold))
                            .foregroundStyle(CorpPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                }
                .background(CorpPalette.canvas.ignoresSafeArea())
                .navigationTitle(exhibit.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { selectedExhibit = nil }
                    }
                }
            }
        }
    }

    private var canOpenExhibition: Bool {
        !objectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var exhibitsAtCapacity: Bool {
        exhibits.count >= MuseumArchive.limit
    }

    private var curatorDesk: some View {
        return DumbCard(accent: accent, isSelected: !objectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("CURATOR DESK")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(accent)

                DumbField("Object title", maxLength: 120, text: $objectTitle)
                    .accessibilityIdentifier("museumTitleField")
                DumbField(
                    "Why does it belong in a museum?",
                    axis: .vertical,
                    maxLength: 280,
                    text: $story
                )
                .accessibilityIdentifier("museumStoryField")

                HStack(spacing: 10) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Photo library", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("museumPhotoPickerButton")
                    .accessibilityLabel("Photo library")
                    .accessibilityHint("Opens your photo library.")

                    Button {
                        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                            photoStatus = "The camera is not available here. Choose a photo instead."
                            return
                        }
                        showingCamera = true
                    } label: {
                        Label("Take photo", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("museumCameraButton")
                    .accessibilityLabel("Take photo")
                    .accessibilityHint("Opens the camera so you can photograph an exhibit.")
                }
                .font(.subheadline.weight(.black))
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .accessibilityElement(children: .contain)

                if let pendingPhoto {
                    Image(uiImage: pendingPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .accessibilityLabel("Pending exhibit photo")

                    Button {
                        selectedPhoto = nil
                        self.pendingPhoto = nil
                        pendingJPEG = nil
                        photoStatus = "Photo removed from the curator desk."
                    } label: {
                        Label("Remove pending photo", systemImage: "xmark.circle")
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(CorpPalette.warningRed)
                    .accessibilityIdentifier("removePendingMuseumPhotoButton")
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .foregroundStyle(accent.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .frame(height: 196)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title.weight(.black))
                                    .foregroundStyle(accent)
                                Text("Point at an ordinary object")
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                        }
                        .accessibilityIdentifier("museumEmptyFrame")
                }

                Text(photoStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("museumPhotoStatus")

                if !validationMessage.isEmpty {
                    Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.warningRed)
                        .accessibilityIdentifier("museumValidationMessage")
                }
            }
        }
    }

    @ViewBuilder
    private var exhibitCatalog: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERMANENT COLLECTION")
                .font(.caption2.weight(.black))
                .tracking(1.2)
                .foregroundStyle(CorpPalette.mutedInk)

            if exhibits.isEmpty {
                DumbEmptyInvite(
                    title: "The collection is suspiciously empty",
                    message: "Archive one ordinary object before civilization moves on.",
                    systemImage: "shippingbox",
                    accent: accent
                )
                .accessibilityIdentifier("emptyMuseumCatalog")
            } else {
                ForEach(exhibits) { exhibit in
                    exhibitCard(exhibit)
                }
            }
        }
    }

    private func exhibitCard(_ exhibit: MuseumExhibit) -> some View {
        DumbCard(accent: accent, isSelected: exhibit.id == exhibits.first?.id) {
            VStack(alignment: .leading, spacing: 11) {
                if let photo = MuseumArchive.image(named: exhibit.photoFilename) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .accessibilityLabel("Photo for \(exhibit.title)")
                }

                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exhibit.title)
                            .font(.headline.weight(.black))
                        Text(exhibit.story.isEmpty ? "No curator note filed." : exhibit.story)
                            .font(.subheadline)
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    Spacer()
                    Image(systemName: "building.columns.fill")
                        .foregroundStyle(accent)
                        .accessibilityHidden(true)
                }

                Button {
                    selectedExhibit = exhibit
                    result = exhibit.placard
                } label: {
                    Label("View placard", systemImage: "doc.text.fill")
                        .font(.caption.weight(.black))
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("viewExhibitPlacardButton")

                Button(role: .destructive) {
                    delete(exhibit)
                } label: {
                    Label("Deaccession exhibit", systemImage: "trash")
                        .font(.caption.weight(.black))
                }
                .accessibilityIdentifier("deleteExhibit_\(exhibit.id.uuidString)")
            }
        }
        .accessibilityIdentifier("museumExhibitCard")
    }

    private var curatorCaption: String {
        exhibits.isEmpty
            ? "The gallery is open. History has failed to submit an object."
            : "\(exhibits.count) exhibit\(exhibits.count == 1 ? "" : "s") protected from ordinary oblivion."
    }

    private func openExhibition() {
        let cleanTitle = objectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanStory = story.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            validationMessage = "The museum requires an object title."
            result = "No object entered. The gallery remains aggressively minimalist."
            return
        }
        guard exhibits.count < MuseumArchive.limit else {
            validationMessage = "The museum is at capacity. Deaccession something first."
            return
        }

        let id = UUID()
        var savedPhotoFilename: String?
        do {
            let filename = try pendingJPEG.map { try MuseumArchive.savePhoto($0, for: id) }
            savedPhotoFilename = filename
            let exhibit = MuseumExhibit(
                id: id,
                title: cleanTitle,
                story: cleanStory,
                photoFilename: filename,
                createdAt: Date()
            )
            exhibits.insert(exhibit, at: 0)
            try MuseumArchive.save(exhibits)
            result = exhibit.placard
            validationMessage = ""
            resetDesk()
            curatorRevision += 1
        } catch {
            MuseumArchive.deletePhoto(named: savedPhotoFilename)
            validationMessage = "The protected archive could not save this exhibit. Try again."
        }
    }

    private func delete(_ exhibit: MuseumExhibit) {
        let updated = exhibits.filter { $0.id != exhibit.id }
        do {
            try MuseumArchive.save(updated)
            MuseumArchive.deletePhoto(named: exhibit.photoFilename)
            exhibits = updated
            result = exhibits.first?.placard
                ?? "No exhibit has opened. The gift shop is still somehow operational."
            validationMessage = ""
            curatorRevision += 1
        } catch {
            validationMessage = "The museum could not remove that exhibit. Nothing was erased."
        }
    }

    private func resetDesk() {
        objectTitle = ""
        story = ""
        selectedPhoto = nil
        pendingPhoto = nil
        pendingJPEG = nil
        photoStatus = "A photo is optional. The object’s emotional paperwork is not."
        validationMessage = ""
    }

    private func clearMuseum() {
        do {
            try MuseumArchive.clear()
            exhibits = []
            result = "No exhibit has opened. The gift shop is still somehow operational."
            resetDesk()
            curatorRevision += 1
        } catch {
            validationMessage = "The protected archive could not be erased. Your exhibits remain."
        }
    }

    private func importPhoto(_ item: PhotosPickerItem) async {
        await MainActor.run {
            photoStatus = "Preparing the gallery copy…"
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                await MainActor.run {
                    photoStatus = "The gallery could not read that image."
                }
                return
            }

            let image = UIImage(cgImage: cgImage)
            await importPhoto(image)
        } catch {
            await MainActor.run {
                photoStatus = "The gallery could not import that image. Try another one."
            }
        }
    }

    private func importPhoto(_ image: UIImage) async {
        await MainActor.run {
            photoStatus = "Preparing the gallery copy…"
        }

        guard let normalized = normalizedJPEG(from: image) else {
            await MainActor.run {
                photoStatus = "The gallery could not prepare a protected copy."
            }
            return
        }

        await MainActor.run {
            pendingPhoto = UIImage(data: normalized)
            pendingJPEG = normalized
            photoStatus = "The photo is ready for its tiny museum debut."
        }
    }

    private func normalizedJPEG(from image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1_600
        let largestSide = max(image.size.width, image.size.height)
        let scale = min(1, maxDimension / max(largestSide, 1))
        let size = CGSize(
            width: max(1, image.size.width * scale),
            height: max(1, image.size.height * scale)
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let normalized = renderer.image { context in
            UIColor.systemBackground.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return normalized.jpegData(compressionQuality: 0.84)
    }
}
