import MetalKit

final class RendererContext {
    
    private let imageRenderer: ImageRenderer
    private let commandEncoder: MTLRenderCommandEncoder
    private let drawableSize: CGSize
    private let scale: CGFloat
    
    let time: TimeInterval

    init(imageRenderer: ImageRenderer,
         commandEncoder: MTLRenderCommandEncoder,
         drawableSize: CGSize,
         scale: CGFloat,
         time: CGFloat
    ) {
        self.imageRenderer = imageRenderer
        self.commandEncoder = commandEncoder
        self.drawableSize = drawableSize
        self.scale = scale
        self.time = time
    }
    
    func drawImage(image: Image) {
        imageRenderer.draw(
            image: image,
            drawableSize: drawableSize,
            scale: scale,
            commandEncoder: commandEncoder
        )
    }
}
