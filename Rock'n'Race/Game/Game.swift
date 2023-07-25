import UIKit

private enum GameState {
    case idle
    case playing
    case gameOver
}

private enum Constants {
    static let initialSpeed: CGFloat = 10.0
    static let speedIncreaseTime: TimeInterval = 30 * 1000
}

final class Game {
    
    private lazy var road = Road(screenSize: screenSize)
    private lazy var player = Car(kind: .player, screenSize: screenSize)
    private lazy var enermy = Car(kind: .enermy, screenSize: screenSize)
    
    private var state = GameState.idle
    private var gameStartTime = TimeInterval.nan
    private var carsOvertaken = 0
    
    private var playerLocation: CGPoint?
    
    private lazy var showAnimation = ShowPlayerAnimation(
        duration: 750,
        player: player,
        road: road
    )
    
    private lazy var tapToStartTexture: MTLTexture! = {
        let text = NSAttributedString(
            string: "TAP TO START",
            attributes: [
                .font: UIFont.systemFont(ofSize: 28),
                .foregroundColor: UIColor.orange,
            ]
        )
        return text.texture()
    }()

    private lazy var gameOverTexture: MTLTexture! = {
        let text = NSAttributedString(
            string: "GAME OVER",
            attributes: [
                .font: UIFont.systemFont(ofSize: 28),
                .foregroundColor: UIColor.red,
            ]
        )
        return text.texture()
    }()
    
    private let screenSize: CGSize
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        setInitialCarsLocation()
    }
    
    func draw(context: RendererContext) {
        switch state {
        case .idle:
            drawIdleState(context: context)
        case .playing:
            drawPlayingState(context: context)
        case .gameOver:
            drawGameOver(context: context)
        }
    }
    
    func setInitialCarsLocation() {
        player.center = CGPoint(
            x: screenSize.width - screenSize.width * 0.25,
            y: screenSize.height - player.frame.height * 0.7
        )
        enermy.center = CGPoint(
            x: screenSize.width - screenSize.width * 0.75,
            y: -enermy.frame.height - Constants.initialSpeed
        )
    }
    
    func reset() {
        state = .idle
        gameStartTime = .nan
        road.speed = 0
        carsOvertaken = 0
        player.isCrashed = false
        enermy.isCrashed = false
        playerLocation = nil
        showAnimation.reset()
        setInitialCarsLocation()
    }
}

extension Game {
    
    func moveStarted(location: CGPoint) {
        guard player.frame.contains(location) else {
            return
        }
        playerLocation = player.center
    }
    
    func moved(translation: CGPoint) {
        guard state == .playing, let playerLocation else {
            return
        }
        
        let location = CGPoint(
            x: playerLocation.x + translation.x,
            y: playerLocation.y + translation.y
        )
        
        player.center = location
    }
    
    func moveEnded() {
        playerLocation = nil
    }
    
    func handleTap(location: CGPoint) {
        switch state {
        case .idle:
            state = .playing
        case .gameOver:
            reset()
        case .playing:
            break
        }
    }
}

private extension Game {
    
    func drawTextInCenter(context: RendererContext, texture: MTLTexture!) {
        let textFrame = CGRect(
            x: screenSize.width / 2 - CGFloat(texture.width / 2),
            y: screenSize.height / 2 - CGFloat(texture.height / 2),
            width: CGFloat(texture.width),
            height: CGFloat(texture.height)
        )

        let image = Image(frame: textFrame, texture: texture)
        context.drawImage(image: image)
    }
    
    func drawScore(context: RendererContext) {
        guard let scoreTexture = NSAttributedString(
            string: "Cars overtaken: \(carsOvertaken)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.orange,
            ]
        ).texture() else { return }
        
        let textFrame = CGRect(
            x: 30,
            y: screenSize.height - 40,
            width: CGFloat(scoreTexture.width),
            height: CGFloat(scoreTexture.height)
        )

        let image = Image(frame: textFrame, texture: scoreTexture)
        context.drawImage(image: image)
    }
}

private extension Game {
    
    func drawIdleState(context: RendererContext) {
        road.draw(context: context)
        drawTextInCenter(context: context, texture: tapToStartTexture)
    }
}

private extension Game {
    
    func drawGameOver(context: RendererContext) {
        player.center.y += road.speed
        enermy.center.y += road.speed
        
        road.draw(context: context)
        player.draw(context: context)
        enermy.draw(context: context)
        
        drawTextInCenter(context: context, texture: gameOverTexture)
    }
}

private extension Game {
    
    func drawPlayingState(context: RendererContext) {
        updateSpeed(context: context)
        
        road.draw(context: context)
        player.draw(context: context)
        
        drawAppearanceIfNeeded(context: context)
        drawEnermy(context: context)
        
        drawCrashIfNeeded(context: context)
        drawScore(context: context)
    }
    
    func updateSpeed(context: RendererContext) {
        if gameStartTime.isNaN {
            gameStartTime = context.time
        } else {
            let runtime = (context.time - gameStartTime)
            let speedIncrease = runtime / Constants.speedIncreaseTime
            road.speed = Constants.initialSpeed + Constants.initialSpeed / 2 * speedIncrease
        }
    }
    
    func drawAppearanceIfNeeded(context: RendererContext) {
        if showAnimation.isFinished {
            return
        }
        showAnimation.animate(context: context)
    }
    
    func drawEnermy(context: RendererContext) {
        if !showAnimation.isFinished { return }
        
        let enermyFrame = enermy.frame

        enermy.center.y += road.speed * 1.5
        enermy.draw(context: context)

        if enermyFrame.minY < screenSize.height + road.speed {
            return
        }
        
        let left = Bool.random()
        enermy.center = CGPoint(
            x: screenSize.width - screenSize.width * (left ? 0.75 : 0.25),
            y: -enermyFrame.height - road.speed
        )
        carsOvertaken += 1
    }
    
    func drawCrashIfNeeded(context: RendererContext) {
        guard player.frame.intersects(enermy.frame) else {
            return
        }
        player.isCrashed = true
        enermy.isCrashed = true
        state = .gameOver
    }
}

final class ShowPlayerAnimation: Animation {
    
    let player: Car
    let road: Road
    
    private let destinationY: CGFloat
    
    init(duration: TimeInterval, player: Car, road: Road) {
        self.player = player
        self.road = road
        self.destinationY = player.center.y
        super.init(duration: duration)
    }
    
    override func draw(context: RendererContext, progress: CGFloat) {
        road.speed = Constants.initialSpeed * progress
        player.center.y = destinationY + (destinationY + road.speed * 1.5) * (1.0 - progress)
        road.draw(context: context)
        player.draw(context: context)
    }
}
