import CoreGraphics
import Foundation

final class ParticleSimulationService {

    // MARK: - Public State

    private(set) var particles: [Particle] = []

    private(set) var jellyfishCenter: CGPoint = .zero

    // MARK: - Private State

    private var canvasSize: CGSize = .zero

    private var lastUpdateTime: TimeInterval?

    private var animationTime: CGFloat = 0

    private var wanderTarget: CGPoint = .zero

    private var wanderTimer: TimeInterval = 0

    private var lastPointerPosition: CGPoint?

    private var pointerVelocity: CGVector = .zero

    private var currentPointer: CGPoint?

    private var randomSeed: CGFloat = CGFloat.random(
        in: 0...1000
    )

    // MARK: - Configuration

    private let configuration: ParticleConfiguration

    // MARK: - Init

    init(
        configuration: ParticleConfiguration = .standard
    ) {
        self.configuration = configuration
    }

    // MARK: - Reset

    func reset(
        size: CGSize
    ) {

        canvasSize = size

        lastUpdateTime = nil

        animationTime = 0

        wanderTimer = 0

        currentPointer = nil

        lastPointerPosition = nil

        pointerVelocity = .zero

        particles.removeAll(
            keepingCapacity: true
        )

        jellyfishCenter = CGPoint(
            x: size.width * 0.62,
            y: size.height * 0.48
        )

        wanderTarget = randomWanderTarget(
            size: size
        )

        createParticles()
    }

    // MARK: - Create Particles

    private func createParticles() {

        let backgroundCount = max(
            0,
            configuration.totalParticles -
            configuration.coreParticles
        )

        // MARK: Background Particles

        for _ in 0..<backgroundCount {

            let position = CGPoint(
                x: CGFloat.random(
                    in: 0...max(canvasSize.width, 1)
                ),
                y: CGFloat.random(
                    in: 0...max(canvasSize.height, 1)
                )
            )

            let angle = CGFloat.random(
                in: 0...(CGFloat.pi * 2)
            )

            let speed = CGFloat.random(
                in: 3...configuration.backgroundSpeed
            )

            let velocity = CGVector(
                dx: cos(angle) * speed,
                dy: sin(angle) * speed
            )

            let particle = Particle(

                position: position,

                velocity: velocity,

                radius: CGFloat.random(
                    in:
                    configuration.minimumRadius...
                    configuration.maximumRadius
                ),

                opacity: CGFloat.random(
                    in:
                    configuration.minimumOpacity...
                    configuration.maximumOpacity
                ),

                intensity: CGFloat.random(
                    in: 0.35...1.0
                ),

                depth: CGFloat.random(
                    in: 0.2...1.0
                ),

                isCore: false,

                phase: CGFloat.random(
                    in: 0...(CGFloat.pi * 2)
                )
            )

            particles.append(
                particle
            )
        }

        // MARK: Jellyfish Core

        let bodyCount = Int(
            CGFloat(configuration.coreParticles) * 0.55
        )

        let tentacleCount = max(
            1,
            configuration.coreParticles - bodyCount
        )

        // MARK: Body

        for index in 0..<bodyCount {

            let normalizedIndex =
                CGFloat(index) /
                CGFloat(max(bodyCount - 1, 1))

            let angle =
                CGFloat.pi +
                normalizedIndex * CGFloat.pi

            let radius = CGFloat.random(
                in: 0.2...1.0
            )

            let initialTarget =
                jellyfishCenter.adding(
                    CGVector(
                        dx: cos(angle) * 60 * radius,
                        dy: sin(angle) * 45 * radius
                    )
                )

            let particle = Particle(

                position: initialTarget,

                velocity: CGVector(
                    dx: 0,
                    dy: 0
                ),

                radius: CGFloat.random(
                    in: 1.0...2.6
                ),

                opacity: CGFloat.random(
                    in: 0.65...1.0
                ),

                intensity: CGFloat.random(
                    in: 0.7...1.0
                ),

                depth: CGFloat.random(
                    in: 0.7...1.0
                ),

                isCore: true,

                coreAngle: angle,

                coreRadius: radius,

                coreProgress: 0,

                strandIndex: -1,

                phase: CGFloat.random(
                    in: 0...(CGFloat.pi * 2)
                )
            )

            particles.append(
                particle
            )
        }

        // MARK: Tentacles

        for index in 0..<tentacleCount {

            let strandCount = 6

            let strandIndex =
                index % strandCount

            let progressIndex =
                index / strandCount

            let particlesPerStrand =
                max(
                    1,
                    Int(
                        ceil(
                            CGFloat(tentacleCount) /
                            CGFloat(strandCount)
                        )
                    )
                )

            let progress =
                CGFloat(progressIndex) /
                CGFloat(
                    max(
                        particlesPerStrand - 1,
                        1
                    )
                )

            let clampedProgress =
                progress.clamped(
                    minimum: 0,
                    maximum: 1
                )

            let horizontalSpacing: CGFloat = 26

            let baseX =
                (
                    CGFloat(strandIndex) -
                    2.5
                ) *
                horizontalSpacing

            let initialPosition =
                jellyfishCenter.adding(
                    CGVector(
                        dx: baseX,
                        dy: 25 + clampedProgress * 140
                    )
                )

            let particle = Particle(

                position: initialPosition,

                velocity: CGVector(
                    dx: 0,
                    dy: 0
                ),

                radius: CGFloat.random(
                    in: 0.9...2.1
                ),

                opacity: CGFloat.random(
                    in: 0.5...0.95
                ),

                intensity: CGFloat.random(
                    in: 0.5...1.0
                ),

                depth: CGFloat.random(
                    in: 0.6...1.0
                ),

                isCore: true,

                coreAngle: 0,

                coreRadius: 0,

                coreProgress: clampedProgress,

                strandIndex: strandIndex,

                phase: CGFloat.random(
                    in: 0...(CGFloat.pi * 2)
                )
            )

            particles.append(
                particle
            )
        }
    }

