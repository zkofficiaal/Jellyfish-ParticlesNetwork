//
//  ParticleNetworkViewModel.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - ParticleNetworkViewModel
// Acts as the ViewModel in MVVM architecture for Jellyfish-ParticlesNetwork.
// Provides access to particles, connections, and jellyfish center while delegating simulation logic to ParticleSimulationService.

@MainActor
final class ParticleNetworkViewModel {

    // MARK: - Simulation
    private let simulation = ParticleSimulationService() // Core simulation service handling particle updates

    // MARK: - Public Access
    var particles: [Particle] {          // Exposes current particles
        simulation.particles
    }

    var jellyfishCenter: CGPoint {       // Exposes jellyfish core center
        simulation.jellyfishCenter
    }

    var connections: [ParticleConnection] { // Exposes particle connections
        simulation.connections()
    }

    // MARK: - Lifecycle
    func start(size: CGSize) {           // Initializes/reset simulation with given canvas size
        simulation.reset(size: size)
    }

    // MARK: - Update
    func update(time: TimeInterval, size: CGSize) { // Updates simulation state over time
        simulation.update(time: time, size: size)
    }

    // MARK: - Pointer
    func setPointer(_ location: CGPoint) { // Sets pointer location for interaction
        simulation.setPointer(location)
    }

    func clearPointer() {                  // Clears pointer influence
        simulation.clearPointer()
    }
}
