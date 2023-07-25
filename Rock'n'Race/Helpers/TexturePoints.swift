import Foundation
import simd

enum TexturePoints {
    static let topLeft = CGPoint(x: 0.0, y: 0.0)
    static let topRight = CGPoint(x: 1.0, y: 0.0)
    static let bottomLeft = CGPoint(x: 0.0, y: 1.0)
    static let bottomRight = CGPoint(x: 1.0, y: 1.0)
}

//============= TEXTURE POINTS ===============//
//                                            //
//    (0.0, 0.0)                 (1.0, 0.0)   //
//               _______________              //
//               |             |              //
//               |             |              //
//               |             |              //
//               |_____________|              //
//                                            //
//    (0.0, 1.0)                 (1.0, 1.0)   //
//                                            //
//============================================//
