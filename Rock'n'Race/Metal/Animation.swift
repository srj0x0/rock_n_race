import Foundation

class Animation {
    
    final private (set) var isFinished: Bool
    
    private let duration: TimeInterval
    private var launchTime: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
        self.launchTime = .nan
        self.isFinished = false
    }
    
    final func animate(context: RendererContext) {
        if launchTime.isNaN {
            launchTime = context.time
        }
        
        let runtime = context.time - launchTime
        let progress = runtime / duration
        
        if (runtime < duration) {
            draw(context: context, progress: min(max(progress, 0.0), 1.0))
        } else {
            isFinished = true
        }
    }
    
    final func reset() {
        self.launchTime = .nan
        self.isFinished = false
    }
    
    func draw(context: RendererContext, progress: CGFloat) {
        preconditionFailure("Should be overriden without 'super' call")
    }
}
