import Foundation

final class Road: Model {

    var speed: CGFloat = 0
    
    private let screenSize: CGSize
    
    private let blocksBuffer = 3
    private var offset: CGFloat = 0
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
    }
    
    func draw(context: RendererContext) {
        let height = screenSize.height
        let width = screenSize.width
        
        let blockSize = CGSize(width: width, height: width * 0.25)
        let blocksCount = Int((height / blockSize.height).rounded(.up)) + blocksBuffer
        
        for i in 0 ..< blocksCount {
            let origin = CGPoint(x: 0, y: height - CGFloat(i) * blockSize.height + offset)
            let image = Image(
                frame: CGRect(origin: origin, size: blockSize),
                texture: Assets.Textures.road
            )
            context.drawImage(image: image)
        }

        offset = offset > blockSize.height ? 0 : offset + speed
    }
}
