import Foundation
import simd

extension CGRect {
    var topLeft: CGPoint { CGPoint(x: minX, y: minY) }
    var topRight: CGPoint { CGPoint(x: maxX, y: minY) }
    var bottomLeft: CGPoint { CGPoint(x: minX, y: maxY) }
    var bottomRight: CGPoint { CGPoint(x: maxX, y: maxY) }
}

extension CGPoint {

    var float2: simd_float2 { simd_float2(Float(x), Float(y)) }
    
    func normalizedPoint(drawableSize: CGSize, scale: CGFloat) -> CGPoint {
        let inverseViewSize = CGSize(
            width: 1.0 / drawableSize.width * scale,
            height: 1.0 / drawableSize.height * scale
        )

        let clipX = (2.0 * x * inverseViewSize.width) - 1.0
        let clipY = (2.0 * y * -inverseViewSize.height) + 1.0

        return CGPoint(x: clipX, y: clipY)
    }
}
 
//========== METAL COORDINATE SYSTEM ==========//
//                                             //
//     (-1.0, 1.0)               (1.0, 1.0)    //
//                _______________              //
//                |             |              //
//                |             |              //
//                |      *      |              //
//                |  (0.0, 0.0) |              //
//                |             |              //
//                |_____________|              //
//     (-1.0, -1.0)              (1.0, -1.0)   //
//                                             //
//=============================================//