    // MARK: - Update

    func update(
        time: TimeInterval,
        size: CGSize
    ) {

        if canvasSize != size ||
            particles.isEmpty {

            reset(
                size: size
            )
        }

        let deltaTime: CGFloat

        if let lastUpdateTime {

            let rawDelta =
                time - lastUpdateTime

            deltaTime = CGFloat(
                min(
                    max(rawDelta, 0),
                    1.0 / 20.0
                )
            )

        } else {

            deltaTime =
                1.0 / 60.0
        }

        lastUpdateTime = time

        animationTime += deltaTime

        updatePointerVelocity()

        updateJellyfishCenter(
            deltaTime: deltaTime
        )

        updateParticles(
            deltaTime: deltaTime
        )
    }

    // MARK: - Pointer

    func setPointer(
        _ position: CGPoint
    ) {

        currentPointer = position
    }

    func clearPointer() {

        currentPointer = nil

        pointerVelocity = .zero

        lastPointerPosition = nil
    }

    // MARK: - Pointer Velocity

    private func updatePointerVelocity() {

        guard let currentPointer else {

            pointerVelocity =
                pointerVelocity * 0.90

            return
        }

        guard let lastPointerPosition else {

            self.lastPointerPosition =
                currentPointer

            return
        }

        let difference =
            lastPointerPosition.vector(
                to: currentPointer
            )

        pointerVelocity =
            pointerVelocity * 0.65 +
            difference * 0.35

        self.lastPointerPosition =
            currentPointer
    }

    // MARK: - Jellyfish Center Physics

