//
//  ParticleConfiguration.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - ParticleConfiguration
// Defines configuration values for particles and jellyfish simulation.
// Includes counts, appearance, physics, interaction, connections, and glow settings.

struct ParticleConfiguration {

    // MARK: - Particle Count
    let totalParticles: Int       // Total number of particles in simulation
    let coreParticles: Int        // Number of particles forming the jellyfish core

    // MARK: - Particle Appearance
    let minimumRadius: CGFloat    // Smallest particle size
    let maximumRadius: CGFloat    // Largest particle size
    let minimumOpacity: CGFloat   // Minimum transparency
    let maximumOpacity: CGFloat   // Maximum transparency

    // MARK: - Background Particle Physics
    let backgroundSpeed: CGFloat        // Speed of background particles
    let backgroundAcceleration: CGFloat // Acceleration factor
    let backgroundDamping: CGFloat      // Damping factor (slows particles)

    // MARK: - Jellyfish Physics
    let jellyfishMaxSpeed: CGFloat      // Maximum speed of jellyfish particles
    let jellyfishAcceleration: CGFloat  // Acceleration factor for jellyfish
    let jellyfishDamping: CGFloat       // Damping factor for jellyfish

    // MARK: - Cursor Interaction
    let cursorInfluenceRadius: CGFloat     // Radius of cursor effect
    let cursorAttractionStrength: CGFloat  // Strength of attraction to cursor
    let cursorOvershootStrength: CGFloat   // Overshoot effect strength
    let cursorVelocityInfluence: CGFloat   // Influence of cursor velocity

    // MARK: - Autonomous Movement
    let wanderAcceleration: CGFloat        // Random wandering acceleration
    let wanderChangeInterval: TimeInterval // Interval for wander direction change

    // MARK: - Connections
    let connectionDistance: CGFloat        // Max distance for particle connections
    let coreConnectionDistance: CGFloat    // Max distance for core connections
    let connectionOpacity: CGFloat         // Transparency of connection lines

    // MARK: - Glow
    let particleGlowRadius: CGFloat        // Glow radius for background particles
    let jellyfishGlowRadius: CGFloat       // Glow radius for jellyfish core

    // MARK: - Standard Configuration
    static let standard = ParticleConfiguration(
        totalParticles: 230,
        coreParticles: 90,

        minimumRadius: 0.7,
        maximumRadius: 2.0,

        minimumOpacity: 0.25,
        maximumOpacity: 0.90,

        backgroundSpeed: 16,
        backgroundAcceleration: 10,
        backgroundDamping: 0.992,

        jellyfishMaxSpeed: 260,
        jellyfishAcceleration: 420,
        jellyfishDamping: 0.985,

        cursorInfluenceRadius: 420,
        cursorAttractionStrength: 2.2,
        cursorOvershootStrength: 0.85,
        cursorVelocityInfluence: 0.20,

        wanderAcceleration: 75,
        wanderChangeInterval: 1.7,

        connectionDistance: 82,
        coreConnectionDistance: 112,
        connectionOpacity: 0.35,

        particleGlowRadius: 5,
        jellyfishGlowRadius: 90
    )
}

