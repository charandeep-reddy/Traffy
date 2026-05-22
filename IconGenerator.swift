import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func generateIcon() {
    let size = 1024
    let canvas = CGRect(x: 0, y: 0, width: size, height: size)
    let inset: CGFloat = 40
    let roundness: CGFloat = 180

    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: size, height: size,
                        bitsPerComponent: 8, bytesPerRow: 0,
                        space: cs,
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!

    // White rounded square background
    let bgPath = CGPath(roundedRect: canvas.insetBy(dx: inset, dy: inset),
                        cornerWidth: roundness, cornerHeight: roundness, transform: nil)
    ctx.addPath(bgPath)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fillPath()

    // Subtle border
    ctx.addPath(bgPath)
    ctx.setStrokeColor(CGColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1))
    ctx.setLineWidth(2)
    ctx.strokePath()

    // Blue gradient background for the arrows
    let center = CGPoint(x: canvas.midX, y: canvas.midY)
    let innerR: CGFloat = 340
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: center.x - innerR, y: center.y - innerR,
                              width: innerR * 2, height: innerR * 2))
    ctx.clip()

    let gradient = CGGradient(
        colorsSpace: cs,
        colors: [
            CGColor(red: 0, green: 0.45, blue: 1, alpha: 1),
            CGColor(red: 0, green: 0.75, blue: 1, alpha: 1)
        ] as CFArray,
        locations: nil
    )!
    ctx.drawRadialGradient(gradient,
                           startCenter: center, startRadius: 0,
                           endCenter: center, endRadius: innerR,
                           options: [])
    ctx.restoreGState()

    // Down arrow — larger, lower half
    drawArrow(in: ctx, center: CGPoint(x: center.x, y: center.y + 40),
              direction: 1, size: 340, color: 1)

    // Up arrow — smaller, upper half
    drawArrow(in: ctx, center: CGPoint(x: center.x, y: center.y - 60),
              direction: -1, size: 240, color: 0.85)

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

func drawArrow(in ctx: CGContext, center: CGPoint, direction: CGFloat, size: CGFloat, color: CGFloat) {
    // direction: -1 = up, 1 = down
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)

    let shaftW = size * 0.22
    let shaftH = size * 0.40
    let headW = size * 0.60
    let headH = size * 0.35

    ctx.setFillColor(CGColor(red: color, green: color, blue: color, alpha: 1))

    // Shaft
    let shaftEnd = direction * shaftH
    let shaftRect = CGRect(x: -shaftW / 2, y: min(direction >= 0 ? 0 : shaftEnd, direction >= 0 ? shaftEnd : 0),
                           width: shaftW, height: abs(shaftEnd))
    ctx.addRect(shaftRect)

    // Triangle head
    let baseY: CGFloat = 0
    let tipY = direction * (shaftH + headH)
    let triangle = CGMutablePath()
    triangle.move(to: CGPoint(x: -headW / 2, y: baseY))
    triangle.addLine(to: CGPoint(x: headW / 2, y: baseY))
    triangle.addLine(to: CGPoint(x: 0, y: tipY))
    triangle.closeSubpath()
    ctx.addPath(triangle)

    ctx.fillPath()
    ctx.restoreGState()
}

generateIcon()
