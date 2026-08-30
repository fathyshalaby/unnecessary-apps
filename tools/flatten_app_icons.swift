import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count >= 2 else {
    fputs("usage: flatten_app_icons.swift <png> [<png> ...]\n", stderr)
    exit(64)
}

// App Store icons must be fully opaque. Keep the illustration intact and place
// its transparent pixels on the series' warm paper background.
let background = CGColor(srgbRed: 0.98, green: 0.96, blue: 0.91, alpha: 1)

for argument in CommandLine.arguments.dropFirst() {
    let url = URL(fileURLWithPath: argument)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          let context = CGContext(
              data: nil,
              width: image.width,
              height: image.height,
              bitsPerComponent: 8,
              bytesPerRow: 0,
              space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
          ) else {
        fputs("could not decode \(argument)\n", stderr)
        exit(1)
    }

    context.setFillColor(background)
    context.fill(CGRect(x: 0, y: 0, width: image.width, height: image.height))
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

    guard let flattened = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(
              url as CFURL,
              UTType.png.identifier as CFString,
              1,
              nil
          ) else {
        fputs("could not encode \(argument)\n", stderr)
        exit(1)
    }

    CGImageDestinationAddImage(destination, flattened, nil)
    guard CGImageDestinationFinalize(destination) else {
        fputs("could not finalize \(argument)\n", stderr)
        exit(1)
    }
    print("flattened \(argument)")
}