    private func updateJellyfishCenter(
        deltaTime: CGFloat
    ) {

        var acceleration = CGVector(
            dx: 0,
            dy: 0
        )

        if let pointer = currentPointer {

            let difference =
                jellyfishCenter.vector(
                    to: pointer
                )

            let distance =
                difference.length

            if distance > 0.001 {

                let direction =
                    difference.normalized

                let influence =
                    (
                        1 -
                        min(
                            distance /
                            configuration.cursorInfluenceRadius,
                            1
                        )
                    )

                let distanceFactor =
                    0.55 +
                    min(
                        distance / 180,
                        1.5
                    )

                acceleration =
                    acceleration +
                    direction *
                    (
                        configuration.cursorAttractionStrength *
                        configuration.jellyfishAcceleration *
                        distanceFactor *
                        (0.45 + influence)
                    )

                // MARK: Cursor Velocity Influence

                acceleration =
                    acceleration +
                    pointerVelocity *
                    (
                        configuration.cursorVelocityInfluence *
                        configuration.jellyfishAcceleration
                    )

                // MARK: Overshoot

                let velocityAlongTarget =
                    dot(
                        jellyfishVelocity,
                        direction
                    )

                if distance < 150 &&
                    velocityAlongTarget > 0 {

                    let overshootForce =
                        direction *
                        (
                            velocityAlongTarget *
                            configuration.cursorOvershootStrength
                        )

                    acceleration =
                        acceleration +
                        overshootForce
                }
            }

        } else {

            updateWanderTarget(
                deltaTime: deltaTime
            )

            let difference =
                jellyfishCenter.vector(
                    to: wanderTarget
                )

            let distance =
                difference.length

            if distance > 1 {

                let direction =
                    difference.normalized

                acceleration =
                    acceleration +
                    direction *
                    configuration.wanderAcceleration
            }
        }

        // MARK: Soft Screen Boundaries

        acceleration =
            acceleration +
            boundaryForce()

        // MARK: Random Organic Motion

        let organicX =
            sin(
                Double(
                    animationTime * 0.65 +
                    randomSeed
                )
            )

        let organicY =
            cos(
                Double(
                    animationTime * 0.52 +
                    randomSeed * 1.73
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx: CGFloat(organicX) * 18,
                dy: CGFloat(organicY) * 18
            )

        // MARK: Apply Acceleration

        jellyfishVelocity =
            jellyfishVelocity +
            acceleration *
            deltaTime

        // MARK: Damping

        let damping =
            pow(
                configuration.jellyfishDamping,
                deltaTime * 60
            )

        jellyfishVelocity =
            jellyfishVelocity *
            damping

        // MARK: Maximum Velocity

        jellyfishVelocity =
            jellyfishVelocity.limited(
                to:
                configuration.jellyfishMaxSpeed
            )

        // MARK: Move

        jellyfishCenter =
            jellyfishCenter +
            jellyfishVelocity *
            deltaTime
    }

    // MARK: - Jellyfish Velocity

    private var jellyfishVelocity =
        CGVector(
            dx: 35,
            dy: -12
        )

    // MARK: - Wander

    private func updateWanderTarget(
        deltaTime: CGFloat
    ) {

        wanderTimer += TimeInterval(
            deltaTime
        )

        let distance =
            jellyfishCenter.distance(
                to: wanderTarget
            )

        if wanderTimer >=
            configuration.wanderChangeInterval ||
            distance < 100 {

            wanderTimer = 0

            wanderTarget =
                randomWanderTarget(
                    size: canvasSize
                )
        }
    }

    private func randomWanderTarget(
        size: CGSize
    ) -> CGPoint {

        let margin: CGFloat = 180

        return CGPoint(

            x: CGFloat.random(
                in: -margin...(size.width + margin)
            ),

            y: CGFloat.random(
                in: -margin...(size.height + margin)
            )
        )
    }

    // MARK: - Boundary Force

    private func boundaryForce()
        -> CGVector {

        let margin: CGFloat = 180

        var force =
            CGVector(
                dx: 0,
                dy: 0
            )

        if jellyfishCenter.x < -margin {

            force.dx +=
                (-margin - jellyfishCenter.x) *
                0.7
        }

        if jellyfishCenter.x >
            canvasSize.width + margin {

            force.dx -=
                (
                    jellyfishCenter.x -
                    (canvasSize.width + margin)
                ) * 0.7
        }

        if jellyfishCenter.y < -margin {

            force.dy +=
                (-margin - jellyfishCenter.y) *
                0.7
        }

        if jellyfishCenter.y >
            canvasSize.height + margin {

            force.dy -=
                (
                    jellyfishCenter.y -
                    (canvasSize.height + margin)
                ) * 0.7
        }

        return force
    }

    // MARK: - Particles

    private func updateParticles(
        deltaTime: CGFloat
    ) {

        for index in particles.indices {

            var particle =
                particles[index]

            if particle.isCore {

                updateCoreParticle(
                    &particle,
                    deltaTime: deltaTime
                )

            } else {

                updateBackgroundParticle(
                    &particle,
                    deltaTime: deltaTime
                )
            }

            particles[index] =
                particle
        }
    }

    // MARK: - Core Particle

    private func updateCoreParticle(
        _ particle: inout Particle,
        deltaTime: CGFloat
    ) {

        let target =
            targetPosition(
                for: particle
            )

        let difference =
            particle.position.vector(
                to: target
            )

        let distance =
            difference.length

        var acceleration =
            difference.normalized *
            min(
                distance * 7,
                950
            )

        // Organic movement

        let noiseX =
            sin(
                Double(
                    animationTime * 1.4 +
                    particle.phase
                )
            )

        let noiseY =
            cos(
                Double(
                    animationTime * 1.1 +
                    particle.phase * 1.37
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx: CGFloat(noiseX) * 20,
                dy: CGFloat(noiseY) * 20
            )

        particle.velocity =
            particle.velocity +
            acceleration *
            deltaTime

        let damping =
            pow(
                0.91,
                deltaTime * 60
            )

        particle.velocity =
            particle.velocity *
            damping

        particle.velocity =
            particle.velocity.limited(
                to: 180
            )

        particle.position =
            particle.position +
            particle.velocity *
            deltaTime

        // Dynamic particle intensity

        let pulse =
            sin(
                Double(
                    animationTime * 2.1 +
                    particle.phase
                )
            )

        particle.intensity =
            (
                0.75 +
                CGFloat(pulse) * 0.18
            )
            .clamped(
                minimum: 0.35,
                maximum: 1.0
            )
    }

    // MARK: - Core Target Position

    private func targetPosition(
        for particle: Particle
    ) -> CGPoint {

        if particle.strandIndex < 0 {

            // MARK: Jellyfish Dome

            let morph =
                sin(
                    Double(
                        animationTime * 0.85 +
                        particle.phase
                    )
                )

            let secondaryMorph =
                cos(
                    Double(
                        animationTime * 0.53 +
                        particle.phase * 0.7
                    )
                )

            let horizontalRadius =
                (
                    82 +
                    CGFloat(morph) * 18
                ) *
                particle.coreRadius

            let verticalRadius =
                (
                    55 +
                    CGFloat(secondaryMorph) * 13
                ) *
                particle.coreRadius

            let angle =
                particle.coreAngle +
                CGFloat(
                    sin(
                        Double(
                            animationTime * 0.45 +
                            particle.phase
                        )
                    )
                ) *
                0.12

            let x =
                cos(angle) *
                horizontalRadius

            let y =
                sin(angle) *
                verticalRadius -
                10

            return jellyfishCenter.adding(
                CGVector(
                    dx: x,
                    dy: y
                )
            )
        }

        // MARK: Tentacles

        let progress =
            particle.coreProgress

        let strand =
            CGFloat(
                particle.strandIndex
            )

        let strandBase =
            (
                strand -
                2.5
            ) *
            29

        let wave =
            sin(
                Double(
                    progress * 4.5 +
                    animationTime * 1.2 +
                    particle.phase
                )
            )

        let secondaryWave =
            cos(
                Double(
                    progress * 2.7 +
                    animationTime * 0.8 +
                    particle.phase * 0.5
                )
            )

        let horizontalAmplitude =
            8 +
            progress * 28

        let x =
            strandBase +
            CGFloat(wave) *
            horizontalAmplitude +
            CGFloat(secondaryWave) *
            8

        let y =
            30 +
            progress * 205 +
            CGFloat(
                sin(
                    Double(
                        animationTime * 1.4 +
                        particle.phase
                    )
                )
            ) *
            8 *
            progress

        return jellyfishCenter.adding(
            CGVector(
                dx: x,
                dy: y
            )
        )
    }

    // MARK: - Background Particle

    private func updateBackgroundParticle(
        _ particle: inout Particle,
        deltaTime: CGFloat
    ) {

        var acceleration =
            CGVector(
                dx: 0,
                dy: 0
            )

        // Weak attraction toward the jellyfish.

        let difference =
            particle.position.vector(
                to: jellyfishCenter
            )

        let distance =
            difference.length

        if distance > 20 &&
            distance < 500 {

            let strength =
                (
                    1 -
                    distance / 500
                ) *
                configuration.backgroundAcceleration

            acceleration =
                acceleration +
                difference.normalized *
                strength
        }

        // Organic drifting.

        let noiseX =
            sin(
                Double(
                    animationTime * 0.25 +
                    particle.phase
                )
            )

        let noiseY =
            cos(
                Double(
                    animationTime * 0.21 +
                    particle.phase * 1.5
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx: CGFloat(noiseX) * 5,
                dy: CGFloat(noiseY) * 5
            )

        particle.velocity =
            particle.velocity +
            acceleration *
            deltaTime

        let damping =
            pow(
                configuration.backgroundDamping,
                deltaTime * 60
            )

        particle.velocity =
            particle.velocity *
            damping

        particle.velocity =
            particle.velocity.limited(
                to:
                configuration.backgroundSpeed * 2
            )

        particle.position =
            particle.position +
            particle.velocity *
            deltaTime

        // Soft screen wrapping.

        wrapParticle(
            &particle
        )
    }

    // MARK: - Wrap Background Particle

    private func wrapParticle(
        _ particle: inout Particle
    ) {

        let margin: CGFloat = 20

        if particle.position.x < -margin {

            particle.position.x =
                canvasSize.width + margin
        }

        if particle.position.x >
            canvasSize.width + margin {

            particle.position.x =
                -margin
        }

        if particle.position.y < -margin {

            particle.position.y =
                canvasSize.height + margin
        }

        if particle.position.y >
            canvasSize.height + margin {

            particle.position.y =
                -margin
        }
    }

    // MARK: - Connections

    func connections()
        -> [ParticleConnection] {

        guard particles.count > 1 else {
            return []
        }

        var result:
            [ParticleConnection] = []

        result.reserveCapacity(
            particles.count * 3
        )

        for firstIndex in 0..<particles.count {

            let first =
                particles[firstIndex]

            for secondIndex in
                (firstIndex + 1)..<particles.count {

                let second =
                    particles[secondIndex]

                let distance =
                    first.position.distance(
                        to: second.position
                    )

                let maximumDistance:
                    CGFloat =
                    (
                        first.isCore &&
                        second.isCore
                    )
                    ?
                    configuration.coreConnectionDistance
                    :
                    configuration.connectionDistance

                guard distance <
                    maximumDistance
                else {
                    continue
                }

                let distanceFactor =
                    1 -
                    distance /
                    maximumDistance

                let coreMultiplier:
                    CGFloat =
                    (
                        first.isCore ||
                        second.isCore
                    )
                    ? 1.35
                    : 0.55

                let opacity =
                    distanceFactor *
                    configuration.connectionOpacity *
                    coreMultiplier

                guard opacity > 0.015 else {
                    continue
                }

                let width:
                    CGFloat =
                    (
                        first.isCore &&
                        second.isCore
                    )
                    ? 0.75
                    : 0.35

                result.append(
                    ParticleConnection(
                        start:
                            first.position,
                        end:
                            second.position,
                        opacity:
                            opacity.clamped(
                                minimum: 0,
                                maximum: 0.55
                            ),
                        width:
                            width
                    )
                )
            }
        }

        return result
    }

    // MARK: - Math

    private func dot(
        _ first: CGVector,
        _ second: CGVector
    ) -> CGFloat {

        return (
            first.dx * second.dx
        ) + (
            first.dy * second.dy
        )
    }
}
