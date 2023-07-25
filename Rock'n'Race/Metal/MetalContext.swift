import MetalKit

final class MetalContext {
    
    static let current = MetalContext()
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let library: MTLLibrary
    let textureLoader: MTKTextureLoader
    
    private init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary()
        else { fatalError() }
        
        self.device = device
        self.commandQueue = commandQueue
        self.library = library
        self.textureLoader = MTKTextureLoader(device: device)
    }
}
