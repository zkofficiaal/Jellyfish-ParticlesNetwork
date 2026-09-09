//
//  Particle.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - Particle
// Represents a single particle in the Jellyfish-ParticlesNetwork simulation.
// Each particle has position, velocity, rendering properties, and jellyfish-specific attributes.

struct Particle: Identifiable {

    // MARK: - Identity
    let id: UUID   // Unique identifier for each particle

    // MARK: - Physics Properties
    var position: CGPoint   // Current position in 2D space
    var velocity: CGVector  // Movement vector (direction + speed)

    // MARK: - Rendering Properties
    var radius: CGFloat     // Size of the particle
    var opacity: CGFloat    // Transparency level
    var intensity: CGFloat  // Brightness or glow strength
    var depth: CGFloat      // Depth for layering effect

    // MARK: - Jellyfish Properties
    var isCore: Bool        // Whether particle belongs to jellyfish core
    var coreAngle: CGFloat  // Angular position around the core
    var coreRadius: CGFloat // Distance from the core center
    var coreProgress: CGFloat // Progress along the jellyfish strand
    var strandIndex: Int    // Which strand this particle belongs to
    var phase: CGFloat      // Phase offset for oscillation/wave motion

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector,
        radius: CGFloat,
        opacity: CGFloat,
        intensity: CGFloat,
        depth: CGFloat,
        isCore: Bool = false,
        coreAngle: CGFloat = 0,
        coreRadius: CGFloat = 0,
        coreProgress: CGFloat = 0,
        strandIndex: Int = 0,
        phase: CGFloat = 0
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.radius = radius
        self.opacity = opacity
        self.intensity = intensity
        self.depth = depth

        self.isCore = isCore
        self.coreAngle = coreAngle
        self.coreRadius = coreRadius
        self.coreProgress = coreProgress
        self.strandIndex = strandIndex
        self.phase = phase
    }
}

