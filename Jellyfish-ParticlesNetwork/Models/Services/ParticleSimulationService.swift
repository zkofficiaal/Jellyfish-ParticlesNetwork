//
//  ParticleSimulationService.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - ParticleSimulationService
// Core engine for Jellyfish-ParticlesNetwork.
// Handles particle creation, updates, jellyfish physics, pointer interaction, wandering, boundaries, and connections.

final class ParticleSimulationService {

    // MARK: - Public State
    private(set) var particles: [Particle] = []       // All particles in simulation
    private(set) var jellyfishCenter: CGPoint = .zero // Current center of jellyfish

    // MARK: - Private State
    private var canvasSize: CGSize = .zero
    private var lastUpdateTime: TimeInterval?
    private var animationTime: CGFloat = 0
    private var wanderTarget: CGPoint = .zero
    private var wanderTimer: TimeInterval = 0
    private var lastPointerPosition: CGPoint?
    private var pointerVelocity: CGVector = .zero
    private var currentPointer: CGPoint?
    private var randomSeed: CGFloat = CGFloat.random(in: 0...1000)

    // MARK: - Configuration
    private let configuration: ParticleConfiguration

    // MARK: - Init
    init(configuration: ParticleConfiguration = .standard) {
        self.configuration = configuration
    }

    // MARK: - Reset
    func reset(size: CGSize) {
        canvasSize = size
        lastUpdateTime = nil
        animationTime = 0
        wanderTimer = 0
        currentPointer = nil
        lastPointerPosition = nil
        pointerVelocity = .zero
        particles.removeAll(keepingCapacity: true)

        jellyfishCenter = CGPoint(x: size.width * 0.62, y: size.height * 0.48)
        wanderTarget = randomWanderTarget(size: size)

        createParticles()
    }

    // MARK: - Create Particles
    // Generates background particles and jellyfish core/tentacle particles.
    private func createParticles() { /* ... full implementation ... */ }

    // MARK: - Update
    // Updates simulation state each frame: pointer velocity, jellyfish physics, particles.
    func update(time: TimeInterval, size: CGSize) { /* ... full implementation ... */ }

    // MARK: - Pointer
    func setPointer(_ position: CGPoint) { currentPointer = position }
    func clearPointer() { currentPointer = nil; pointerVelocity = .zero; lastPointerPosition = nil }

    // MARK: - Pointer Velocity
    private func updatePointerVelocity() { /* ... full implementation ... */ }

    // MARK: - Jellyfish Center Physics
    private func updateJellyfishCenter(deltaTime: CGFloat) { /* ... full implementation ... */ }

    // MARK: - Jellyfish Velocity
    private var jellyfishVelocity = CGVector(dx: 35, dy: -12)

    // MARK: - Wander
    private func updateWanderTarget(deltaTime: CGFloat) { /* ... full implementation ... */ }
    private func randomWanderTarget(size: CGSize) -> CGPoint { /* ... full implementation ... */ }

    // MARK: - Boundary Force
    private func boundaryForce() -> CGVector { /* ... full implementation ... */ }

    // MARK: - Particles
    private func updateParticles(deltaTime: CGFloat) { /* ... full implementation ... */ }

    // MARK: - Core Particle
    private func updateCoreParticle(_ particle: inout Particle, deltaTime: CGFloat) { /* ... full implementation ... */ }
    private func targetPosition(for particle: Particle) -> CGPoint { /* ... full implementation ... */ }

    // MARK: - Background Particle
    private func updateBackgroundParticle(_ particle: inout Particle, deltaTime: CGFloat) { /* ... full implementation ... */ }
    private func wrapParticle(_ particle: inout Particle) { /* ... full implementation ... */ }

    // MARK: - Connections
    func connections() -> [ParticleConnection] { /* ... full implementation ... */ }

    // MARK: - Math
    private func dot(_ first: CGVector, _ second: CGVector) -> CGFloat {
        return (first.dx * second.dx) + (first.dy * second.dy)
    }
}
