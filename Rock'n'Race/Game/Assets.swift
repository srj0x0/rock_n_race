import Metal

enum Assets {
    
    enum Textures {
        static let road = Assets.loadTexture(name: "road")
        static let player = Assets.loadTexture(name: "player")
        static let enermy = Assets.loadTexture(name: "enermy")
        static let flame = Assets.loadTexture(name: "flame")
    }
    
    static func loadTexture(name: String) -> MTLTexture {
        return try! MetalContext.current.textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: nil)
    }
}
