import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func generateIcon() {
    let size = 1024
    let canvas = CGRect(x: 0, y: 0, width: size, height: size)
    let inset: CGFloat = 40
    let roundness: CGFloat = 200

    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: size, height: size,
                        bitsPerComponent: 8, bytesPerRow: 0,
                        space: cs,
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!

    // Blue gradient rounded square background
    let bgPath = CGPath(roundedRect: canvas.insetBy(dx: inset, dy: inset),
                        cornerWidth: roundness, cornerHeight: roundness, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    let gradient = CGGradient(
        colorsSpace: cs,
        colors: [
            CGColor(red: 0, green: 0.478, blue: 1, alpha: 1),
            CGColor(red: 0, green: 0.831, blue: 1, alpha: 1)
        ] as CFArray,
        locations: nil
    )!
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: canvas.minX, y: canvas.minY),
                           end: CGPoint(x: canvas.maxX, y: canvas.maxY),
                           options: [])

    // Up arrow stem: vertical line from center to top
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.setLineWidth(56)
    ctx.setLineCap(.round)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: canvas.midX, y: canvas.midY + 80))
    ctx.addLine(to: CGPoint(x: canvas.midX, y: canvas.minY + 130))
    ctx.strokePath()

    // Up arrowhead
    let upTip = CGPoint(x: canvas.midX, y: canvas.minY + 70)
    let upBase: CGFloat = canvas.midY - 80
    let upHalf: CGFloat = 110
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.beginPath()
    ctx.move(to: upTip)
    ctx.addLine(to: CGPoint(x: canvas.midX - upHalf, y: upBase))
    ctx.addLine(to: CGPoint(x: canvas.midX + upHalf, y: upBase))
    ctx.closePath()
    ctx.fillPath()

    // Down arrowhead (no stem)
    let downTip = CGPoint(x: canvas.midX, y: canvas.maxY - 70)
    let downBase: CGFloat = canvas.midY + 150
    let downHalf: CGFloat = 120
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
    ctx.beginPath()
    ctx.move(to: downTip)
    ctx.addLine(to: CGPoint(x: canvas.midX - downHalf, y: downBase))
    ctx.addLine(to: CGPoint(x: canvas.midX + downHalf, y: downBase))
    ctx.closePath()
    ctx.fillPath()

    guard let cgImage = ctx.makeImage() else {
        print("Failed to create CGImage")
        return
    }

    let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources")
    try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

    let pngURL = outputDir.appendingPathComponent("app-icon-1024.png")
    guard let dest = CGImageDestinationCreateWithURL(pngURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("Failed to create image destination")
        return
    }
    CGImageDestinationAddImage(dest, cgImage, nil)
    CGImageDestinationFinalize(dest)
    print("Icon saved to \(pngURL.path)")
}

generateIcon()
