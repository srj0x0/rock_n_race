import Foundation
import CoreGraphics
import CoreText
import Metal

extension NSAttributedString {
    
    func texture() -> MTLTexture? {
        let framesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRangeMake(0, self.length),
            nil,
            CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX),
            nil
        )

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(size.width),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
            releaseCallback: nil,
            releaseInfo: nil
        ) else {
            return nil
        }
        
        let frameRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let framePath = CGPath(rect: frameRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.length), framePath, nil)
        CTFrameDraw(frame, context)
        
        guard let imageRef = context.makeImage() else {
            return nil
        }
        
        return try? MetalContext.current.textureLoader.newTexture(cgImage: imageRef)
    }
}
