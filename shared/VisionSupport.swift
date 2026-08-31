#if os(iOS)
import Foundation

public enum VisionSupport {
    /// Vision image classification is unreliable on Simulator; surface that early.
    public static var isLikelyUnavailable: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    public static var deviceBannerMessage: String? {
        isLikelyUnavailable
            ? "Photo labels need a physical iPhone. Sliders and manual checklists still work here."
            : nil
    }
}
#endif
