import UIKit
import AVFoundation
import MetalKit

final class ViewController: UIViewController {

    private lazy var mtkView = MTKView()
    private lazy var queuePlayer = AVQueuePlayer()
    private lazy var imageRenderer = ImageRenderer()
    private lazy var game = Game(screenSize: mtkView.bounds.size)

    private var playerLooper: AVPlayerLooper?
    private var time: CGFloat = 1
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        playBackgroundMusic()
    }
    
    private func setupViews() {
        view.addSubview(mtkView)

        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mtkView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mtkView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        mtkView.device = MetalContext.current.device
        mtkView.delegate = self
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
    }
    
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "ace_of_spades", withExtension: "m4a") else {
            return
        }
        let playerItem = AVPlayerItem(asset: AVAsset(url: url))
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()
    }
}

extension ViewController: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        guard let currentDrawable = view.currentDrawable,
              let pathDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = MetalContext.current.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: pathDescriptor)
        else { return }
        
        commandEncoder.setRenderPipelineState(imageRenderer.pipelineState)
        
        let context = RendererContext(
            imageRenderer: imageRenderer,
            commandEncoder: commandEncoder,
            drawableSize: view.drawableSize,
            scale: view.window?.screen.scale ?? 1.0,
            time: time * 1000
        )
        
        game.draw(context: context)

        commandEncoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        
        time += 1.0 / CGFloat(view.preferredFramesPerSecond)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

private extension ViewController {
    
    func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        mtkView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            game.handleTap(location: sender.location(in: mtkView))
        }
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            game.moveStarted(location: sender.location(in: mtkView))
        case .changed:
            game.moved(translation: sender.translation(in: mtkView))
        case .ended:
            game.moveEnded()
        default:
            break
        }
    }
}
