import MetalKit
import simd

struct VertexData {
    let position: simd_float2
    let textureCood: simd_float2
}

final class ImageRenderer {
    
    let pipelineState: MTLRenderPipelineState
    
    init() {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2;
        vertexDescriptor.attributes[0].offset = 0;
        vertexDescriptor.attributes[0].bufferIndex = 0;
        vertexDescriptor.attributes[1].format = .float2;
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float2>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0;
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 2 * 2

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = MetalContext.current.library
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexFunction")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentFunction")
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        let mainColorAttachment = pipelineDescriptor.colorAttachments[0]!
        mainColorAttachment.pixelFormat = .bgra8Unorm_srgb
        mainColorAttachment.isBlendingEnabled = true
        mainColorAttachment.rgbBlendOperation = .add
        mainColorAttachment.alphaBlendOperation = .add
        mainColorAttachment.sourceRGBBlendFactor = .sourceAlpha
        mainColorAttachment.sourceAlphaBlendFactor = .one
        mainColorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        mainColorAttachment.destinationAlphaBlendFactor = .one
        
        self.pipelineState = try! MetalContext.current.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func draw(image: Image, drawableSize: CGSize, scale: CGFloat, commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setVertexBytes(image.verticies(drawableSize: drawableSize, scale: scale),
                                      length: MemoryLayout<VertexData>.stride * 6,
                                      index: 0)
        commandEncoder.setFragmentTexture(image.texture, index: 1)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}

private extension Image {
    
    func verticies(drawableSize: CGSize, scale: CGFloat) -> [VertexData] {
        return [
            // Triangle #1
            VertexData(
                position: frame.bottomLeft.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.bottomLeft.float2
            ),
            VertexData(
                position: frame.topLeft.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.topLeft.float2
            ),
            VertexData(
                position: frame.topRight.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.topRight.float2
            ),
            // Triangle #2
            VertexData(
                position: frame.topRight.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.topRight.float2
            ),
            VertexData(
                position: frame.bottomRight.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.bottomRight.float2
            ),
            VertexData(
                position: frame.bottomLeft.normalizedPoint(drawableSize: drawableSize, scale: scale).float2,
                textureCood: TexturePoints.bottomLeft.float2
            ),
        ]
    }
}
