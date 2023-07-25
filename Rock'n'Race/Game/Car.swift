import MetalKit

final class Car: Model {
    
    enum Kind {
        case player
        case enermy
        
        var aspectRatio: CGFloat {
            switch self {
            case .player: return 0.4
            case .enermy: return 0.5
            }
        }
        
        var texture: MTLTexture {
            switch self {
            case .player: return Assets.Textures.player
            case .enermy: return Assets.Textures.enermy
            }
        }
    }
    
    let kind: Kind
    let screenSize: CGSize

    var center: CGPoint
    var isCrashed = false
    
    init(kind: Kind, screenSize: CGSize) {
        self.kind = kind
        self.center = CGPointZero
        self.screenSize = screenSize
    }
    
    func draw(context: RendererContext) {
        let texture = isCrashed ? Assets.Textures.flame : kind.texture
        let image = Image(frame: frame, texture: texture)
        context.drawImage(image: image)
    }
    
    var frame: CGRect {
        let size = CGSize(
            width: screenSize.width * 0.25,
            height: screenSize.width * 0.25 / kind.aspectRatio
        )
        let origin = CGPoint(
            x: center.x - size.width * 0.5,
            y: center.y - size.height * 0.5
        )
        return CGRect(origin: origin, size: size)
    }
}
