//
//  ParticleSimulationService.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - Random CGFloat Helper

private func randomCGFloat(
    from minimum: CGFloat,
    to maximum: CGFloat
) -> CGFloat {
    guard maximum > minimum else {
        return minimum
    }

    return minimum +
        CGFloat.random(in: 0...1) *
        (maximum - minimum)
}

// MARK: - Particle Simulation Service

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

    private var randomSeed: CGFloat =
        randomCGFloat(
            from: 0,
            to: 1000
        )

    private var jellyfishVelocity = CGVector(
        dx: 35,
        dy: -12
    )

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

        jellyfishVelocity = CGVector(
            dx: 35,
            dy: -12
        )

        particles.removeAll(
            keepingCapacity: true
        )

        // Start slightly right of center,
        // like the reference animation.
        jellyfishCenter = CGPoint(
            x: size.width * 0.60,
            y: size.height * 0.52
        )

        wanderTarget =
            randomWanderTarget(
                size: size
            )

        createParticles()
    }

    // MARK: - Create Particles

    private func createParticles() {

        // ---------------------------------------------------------
        // Background
        // ---------------------------------------------------------

        // Intentionally lower than configuration.totalParticles.
        // This prevents the screen from becoming a huge network.
        let backgroundCount = min(
            max(
                0,
                configuration.totalParticles -
                    configuration.coreParticles
            ),
            105
        )

        for _ in 0..<backgroundCount {

            let position = CGPoint(
                x: randomCGFloat(
                    from: 0,
                    to: max(canvasSize.width, 1)
                ),
                y: randomCGFloat(
                    from: 0,
                    to: max(canvasSize.height, 1)
                )
            )

            let angle = randomCGFloat(
                from: 0,
                to: CGFloat.pi * 2
            )

            let speed = randomCGFloat(
                from: 2,
                to: configuration.backgroundSpeed * 0.65
            )

            let particle = Particle(
                position: position,

                velocity: CGVector(
                    dx: cos(angle) * speed,
                    dy: sin(angle) * speed
                ),

                radius: randomCGFloat(
                    from: 0.55,
                    to: 1.35
                ),

                opacity: randomCGFloat(
                    from: 0.22,
                    to: 0.68
                ),

                intensity: randomCGFloat(
                    from: 0.35,
                    to: 0.90
                ),

                depth: randomCGFloat(
                    from: 0.2,
                    to: 1.0
                ),

                isCore: false,

                phase: randomCGFloat(
                    from: 0,
                    to: CGFloat.pi * 2
                )
            )

            particles.append(
                particle
            )
        }

        // ---------------------------------------------------------
        // Jellyfish
        // ---------------------------------------------------------

        // Much smaller than the previous version.
        let bodyCount = min(
            20,
            configuration.coreParticles
        )

        let tentacleCount = min(
            36,
            max(
                1,
                configuration.coreParticles -
                    bodyCount
            )
        )

        // ---------------------------------------------------------
        // Organic Body
        // ---------------------------------------------------------

        for index in 0..<bodyCount {

            let normalizedIndex =
                CGFloat(index) /
                CGFloat(
                    max(
                        bodyCount,
                        1
                    )
                )

            let angle =
                normalizedIndex *
                CGFloat.pi * 2

            // Dense toward the center,
            // producing an organic cloud instead of a grid.
            let radius =
                sqrt(
                    randomCGFloat(
                        from: 0.05,
                        to: 1.0
                    )
                )

            let particle = Particle(
                position:
                    jellyfishCenter.adding(
                        CGVector(
                            dx:
                                cos(angle) *
                                38 *
                                radius,

                            dy:
                                sin(angle) *
                                28 *
                                radius
                        )
                    ),

                velocity: .zero,

                radius: randomCGFloat(
                    from: 0.8,
                    to: 1.9
                ),

                opacity: randomCGFloat(
                    from: 0.65,
                    to: 1.0
                ),

                intensity: randomCGFloat(
                    from: 0.65,
                    to: 1.0
                ),

                depth: randomCGFloat(
                    from: 0.75,
                    to: 1.0
                ),

                isCore: true,

                coreAngle: angle,

                coreRadius: radius,

                coreProgress: 0,

                strandIndex: -1,

                phase: randomCGFloat(
                    from: 0,
                    to: CGFloat.pi * 2
                )
            )

            particles.append(
                particle
            )
        }

        // ---------------------------------------------------------
        // Tendrils
        // ---------------------------------------------------------

        let strandCount = 8

        let particlesPerStrand =
            Int(
                ceil(
                    CGFloat(tentacleCount) /
                    CGFloat(strandCount)
                )
            )

        for index in 0..<tentacleCount {

            let strandIndex =
                index % strandCount

            let progressIndex =
                index / strandCount

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

            let strandPosition =
                CGFloat(strandIndex) /
                CGFloat(
                    max(
                        strandCount - 1,
                        1
                    )
                )

            let baseX =
                (
                    strandPosition -
                    0.5
                ) * 58

            let initialPosition =
                jellyfishCenter.adding(
                    CGVector(
                        dx: baseX,
                        dy:
                            20 +
                            clampedProgress * 105
                    )
                )

            let particle = Particle(
                position: initialPosition,

                velocity: .zero,

                radius: randomCGFloat(
                    from: 0.65,
                    to: 1.55
                ),

                opacity: randomCGFloat(
                    from: 0.45,
                    to: 0.90
                ),

                intensity: randomCGFloat(
                    from: 0.45,
                    to: 0.95
                ),

                depth: randomCGFloat(
                    from: 0.65,
                    to: 1.0
                ),

                isCore: true,

                coreAngle: 0,

                coreRadius: 0,

                coreProgress:
                    clampedProgress,

                strandIndex:
                    strandIndex,

                phase:
                    randomCGFloat(
                        from: 0,
                        to: CGFloat.pi * 2
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
                time -
                lastUpdateTime

            deltaTime =
                CGFloat(
                    min(
                        max(
                            rawDelta,
                            0
                        ),
                        1.0 / 20.0
                    )
                )

        } else {

            deltaTime =
                1.0 / 60.0
        }

        lastUpdateTime = time

        animationTime +=
            deltaTime

        updatePointerVelocity()

        updateJellyfishCenter(
            deltaTime:
                deltaTime
        )

        updateParticles(
            deltaTime:
                deltaTime
        )
    }

    // MARK: - Pointer

    func setPointer(
        _ position: CGPoint
    ) {
        currentPointer =
            position
    }

    func clearPointer() {

        currentPointer = nil

        pointerVelocity =
            .zero

        lastPointerPosition =
            nil
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
                to:
                    currentPointer
            )

        pointerVelocity =
            pointerVelocity * 0.65 +
            difference * 0.35

        self.lastPointerPosition =
            currentPointer
    }

    // MARK: - Jellyfish Movement

    private func updateJellyfishCenter(
        deltaTime: CGFloat
    ) {

        if let pointer = currentPointer {

            // Track the pointer exactly — same displacement per frame,
            // so the jellyfish moves at identical speed to the cursor
            // instead of chasing it with acceleration/lag.

            let displacement =
                jellyfishCenter.vector(
                    to: pointer
                )

            jellyfishVelocity =
                deltaTime > 0
                ? displacement * (1 / deltaTime)
                : .zero

            jellyfishCenter = pointer

            return
        }

        var acceleration =
            CGVector(
                dx: 0,
                dy: 0
            )

        updateWanderTarget(
            deltaTime:
                deltaTime
        )

        let difference =
            jellyfishCenter.vector(
                to:
                    wanderTarget
            )

        if difference.length > 1 {

            acceleration =
                acceleration +
                difference.normalized *
                configuration.wanderAcceleration
        }

        // ---------------------------------------------------------
        // Organic floating movement
        // ---------------------------------------------------------

        let organicX =
            sin(
                Double(
                    animationTime * 0.47 +
                    randomSeed
                )
            )

        let organicY =
            cos(
                Double(
                    animationTime * 0.38 +
                    randomSeed * 1.7
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx:
                    CGFloat(organicX) * 22,

                dy:
                    CGFloat(organicY) * 22
            )

        // Soft boundaries.
        acceleration =
            acceleration +
            boundaryForce()

        // Apply acceleration.
        jellyfishVelocity =
            jellyfishVelocity +
            acceleration *
            deltaTime

        // Smooth damping.
        let damping =
            pow(
                configuration.jellyfishDamping,
                deltaTime * 60
            )

        jellyfishVelocity =
            jellyfishVelocity *
            damping

        jellyfishVelocity =
            jellyfishVelocity.limited(
                to:
                    configuration.jellyfishMaxSpeed
            )

        jellyfishCenter =
            jellyfishCenter +
            jellyfishVelocity *
            deltaTime
    }

    // MARK: - Wander

    private func updateWanderTarget(
        deltaTime: CGFloat
    ) {

        wanderTimer +=
            TimeInterval(
                deltaTime
            )

        let distance =
            jellyfishCenter.distance(
                to:
                    wanderTarget
            )

        if wanderTimer >=
            configuration.wanderChangeInterval ||
            distance < 100 {

            wanderTimer = 0

            wanderTarget =
                randomWanderTarget(
                    size:
                        canvasSize
                )
        }
    }

    private func randomWanderTarget(
        size: CGSize
    ) -> CGPoint {

        let margin: CGFloat =
            130

        return CGPoint(
            x:
                randomCGFloat(
                    from:
                        -margin,
                    to:
                        size.width +
                        margin
                ),

            y:
                randomCGFloat(
                    from:
                        -margin,
                    to:
                        size.height +
                        margin
                )
        )
    }

    // MARK: - Boundary Force

    private func boundaryForce()
        -> CGVector {

        let margin: CGFloat =
            130

        var force =
            CGVector(
                dx: 0,
                dy: 0
            )

        if jellyfishCenter.x <
            -margin {

            force.dx +=
                (
                    -margin -
                    jellyfishCenter.x
                ) * 0.8
        }

        if jellyfishCenter.x >
            canvasSize.width +
            margin {

            force.dx -=
                (
                    jellyfishCenter.x -
                    (
                        canvasSize.width +
                        margin
                    )
                ) * 0.8
        }

        if jellyfishCenter.y <
            -margin {

            force.dy +=
                (
                    -margin -
                    jellyfishCenter.y
                ) * 0.8
        }

        if jellyfishCenter.y >
            canvasSize.height +
            margin {

            force.dy -=
                (
                    jellyfishCenter.y -
                    (
                        canvasSize.height +
                        margin
                    )
                ) * 0.8
        }

        return force
    }

    // MARK: - Particle Updates

    private func updateParticles(
        deltaTime: CGFloat
    ) {

        for index in particles.indices {

            var particle =
                particles[index]

            if particle.isCore {

                updateCoreParticle(
                    &particle,
                    deltaTime:
                        deltaTime
                )

            } else {

                updateBackgroundParticle(
                    &particle,
                    deltaTime:
                        deltaTime
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
                for:
                    particle
            )

        let difference =
            particle.position.vector(
                to:
                    target
            )

        let distance =
            difference.length

        var acceleration =
            difference.normalized *
            min(
                distance * 8,
                900
            )

        // Soft independent motion.
        let waveX =
            sin(
                Double(
                    animationTime * 1.1 +
                    particle.phase
                )
            )

        let waveY =
            cos(
                Double(
                    animationTime * 0.85 +
                    particle.phase * 1.31
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx:
                    CGFloat(waveX) * 14,

                dy:
                    CGFloat(waveY) * 14
            )

        particle.velocity =
            particle.velocity +
            acceleration *
            deltaTime

        let damping =
            pow(
                0.88,
                deltaTime * 60
            )

        particle.velocity =
            particle.velocity *
            damping

        particle.velocity =
            particle.velocity.limited(
                to:
                    150
            )

        particle.position =
            particle.position +
            particle.velocity *
            deltaTime

        // Gentle brightness pulse.
        let pulse =
            sin(
                Double(
                    animationTime * 2.0 +
                    particle.phase
                )
            )

        particle.intensity =
            (
                0.72 +
                CGFloat(pulse) * 0.20
            )
            .clamped(
                minimum:
                    0.30,
                maximum:
                    1.0
            )
    }

    // MARK: - Organic Target Position

    private func targetPosition(
        for particle: Particle
    ) -> CGPoint {

        // ---------------------------------------------------------
        // BODY
        // ---------------------------------------------------------

        if particle.strandIndex < 0 {

            let breathing =
                sin(
                    Double(
                        animationTime * 0.65 +
                        particle.phase
                    )
                )

            let secondary =
                cos(
                    Double(
                        animationTime * 0.43 +
                        particle.phase * 0.8
                    )
                )

            let horizontalRadius =
                (
                    36 +
                    CGFloat(breathing) * 7
                ) *
                particle.coreRadius

            let verticalRadius =
                (
                    26 +
                    CGFloat(secondary) * 5
                ) *
                particle.coreRadius

            let angle =
                particle.coreAngle +
                CGFloat(
                    sin(
                        Double(
                            animationTime * 0.55 +
                            particle.phase
                        )
                    )
                ) * 0.10

            let x =
                cos(angle) *
                horizontalRadius

            let y =
                sin(angle) *
                verticalRadius

            return jellyfishCenter.adding(
                CGVector(
                    dx: x,
                    dy: y
                )
            )
        }

        // ---------------------------------------------------------
        // TENDRILS
        // ---------------------------------------------------------

        let progress =
            particle.coreProgress

        let strand =
            CGFloat(
                particle.strandIndex
            )

        let strandNormalized =
            strand / 7.0

        let baseX =
            (
                strandNormalized -
                0.5
            ) * 58

        // Long organic wave.
        let wave =
            sin(
                Double(
                    progress * 4.2 +
                    animationTime * 1.15 +
                    particle.phase
                )
            )

        let secondaryWave =
            cos(
                Double(
                    progress * 2.3 +
                    animationTime * 0.72 +
                    particle.phase * 0.6
                )
            )

        // Tendrils spread more as they descend.
        let spread =
            7 +
            progress * 35

        let x =
            baseX +
            CGFloat(wave) *
            spread +
            CGFloat(secondaryWave) *
            5

        let verticalWave =
            sin(
                Double(
                    animationTime * 0.9 +
                    particle.phase
                )
            )

        let y =
            18 +
            progress * 118 +
            CGFloat(verticalWave) *
            5 *
            progress

        return jellyfishCenter.adding(
            CGVector(
                dx:
                    x,
                dy:
                    y
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

        // Very weak attraction.
        let difference =
            particle.position.vector(
                to:
                    jellyfishCenter
            )

        let distance =
            difference.length

        if distance > 30 &&
            distance < 420 {

            let strength =
                (
                    1 -
                    distance / 420
                ) *
                configuration.backgroundAcceleration *
                0.35

            acceleration =
                acceleration +
                difference.normalized *
                strength
        }

        // Slow drifting.
        let noiseX =
            sin(
                Double(
                    animationTime * 0.22 +
                    particle.phase
                )
            )

        let noiseY =
            cos(
                Double(
                    animationTime * 0.18 +
                    particle.phase * 1.4
                )
            )

        acceleration =
            acceleration +
            CGVector(
                dx:
                    CGFloat(noiseX) * 3,

                dy:
                    CGFloat(noiseY) * 3
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
                    configuration.backgroundSpeed
            )

        particle.position =
            particle.position +
            particle.velocity *
            deltaTime

        wrapParticle(
            &particle
        )
    }

    // MARK: - Wrap

    private func wrapParticle(
        _ particle: inout Particle
    ) {

        let margin: CGFloat =
            20

        if particle.position.x <
            -margin {

            particle.position.x =
                canvasSize.width +
                margin
        }

        if particle.position.x >
            canvasSize.width +
            margin {

            particle.position.x =
                -margin
        }

        if particle.position.y <
            -margin {

            particle.position.y =
                canvasSize.height +
                margin
        }

        if particle.position.y >
            canvasSize.height +
            margin {

            particle.position.y =
                -margin
        }
    }

    // MARK: - Connections

    func connections()
        -> [ParticleConnection] {

        var result:
            [ParticleConnection] = []

        let coreParticles =
            particles.filter {
                $0.isCore
            }

        let backgroundParticles =
            particles.filter {
                !$0.isCore
            }

        // ---------------------------------------------------------
        // Jellyfish Tendrils
        // ---------------------------------------------------------

        for strandIndex in 0..<8 {

            let strandParticles =
                coreParticles
                    .filter {
                        $0.strandIndex ==
                            strandIndex
                    }
                    .sorted {
                        $0.coreProgress <
                            $1.coreProgress
                    }

            guard strandParticles.count > 1
            else {
                continue
            }

            for index in 0..<strandParticles.count - 1 {

                let first =
                    strandParticles[index]

                let second =
                    strandParticles[index + 1]

                result.append(
                    ParticleConnection(
                        start:
                            first.position,

                        end:
                            second.position,

                        opacity:
                            0.42 *
                            (
                                1 -
                                second.coreProgress * 0.35
                            ),

                        width:
                            0.45,

                        isCoreConnection:
                            true
                    )
                )
            }
        }

        // ---------------------------------------------------------
        // Body Connections
        // ---------------------------------------------------------

        let bodyParticles =
            coreParticles.filter {
                $0.strandIndex < 0
            }

        if bodyParticles.count > 1 {

            let sortedBody =
                bodyParticles.sorted {
                    $0.coreAngle <
                        $1.coreAngle
                }

            // Only connect neighboring body particles.
            // This prevents the old rectangular mesh.
            for index in 0..<sortedBody.count {

                let first =
                    sortedBody[index]

                let second =
                    sortedBody[
                        (index + 1) %
                        sortedBody.count
                    ]

                result.append(
                    ParticleConnection(
                        start:
                            first.position,

                        end:
                            second.position,

                        opacity:
                            0.32,

                        width:
                            0.40,

                        isCoreConnection:
                            true
                    )
                )
            }
        }

        // ---------------------------------------------------------
        // Body → Tendril Roots
        // ---------------------------------------------------------

        for strandIndex in 0..<8 {

            guard let firstTendril =
                coreParticles
                    .filter({
                        $0.strandIndex ==
                            strandIndex
                    })
                    .min(by: {
                        $0.coreProgress <
                            $1.coreProgress
                    })
            else {
                continue
            }

            guard let nearestBody =
                bodyParticles.min(by: {
                    $0.position.distance(
                        to:
                            firstTendril.position
                    )
                    <
                    $1.position.distance(
                        to:
                            firstTendril.position
                    )
                })
            else {
                continue
            }

            result.append(
                ParticleConnection(
                    start:
                        nearestBody.position,

                    end:
                        firstTendril.position,

                    opacity:
                        0.28,

                    width:
                        0.40,

                    isCoreConnection:
                        true
                )
            )
        }

        // ---------------------------------------------------------
        // Background Connections
        // ---------------------------------------------------------

        // Very sparse background network.
        // Only connect each particle to its closest nearby particle.
        for particle in backgroundParticles {

            var nearest:
                Particle?

            var nearestDistance:
                CGFloat =
                    58

            for other in backgroundParticles {

                if particle.id ==
                    other.id {
                    continue
                }

                let distance =
                    particle.position.distance(
                        to:
                            other.position
                    )

                if distance <
                    nearestDistance {

                    nearestDistance =
                        distance

                    nearest =
                        other
                }
            }

            if let nearest {

                // Prevent duplicate-looking connections
                // by using ID ordering.
                if particle.id.uuidString <
                    nearest.id.uuidString {

                    let factor =
                        1 -
                        nearestDistance /
                        58

                    result.append(
                        ParticleConnection(
                            start:
                                particle.position,

                            end:
                                nearest.position,

                            opacity:
                                factor * 0.12,

                            width:
                                0.25,

                            isCoreConnection:
                                false
                        )
                    )
                }
            }
        }

        return result
    }
}
