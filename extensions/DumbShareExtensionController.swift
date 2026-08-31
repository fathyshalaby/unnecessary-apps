import Social
import UIKit
import UniformTypeIdentifiers

/// Base Share extension controller — subclass per app with scheme + app key.
open class DumbShareExtensionController: UIViewController {
    open var appScheme: String { "app30apologydraft" }
    open var shareAppKey: String { "app30" }
    open var routeAction: String { "share" }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await handleShare() }
    }

    @MainActor
    private func handleShare() async {
        let text = await extractedText().trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            storePayload(text)
        }
        guard let url = URL(string: "\(appScheme)://\(routeAction)") else {
            finish()
            return
        }
        extensionContext?.open(url) { _ in
            self.finish()
        }
    }

    private func storePayload(_ text: String) {
        guard let store = UserDefaults(suiteName: "group.corp.unecessary.shared") else { return }
        store.set(text, forKey: "\(shareAppKey).sharePayload")
        store.set(Date().timeIntervalSince1970, forKey: "\(shareAppKey).updatedAt")
    }

    private func extractedText() async -> String {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return "" }
        var chunks: [String] = []
        for item in items {
            guard let providers = item.attachments else { continue }
            for provider in providers {
                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                   let data = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier),
                   let text = data as? String {
                    chunks.append(text)
                } else if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier),
                          let data = try? await provider.loadItem(forTypeIdentifier: UTType.text.identifier),
                          let text = data as? String {
                    chunks.append(text)
                }
            }
            if let attributed = item.attributedContentText?.string, !attributed.isEmpty {
                chunks.append(attributed)
            }
        }
        return chunks.joined(separator: "\n\n")
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
